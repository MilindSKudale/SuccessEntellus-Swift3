//
//  StartTextCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 27/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class StartTextCampaignVC: UIViewController {

    @IBOutlet weak var lblCampaignName : UILabel!
    @IBOutlet weak var lblCreatedDate : UILabel!
    @IBOutlet weak var tblList : UITableView!
    @IBOutlet weak var btnStartCampaign : UIButton!
    @IBOutlet weak var noRecView : UIView!
    
    var arrContactId = [String]()
    var arrContactEmail = [String]()
    var arrContactName = [String]()
    var arrCreatedDate = [String]()
    var arrSelectedMembers = [String]()
    
    var campaignId = ""
    var messageText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnStartCampaign.layer.cornerRadius = 5.0
        btnStartCampaign.clipsToBounds = true
        btnStartCampaign.isHidden = true
        noRecView.isHidden = true
        self.tblList.tableFooterView = UIView()
        
        arrSelectedMembers = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if campaignId == "" {
            return
        }
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnStartCampaign(sender: UIButton) {
        
        if self.arrSelectedMembers.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one record to start camapign.")
            return
        }else{
            let selectedIds = self.arrSelectedMembers.joined(separator: ",")
            let alertController = UIAlertController(title: "", message: "Are you sure you want to start current campaign for selected members?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Start", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.startCampaignAPICall(selectedIds:selectedIds)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                
            }
            alertController.addAction(okAction)
            alertController.addAction(CancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension StartTextCampaignVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrContactEmail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! StartTextCampCell
        cell.lblUsername.text = self.arrContactName[indexPath.row]
        cell.lblUserPhone.text = self.arrContactEmail[indexPath.row]
        
        if self.arrSelectedMembers.contains(self.arrContactId[indexPath.row]) {
            
            cell.imgSelectRecord.image = #imageLiteral(resourceName: "checkbox_ic")
        }else{
            cell.imgSelectRecord.image = #imageLiteral(resourceName: "uncheck")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = self.arrContactId[indexPath.row]
        if self.arrSelectedMembers.contains(selectedId) {
            let index = self.arrSelectedMembers.index(of : selectedId)
            self.arrSelectedMembers.remove(at: index!)
        }else{
            self.arrSelectedMembers.append(selectedId)
        }
        
        self.tblList.reloadData()
    }
}

extension StartTextCampaignVC {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAddedMemberToStartCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrContactId = []
                self.arrContactEmail = []
                self.arrContactName = []
                self.arrCreatedDate = []
                let result = JsonDict!["result"] as! [String : AnyObject]
                self.lblCampaignName.text = result["txtCampName"] as? String ?? ""
                self.lblCreatedDate.text = "Text Campaign Created On \(result["campaignDateTime"] as? String ?? "")"
                self.messageText = result["scheduleMessage"] as? String ?? ""
                let emailDetails = result["campaignEmails"] as! [AnyObject]
                if emailDetails.count > 0 {
                    for obj in emailDetails {
                        self.arrContactId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                        self.arrContactEmail.append(obj.value(forKey: "contact_phone") as! String)
                        self.arrContactName.append(obj.value(forKey: "contact_name") as! String)
                        
                        self.arrCreatedDate.append(obj.value(forKey: "email_addDate") as! String)
                    }
                    self.btnStartCampaign.isHidden = false
                    self.noRecView.isHidden = true
                }else{
                    self.btnStartCampaign.isHidden = true
                    self.noRecView.isHidden = false
                }
                OBJCOM.hideLoader()
            }else{
                self.arrContactId = []
                self.arrContactEmail = []
                self.arrContactName = []
                self.arrCreatedDate = []
                self.btnStartCampaign.isHidden = true
                self.noRecView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        };
    }
    
    func startCampaignAPICall(selectedIds:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":campaignId,
                         "txtcontactCampaignIds":selectedIds]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "startTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                let alertController = UIAlertController(title: "", message: result as? String, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        };
    }
}
