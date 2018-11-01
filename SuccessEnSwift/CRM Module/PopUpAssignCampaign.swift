//
//  PopUpAssignCampaign.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PopUpAssignCampaign: UIViewController {
    
    @IBOutlet var DDSelectCampaign : UIDropDown!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnAssign : UIButton!
    @IBOutlet var tblAssignedCamp : UITableView!
    @IBOutlet var noRecordView : UIView!
    
    var arrCampaignTitle = [String]()
    var arrCampaignId = [AnyObject]()
    var arrUnAssignCampaignTitle = [String]()
    var arrUnAssignCampaignId = [AnyObject]()
    var campaignTitle = ""
    var campaignId = ""
    var contactId = ""
    var isGroup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAssign.layer.cornerRadius = 5.0
        btnCancel.layer.cornerRadius = 5.0
        btnAssign.clipsToBounds = true
        btnCancel.clipsToBounds = true
        
        noRecordView.isHidden = true
        tblAssignedCamp.tableFooterView = UIView()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func loadDropDown() {
        self.DDSelectCampaign.textColor = .black
        self.DDSelectCampaign.tint = .black
        self.DDSelectCampaign.optionsSize = 15.0
        self.DDSelectCampaign.placeholder = " Select email campaign"
        self.DDSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.DDSelectCampaign.textAlignment = NSTextAlignment.left
        self.DDSelectCampaign.options = self.arrCampaignTitle
        campaignTitle = " Select email campaign"
        self.DDSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignId[index] as! String
        }
    }
    
    @IBAction func actionCancel(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender : UIButton){
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            AssignCampaign()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func actionUnAssignCampaign(_ sender : UIButton){
        let assignId = arrUnAssignCampaignId[sender.tag]
        let alertController = UIAlertController(title: "", message: "Do you want to unassign selected campaign", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Un-Assign", style: UIAlertActionStyle.default) {
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

}

extension PopUpAssignCampaign : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUnAssignCampaignTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAssignedCamp.dequeueReusableCell(withIdentifier: "Cell") as! AssignCampaignCell
        
        cell.lblCampaignName.text = self.arrUnAssignCampaignTitle[indexPath.row]
        cell.btnUnAssignCampaign.tag = indexPath.row
        cell.btnUnAssignCampaign.addTarget(self, action: #selector(actionUnAssignCampaign(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
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
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                for obj in campData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as AnyObject)
                }
                
                if unAssignCampData.count == 0 {
                    self.noRecordView.isHidden = false
                }else{
                    self.noRecordView.isHidden = true
                    self.arrUnAssignCampaignId = []
                    self.arrUnAssignCampaignTitle = []
                    for obj in unAssignCampData {
                        self.arrUnAssignCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                        self.arrUnAssignCampaignId.append(obj.value(forKey: "contactCampaignId") as AnyObject)
                    }
                }
               
                
                OBJCOM.hideLoader()
                self.loadDropDown()
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
    
    func AssignCampaign() {
        if campaignTitle != " Select email campaign" {
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
            OBJCOM.setAlert(_title: "", message: "Please select email campaign to assign.")
        }
        
    }
}
