//
//  GmailContactVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 31/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2
import GoogleSignIn
import Alamofire
import SwiftyJSON

var accountMail = ""

class GmailContactVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

   // private let scopes = [kGTLRAuthScopeGmailReadonly]
    private let service = GTLRGmailService()
    fileprivate var networkController : NetworkController!
    fileprivate var accessToken : String?
    @IBOutlet var tblContact : UITableView!
    @IBOutlet var btnImport : UIButton!
    @IBOutlet var btnSelectAll : UIButton!
    @IBOutlet var imgSelectAll : UIImageView!
    
    var arrTitle = [String]()
    var arrEmail = [String]()
    var arrSelectedContacts = [String]()
    var dictSelectedContacts = [[String:AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblContact.tableFooterView = UIView()
        arrSelectedContacts = []
        dictSelectedContacts = []
        btnImport.isEnabled = false
        btnSelectAll.setTitle("Select All", for: .normal)
        imgSelectAll.image = #imageLiteral(resourceName: "unchk")
        
        OBJCOM.setLoader()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.google.com/m8/feeds","https://www.googleapis.com/auth/contacts.readonly"];
    
        GIDSignIn.sharedInstance().signIn()
    }
   
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let urlString = "https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=500&access_token=\(user.authentication.accessToken!)&v=3.0"
        
        print(GIDSignIn.sharedInstance().scopes)
        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                accountMail = user.profile.email
                
                switch response.result {
                case .success( _):
                    do{
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[]) as! [String : AnyObject]
                        if let res = json["feed"]!["entry"] as? [[String: Any]] {
                            print(res)
                            self.arrTitle = []
                            self.arrEmail = []
                            for i in 0 ..< res.count {
                                if let arrT = res[i]["gd$name"] as? [String: Any] {
                                    for obj in arrT["gd$fullName"] as! NSDictionary {
                                        self.arrTitle.append(obj.value as? String ?? "")
                                    }
                                    if let arrT = res[i]["gd$email"] as? [[String: Any]] {
                                        if let usersEmail = arrT[0] as? [String : Any] {
                                            if let userEmail = usersEmail["address"] {
                                                self.arrEmail.append(userEmail as? String ?? "")
                                                print(userEmail)
                                            }else{
                                                self.arrEmail.append("Not available")
                                            }
                                        }
                                    }else{
                                        self.arrEmail.append("Not available")
                                    }
                                }
                            }
                                
                            print(self.arrTitle)
                            print(self.arrEmail)
                            self.tblContact.reloadData()
                            OBJCOM.hideLoader()
                        }
                    }catch let error as NSError{
                        print(error)
                        OBJCOM.hideLoader()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    OBJCOM.hideLoader()
                }
        }
    }
}

extension GmailContactVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblContact.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GoogleContactCell
        
        if self.arrSelectedContacts.contains(self.arrEmail[indexPath.row]){
            cell.imgSelect.image = #imageLiteral(resourceName: "chk")
        }else{
            cell.imgSelect.image = #imageLiteral(resourceName: "unchk")
        }
        
        cell.lblName.text = self.arrTitle[indexPath.row]
        cell.lblEmail.text = self.arrEmail[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arrName = arrTitle[indexPath.row].components(separatedBy: " ")
        var fName = ""
        var lName = ""
        if arrName.count > 0 && arrName.count < 2 {
            fName = arrName[0]
            lName = ""
        }else if arrName.count > 0 && arrName.count >= 2 {
            fName = arrName[0]
            lName = arrName[1]
        }
        
        let dict = ["contact_other_email": "",
                    "contact_phone": "",
                    "contact_skype_id": "",
                    "contact_company_name": "",
                    "contact_country": "",
                    "contact_description": "",
                    "contact_lname": fName,
                    "contact_work_email": "",
                    "contact_flag": "1",
                    "contact_other_phone": "",
                    "contact_twitter_name": "",
                    "contact_users_id": userID,
                    "contact_work_phone": "",
                    "contact_fname": lName,
                    "contact_linkedinurl": "",
                    "contact_address": "",
                    "contact_city": "",
                    "contact_state": "",
                    "contact_facebookurl": "",
                    "contact_zip": "",
                    "contact_platform": "3",
                    "contact_email": arrEmail[indexPath.row]]
        
        let cell = tblContact.cellForRow(at: indexPath) as! GoogleContactCell

        if self.arrSelectedContacts.contains(arrEmail[indexPath.row]) {
           let index = self.arrSelectedContacts.index(of: arrEmail[indexPath.row])
            self.arrSelectedContacts.remove(at: index!)
            self.dictSelectedContacts.remove(at: index!)
            cell.imgSelect.image = #imageLiteral(resourceName: "unchk")
        }else{
            self.dictSelectedContacts.append(dict as [String : AnyObject])
            self.arrSelectedContacts.append(arrEmail[indexPath.row])
            cell.imgSelect.image = #imageLiteral(resourceName: "chk")
        }
        
        if self.dictSelectedContacts.count > 0 {
            btnImport.isEnabled = true
        }else{
            btnImport.isEnabled = false
        }
        
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
//
//        headerView.backgroundColor = UIColor.groupTableViewBackground
//
//        let btn = UIButton()
//        btn.frame = CGRect.init(x: 8, y: 5, width: 170, height: 33)
//        btn.setTitle("Select All", for: .normal)
//       // btn.setTitle("Deselect All", for: .selected)
//        btn.setImage(#imageLiteral(resourceName: "unchk"), for: .normal)
//       // btn.setImage(#imageLiteral(resourceName: "chk"), for: .selected)
//       // btn.isSelected = false
//        btn.setTitleColor(.black, for: .normal)
//        //btn.setTitleColor(.black, for: .selected)
//        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
//        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//        btn.contentMode = .center
//
//        btn.addTarget(self, action: #selector(actionSelectAllContacts(_:)), for: .touchUpInside)
//
//        headerView.addSubview(btn)
//
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44
//    }
    
    @IBAction func actionSelectAllContacts(_ sender:UIButton) {
        
        if sender.titleLabel?.text == "Select All"{
            sender.setTitle("Deselect All", for: .normal)
            imgSelectAll.image = #imageLiteral(resourceName: "chk")
            
            self.arrSelectedContacts = []
            self.dictSelectedContacts = []
            SelectAllContacts()
        }else{
            sender.setTitle("Select All", for: .normal)
            imgSelectAll.image = #imageLiteral(resourceName: "unchk")
            deselectAllContacts()
        }
    }
    
    func SelectAllContacts(){
        
        for i in 0 ..< arrTitle.count {
            
            let arrName = arrTitle[i].components(separatedBy: " ")
            var fName = ""
            var lName = ""
            if arrName.count > 0 && arrName.count < 2 {
                fName = arrName[0]
                lName = ""
            }else if arrName.count > 0 && arrName.count >= 2 {
                fName = arrName[0]
                lName = arrName[1]
            }
            
            let dict = ["contact_other_email": "",
                        "contact_phone": "",
                        "contact_skype_id": "",
                        "contact_company_name": "",
                        "contact_country": "",
                        "contact_description": "",
                        "contact_lname": fName,
                        "contact_work_email": "",
                        "contact_flag": "1",
                        "contact_other_phone": "",
                        "contact_twitter_name": "",
                        "contact_users_id": userID,
                        "contact_work_phone": "",
                        "contact_fname": lName,
                        "contact_linkedinurl": "",
                        "contact_address": "",
                        "contact_city": "",
                        "contact_state": "",
                        "contact_facebookurl": "",
                        "contact_zip": "",
                        "contact_platform": "3",
                        "contact_email": arrEmail[i]]
            
            self.dictSelectedContacts.append(dict as [String : AnyObject])
            self.arrSelectedContacts.append(arrEmail[i])
        }
        self.btnImport.isEnabled = true
        self.tblContact.reloadData()
        
    }
    
    func deselectAllContacts(){
        self.arrSelectedContacts = []
        self.dictSelectedContacts = []
        self.btnImport.isEnabled = false
        self.tblContact.reloadData()
    }
    
    @IBAction func actionClose(_ sender:UIButton) {
//        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImportContacts(_ sender:UIButton) {
      //  print(self.arrSelectedContacts)
        
        if dictSelectedContacts.count > 0 {
            importGoogleContacts(items: dictSelectedContacts)
        }
    }
    
//    @IBAction func actionSelectAllContacts(_ sender:UIButton) {
//
//    }
    
    @IBAction func actionMoreOptions(_ sender:UIButton) {
        let alert = UIAlertController(title: accountMail, message: nil, preferredStyle: .actionSheet)
        
        let actionSignOut = UIAlertAction(title: "Sign Out", style: .default)
        {
            UIAlertAction in
            self.googleSignOut()
        }
        actionSignOut.setValue(UIColor.black, forKey: "titleTextColor")
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionSignOut)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func googleSignOut(){
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func importGoogleContacts(items:[[String:Any]]){
        var arrForImport = [AnyObject]()
        for item in items {
            arrForImport.append(item as AnyObject)
        }
        if arrForImport.count > 0 {
            print("----------------------------------")
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "contact_details":arrForImport] as [String : Any]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "importCrmDevice", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: "Google contacts imported successfully.")
                
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.removeDuplicateContacts()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                self.dismiss(animated: true, completion: nil)
            };
        }
    }
    
    func removeDuplicateContacts(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteDuplicateCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
        };
    }
    
}

class LeftAlignedIconButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHorizontalAlignment = .left
        let availableSpace = UIEdgeInsetsInsetRect(bounds, contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.right - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: availableWidth / 2, bottom: 0, right: 0)
    }
}
