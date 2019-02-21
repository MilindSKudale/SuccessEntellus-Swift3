//
//  ApproveAccessSettingVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ApproveAccessSettingVC: UIViewController {
    
    @IBOutlet var tblView : UITableView!
    @IBOutlet var tblViewHeight : NSLayoutConstraint!
    
    //For Remove Access
    @IBOutlet var removeView : UIView!
    @IBOutlet var btnSelectUser : UIButton!
    @IBOutlet var btnRemoveAccess : UIButton!
    
    //For approve
    var arrAppAccessId = [String]()
    var arrAppUserName = [String]()
    var selectedUser = ""

    //For request
    var arrReqAccessId = [String]()
    var arrReqModule = [AnyObject]()
    var arrReqImg = [String]()
    var arrReqName = [String]()
    var arrReqAccessDate = [String]()
    var accessImage : [UIImage] = [#imageLiteral(resourceName: "ic_scorecard"), #imageLiteral(resourceName: "ic_calendar"), #imageLiteral(resourceName: "profile")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.tableFooterView = UIView()
        self.tblView.estimatedRowHeight = 80.0
        
        self.removeView.layer.cornerRadius = 5.0
        self.removeView.layer.borderColor = APPGRAYCOLOR.cgColor
        self.removeView.layer.borderWidth = 0.5
        self.removeView.clipsToBounds = true
        
        self.btnSelectUser.layer.cornerRadius = 5.0
        self.btnSelectUser.layer.borderColor = APPGRAYCOLOR.cgColor
        self.btnSelectUser.layer.borderWidth = 0.5
        self.btnSelectUser.clipsToBounds = true
        
        self.btnRemoveAccess.layer.cornerRadius = 5.0
        self.btnRemoveAccess.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getRequestList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getRequestList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorRequestedAndApproved", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrReqAccessId = []
            self.arrReqName = []
            self.arrReqImg = []
            self.arrReqModule = []
            self.arrReqAccessDate = []

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [String : Any]
               
                let requestData = data["requested"] as! [AnyObject]
                let approveData = data["approved"] as! [AnyObject]

                //requested user logic
                for i in 0..<requestData.count {
                    self.arrReqAccessId.append(requestData[i]["accessId"] as? String ?? "")
                    self.arrReqName.append(requestData[i]["userNameReq"] as? String ?? "")
                    self.arrReqImg.append(requestData[i]["imgPath"] as? String ?? "")
                    self.arrReqModule.append(requestData[i]["accessModule"] as AnyObject)
                    self.arrReqAccessDate.append(requestData[i]["cftAccessDate"] as? String ?? "")
                }
                
                if requestData.count > 3 {
                    self.tblViewHeight.constant = 80*3
                }else if requestData.count == 0 {
                    self.tblViewHeight.constant = 80.0
                }else{
                    self.tblViewHeight.constant = CGFloat(80*requestData.count)
                }
                
               // self.tblView.reloadData()
                
                //approved user logic
                self.arrAppAccessId = []
                self.arrAppUserName = []
                self.btnSelectUser.setTitle("Select User", for: .normal)
                
                for i in 0..<approveData.count {
                    self.arrAppAccessId.append(approveData[i]["accessId"] as? String ?? "")
                    self.arrAppUserName.append(approveData[i]["userName"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblView.reloadData()
        };
    }

}

extension ApproveAccessSettingVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrReqName.count == 0 {
            return 1
        }
        return arrReqName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "Cell") as! ApproveRequestCell
        
        if self.arrReqName.count == 0 {
            cell.lblName.isHidden = true
            cell.lblDate.isHidden = true
            cell.imgView.isHidden = true
            cell.btnAccept.isHidden = true
            cell.btnReject.isHidden = true
            cell.lblAccessModule.isHidden = true
            cell.accessModuleView.isHidden = true
            cell.lblNoRequest.isHidden = false
        }else{
            cell.lblName.isHidden = false
            cell.lblDate.isHidden = false
            cell.imgView.isHidden = false
            cell.btnAccept.isHidden = false
            cell.btnReject.isHidden = false
            cell.lblAccessModule.isHidden = false
            cell.accessModuleView.isHidden = false
            cell.lblNoRequest.isHidden = true
            
            cell.lblName.text = self.arrReqName[indexPath.row]
            cell.lblDate.text = "Date : \(self.arrReqAccessDate[indexPath.row])"
            let pic = self.arrReqImg[indexPath.row]
            if pic != "" {
                cell.imgView.imageFromServerURL(urlString: pic)
            }else{
                cell.imgView.image = #imageLiteral(resourceName: "noImg")
            }
            
            let tempArr = self.arrReqModule[indexPath.row] as! [AnyObject]
            if tempArr.count > 0 {
                var x = 5.0
                for i in 0 ..< tempArr.count {
                    let index = "\(tempArr[i])"
                    if index != "3" {
                        let btn = UIButton()
                        btn.frame = CGRect(x: x, y: 5, width: 20, height: 20)
                        btn.setImage(accessImage[(Int(index)!)-1], for: .normal)
                        cell.accessModuleView.addSubview(btn)
                        x = x + 25
                    }
                }
            }
            
            cell.btnAccept.tag = indexPath.row
            cell.btnReject.tag = indexPath.row
            cell.btnAccept.addTarget(self, action: #selector(self.actionAcceptRequest(_:)), for: .touchUpInside)
            cell.btnReject.addTarget(self, action: #selector(actionRejectRequest(_:)), for: .touchUpInside)
        }
        return cell
    }
}

extension ApproveAccessSettingVC {
    
    @IBAction func actionClose (_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name("ReloadCFTDashboard"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSelectUser (_ sender:UIButton){
        if self.arrAppUserName.count > 0 {
            let alert = UIAlertController(title: "Select User", message: nil, preferredStyle: .actionSheet)
            for i in self.arrAppUserName {
                alert.addAction(UIAlertAction(title: i, style: .default, handler: setUser))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            self.present(alert, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "No approved users available yet.")
        }
    }
    
    func setUser(action: UIAlertAction) {
        
        self.btnSelectUser.setTitle(action.title, for: .normal)
        for i in 0..<self.arrAppUserName.count {
            if action.title == self.arrAppUserName[i] {
                self.selectedUser = self.arrAppAccessId[i]
            }
        }
    }
    
    @IBAction func actionRemoveAccess (_ sender:UIButton){
        
        if selectedUser == "" {
            OBJCOM.setAlert(_title: "", message: "Please select user")
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftUserId":selectedUser]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "removeAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionAcceptRequest (_ sender:UIButton){
        
        if self.arrReqAccessId.count == 0 {
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":self.arrReqAccessId[sender.tag]]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "aproveAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionRejectRequest (_ sender:UIButton){
        
        if self.arrReqAccessId.count == 0 {
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":self.arrReqAccessId[sender.tag]]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCommon(action: "rejectAccess", dictParam: dictParam)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func apiCallForCommon(action:String, dictParam:[String:String]){
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getRequestList()
                    
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
