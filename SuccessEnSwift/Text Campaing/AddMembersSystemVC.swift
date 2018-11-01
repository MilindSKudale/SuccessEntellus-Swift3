//
//  AddMembersSystemVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddMembersSystemVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var viewSearch : UIView!
    @IBOutlet var selectionView : UIView!
    @IBOutlet var btnContact : UIButton!
    @IBOutlet var btnProspect : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var btnRecruit : UIButton!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnAssign : UIButton!
    
    var mainArrayList = [String]()
    var mainArrayID = [String]()
    var mainArrayListSearch = [String]()
    var mainArrayIDSearch = [String]()
    var arrContactList = [String]()
    var arrProspectList = [String]()
    var arrCustomerList = [String]()
    var arrRecruitList = [String]()
    var arrContactID = [String]()
    var arrProspectID = [String]()
    var arrCustomerID = [String]()
    var arrRecruitID = [String]()
    var arrSelectedIDs = [String]()
    var CampaignId = ""
    var isFilter = false;
    var CampaignType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblList.tableFooterView = UIView()
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        btnAssign.layer.cornerRadius = 5.0
        btnAssign.clipsToBounds = true
        
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        isFilter = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            
            if CampaignType == "TextCampaign" {
                self.getContactList(action: "getListCrmForTxtMsg")
                self.getProspectList(action: "getListCrmForTxtMsg")
                self.getCustomerList(action: "getListCrmForTxtMsg")
                self.getRecruitList(action: "getListCrmForTxtMsg")
            } else if CampaignType == "EmailCampaign" {
                self.getContactList(action: "getListCrmForEmailCamp")
                self.getProspectList(action: "getListCrmForEmailCamp")
                self.getCustomerList(action: "getListCrmForEmailCamp")
                self.getRecruitList(action: "getListCrmForEmailCamp")
            }
            
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        selectionView.layer.borderColor = APPGRAYCOLOR.cgColor
        selectionView.layer.borderWidth = 1.0
        viewSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        viewSearch.layer.borderWidth = 1.0
        txtSearch.leftViewMode = UITextFieldViewMode.always
        txtSearch.layer.cornerRadius = txtSearch.frame.size.height/2
        txtSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        txtSearch.layer.borderWidth = 1.0
        txtSearch.clipsToBounds = true
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        let image = #imageLiteral(resourceName: "icons8-search")
        
        imageView.image = image
        uiView.addSubview(imageView)
        txtSearch.leftView = uiView
        self.txtSearch.delegate = self
    }
    
    @IBAction func actionClose (_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddMembersSystemVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.mainArrayListSearch.count
        }else { return mainArrayList.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "EditCell") as! EditGroupCell
        
        if isFilter {
            cell.lblName.text = self.mainArrayListSearch[indexPath.row]
            
            let selId = self.mainArrayIDSearch[indexPath.row]
            if self.arrSelectedIDs.contains(selId){
                cell.imgSelectBox.image = #imageLiteral(resourceName: "checkbox_ic")
            }else{
                cell.imgSelectBox.image = #imageLiteral(resourceName: "uncheck")
            }
        }else{
            cell.lblName.text = self.mainArrayList[indexPath.row]
            
            let selId = self.mainArrayID[indexPath.row]
            if self.arrSelectedIDs.contains(selId){
                cell.imgSelectBox.image = #imageLiteral(resourceName: "checkbox_ic")
            }else{
                cell.imgSelectBox.image = #imageLiteral(resourceName: "uncheck")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFilter {
            let selId = self.mainArrayIDSearch[indexPath.row]
            if self.arrSelectedIDs.contains(selId){
                if let index = self.arrSelectedIDs.index(of: selId) {
                    self.arrSelectedIDs.remove(at: index)
                }
            }else{
                self.arrSelectedIDs.append(selId)
            }
        }else{
            let selId = self.mainArrayID[indexPath.row]
            if self.arrSelectedIDs.contains(selId){
                if let index = self.arrSelectedIDs.index(of: selId) {
                    self.arrSelectedIDs.remove(at: index)
                }
            }else{
                self.arrSelectedIDs.append(selId)
            }
        }
        self.tblList.reloadData()
    }
}

extension AddMembersSystemVC {
    
    @IBAction func actionShowContactList (_ sender:UIButton){
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrContactList
        mainArrayID = arrContactID
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowProspectList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrProspectList
        mainArrayID = arrProspectID
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowCustomerList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrCustomerList
        mainArrayID = arrCustomerID
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowRecruiterList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setSelected(btnRecruit)
        mainArrayList = arrRecruitList
        mainArrayID = arrRecruitID
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    func setSelected(_ btn : UIButton){
        btn.backgroundColor = APPGRAYCOLOR
        btn.setTitleColor(.white, for: .normal)
    }
    func setDeSelected(_ btn : UIButton){
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func actionAssign (_ sender:UIButton){
       if self.arrSelectedIDs.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member.")
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                if CampaignType == "TextCampaign" {
                    self.assignTextMembers()
                }else if CampaignType == "EmailCampaign" {
                    self.assignEmaiMembers()
                }
                
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
}

extension AddMembersSystemVC {
    
    func getContactList(action:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrContactList = []
                self.arrContactID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrContactList.append(name)
                        self.arrContactID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                self.mainArrayList = self.arrContactList
                self.mainArrayID = self.arrContactID
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getProspectList(action:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrProspectList = []
                self.arrProspectID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrProspectList.append(name)
                        self.arrProspectID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCustomerList(action:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"2"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrCustomerList = []
                self.arrCustomerID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrCustomerList.append(name)
                        self.arrCustomerID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getRecruitList(action:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrRecruitList = []
                self.arrRecruitID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrRecruitList.append(name)
                        self.arrRecruitID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
   
    func assignTextMembers(){
        let strSelect = self.arrSelectedIDs.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txt_contact_ids": strSelect,
                         "txtcontactMainCampaignId":CampaignId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addSystemCrmToTxtCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NotificationCenter.default.post(name: Notification.Name("UpdateTextCampaignVC"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func assignEmaiMembers(){
        let strSelect = self.arrSelectedIDs.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contact_ids": strSelect,
                         "contactCampaignAssignId":CampaignId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addSystemCrmToEmailCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NotificationCenter.default.post(name: Notification.Name("UpdateTextCampaignVC"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension AddMembersSystemVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        mainArrayIDSearch.removeAll()
        mainArrayListSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< self.mainArrayList.count {
                let strName = mainArrayList[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if strName != nil {
                    self.mainArrayListSearch.append(self.mainArrayList[i])
                    self.mainArrayIDSearch.append(self.mainArrayID[i])
                }
            }
        } else {
            isFilter = false
        }
        self.tblList.reloadData()
    }
}

