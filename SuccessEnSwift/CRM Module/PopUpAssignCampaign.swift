//
//  PopUpAssignCampaign.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PopUpAssignCampaign: UIViewController {
    
    @IBOutlet var lblTitle : UILabel!
  //  @IBOutlet var DDSelectCampaign : UIDropDown!
    @IBOutlet var btnSelectCampaign : UIButton!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnAssign : UIButton!
    @IBOutlet var lblContactName : UILabel!
    @IBOutlet var tblAssignedCamp : UITableView!
    @IBOutlet var bgView : UIView!

    var arrCampaignTitle = [String]()
    var arrCampaignId = [AnyObject]()
    var arrAvailCampaign = [String]()
    var arrUnAssignCampaignTitle = [String]()
    var arrUnAssignCampaignId = [AnyObject]()
    var arrAddedCampaignTitle = [String]()
    var arrAddedCampaignId = [AnyObject]()
    var campaignTitle = ""
    var campaignId = ""
    var contactId = ""
    var contactName = ""
    var isGroup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAssign.layer.cornerRadius = 5.0
        btnCancel.layer.cornerRadius = 5.0
        btnAssign.clipsToBounds = true
        btnCancel.clipsToBounds = true
        
        btnSelectCampaign.layer.cornerRadius = 5.0
        btnSelectCampaign.layer.borderColor = APPGRAYCOLOR.cgColor
        btnSelectCampaign.layer.borderWidth = 0.5
        btnSelectCampaign.clipsToBounds = true
        campaignTitle = ""
        btnSelectCampaign.setTitle("Select Email Campaign", for: .normal)
        
        tblAssignedCamp.tableFooterView = UIView()
      
        if isGroup == true {
            lblTitle.text = "Add group to 'Email Campaigns'"
        }else{
            lblTitle.text = "Add email to 'Email Campaigns'"
        }
        
        lblContactName.text = contactName
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
//    func loadDropDown() {
//        self.DDSelectCampaign.textColor = .black
//        self.DDSelectCampaign.tint = .black
//        self.DDSelectCampaign.optionsSize = 15.0
//        self.DDSelectCampaign.placeholder = " Select email campaign"
//        self.DDSelectCampaign.optionsTextAlignment = NSTextAlignment.left
//        self.DDSelectCampaign.textAlignment = NSTextAlignment.left
//        self.DDSelectCampaign.options = self.arrCampaignTitle
//        self.DDSelectCampaign.availCamp = self.arrAvailCampaign
//        self.DDSelectCampaign.uiView.backgroundColor = self.bgView.backgroundColor
////        for i in 0..<arrAvailCampaign.count{
////            if "\(arrAvailCampaign[i])"  == "0" {
////                self.DDSelectCampaign.campaigns = "0"
////            }else{
////                self.DDSelectCampaign.campaigns = "1"
////            }
////        }
//
//        campaignTitle = " Select email campaign"
//        self.DDSelectCampaign.didSelect { (item, index) in
//            self.campaignTitle = self.arrCampaignTitle[index]
//            self.campaignId = self.arrCampaignId[index] as! String
//        }
//    }
    
    @IBAction func actionCancel(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender : UIButton){
        if campaignTitle != "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getEmailScheduleMessage()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.hideLoader()
            OBJCOM.setAlert(_title: "", message: "Please select email campaign to assign.")
        }
    }
    
    @objc func actionUnAssignCampaign(_ sender : UIButton){
        let assignId = arrUnAssignCampaignId[sender.tag]
        let alertController = UIAlertController(title: "", message: "Do you want to unassign selected campaign", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Unassign", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.UnAssignCampaign(assignId:assignId as! String)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func actionDeleteCampaign(_ sender : UIButton){
        let assignId = self.arrAddedCampaignId[sender.tag]
        let alertController = UIAlertController(title: "", message: "Do you want to delete selected campaign", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.removeCampaign(assignId: assignId as! String)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func actionSelectCampaign(_ sender : UIButton){
        if self.arrCampaignTitle.count > 0 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            for i in 0..<self.arrCampaignTitle.count{
                alert.addAction(UIAlertAction(title: self.arrCampaignTitle[i], style: .default , handler:{ (UIAlertAction)in
                    self.campaignTitle = self.arrCampaignTitle[i]
                    self.campaignId = "\(self.arrCampaignId[i])"
                    self.btnSelectCampaign.setTitle(self.campaignTitle, for: .normal)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension PopUpAssignCampaign : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            if arrUnAssignCampaignTitle.count == 0 {
                return 1
            }else{
                return arrUnAssignCampaignTitle.count
            }
//        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblAssignedCamp.dequeueReusableCell(withIdentifier: "Cell") as! AssignCampaignCell
    
            if arrUnAssignCampaignTitle.count == 0 {
                cell.lblCampaignName.text = "No email campaign(s) assigned yet!"
                cell.lblCampaignName.textColor = .red
                cell.btnUnAssignCampaign.isHidden = true
            }else{
                cell.btnUnAssignCampaign.isHidden = false
                cell.lblCampaignName.textColor = .black
                cell.lblCampaignName.text = self.arrUnAssignCampaignTitle[indexPath.row]
                cell.btnUnAssignCampaign.setImage(UIImage(named: "ic_btnUnassign"), for: .normal)
                cell.btnUnAssignCampaign.tag = indexPath.row
                cell.btnUnAssignCampaign.addTarget(self, action: #selector(actionUnAssignCampaign(_:)), for: .touchUpInside)
            }
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.groupTableViewBackground
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
//        if section == 0 {
//            label.text = "List of Added Email Campaign(s)"
//        }else{
            label.text = "List of Assigned Email Campaign(s)"
//        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension PopUpAssignCampaign {
    func getDataFromServer() {
        var dictParam = [String:String]()
        
        if isGroup == true {
            dictParam = ["userId": userID,
                         "platform":"3",
                         "groupId":contactId]
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactId":contactId]
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmAssignUnassignCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                let campData = result["assingCamp"] as! [AnyObject]
                let unAssignCampData = result["unAssingCamp"] as! [AnyObject]
                //let addedCampData = result["addedCamp"] as! [AnyObject]
                
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                self.arrAvailCampaign = []
                
                for obj in campData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as AnyObject)
                    self.arrAvailCampaign.append("\(obj.value(forKey: "campaignTemplateExits") ?? "1")")
                }
                self.arrUnAssignCampaignId = []
                self.arrUnAssignCampaignTitle = []
                for obj in unAssignCampData {
                    self.arrUnAssignCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrUnAssignCampaignId.append(obj.value(forKey: "contactCampaignId") as AnyObject)
                }
                
//                self.arrAddedCampaignId = []
//                self.arrAddedCampaignTitle = []
//                for obj in addedCampData {
//                    self.arrAddedCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
//                    self.arrAddedCampaignId.append(obj.value(forKey: "contactCampaignId") as AnyObject)
//                }
                
                OBJCOM.hideLoader()
               // self.loadDropDown()
                self.tblAssignedCamp.reloadData()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func UnAssignCampaign(assignId : String) {
        var dictParam  = [String:String]()
        if isGroup == true {
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId,
                         "fromGroup" : "1"]
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId]
        }
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "unAssignCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.getDataFromServer()
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
    
    func removeCampaign(assignId : String) {
        var dictParam  = [String:String]()
        if isGroup == true {
            return
        }else{
            dictParam = ["userId": userID,
                         "platform":"3",
                         "contactCampaignId":assignId]
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.getDataFromServer()
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
    
    func AssignCampaign() {

        if campaignTitle != "" {
            var dictParam = [String:String]()
            if isGroup == true {
                dictParam = ["userId": userID,
                             "platform":"3",
                             "groupId":contactId,
                             "campaignId":campaignId]
            }else{
                dictParam = ["userId": userID,
                             "platform":"3",
                             "contactId":contactId,
                             "campaignId":campaignId]
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "assignCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as! String
                    print(result)
                    let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.getDataFromServer()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    OBJCOM.hideLoader()
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
            
        }else{
            OBJCOM.hideLoader()
            OBJCOM.setAlert(_title: "", message: "Please select email campaign to assign.")
        }
        
    }
    
    func getEmailScheduleMessage() {
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailScheduleMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Proceed", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.AssignCampaign()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                }
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}
