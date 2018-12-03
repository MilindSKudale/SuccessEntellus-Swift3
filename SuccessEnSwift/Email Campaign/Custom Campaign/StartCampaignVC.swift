//
//  StartCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 20/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class StartCampaignVC: UIViewController {
    
    @IBOutlet weak var lblCampaignName : UILabel!
    @IBOutlet weak var lblCreatedDate : UILabel!
    @IBOutlet weak var tblList : UITableView!
    @IBOutlet weak var btnStartCampaign : UIButton!
    @IBOutlet weak var noRecView : UIView!
    
    var arrContactId = [String]()
    var arrContactEmail = [String]()
    var arrContactName = [String]()
    var arrCreatedDate = [String]()
    
    var campaignId = ""
    var messageText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        btnStartCampaign.layer.cornerRadius = 5.0
        btnStartCampaign.clipsToBounds = true
        btnStartCampaign.isHidden = true
        noRecView.isHidden = true
        self.tblList.tableFooterView = UIView()
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
        let alertController = UIAlertController(title: "", message: "Email will be sent '\(self.messageText)'. Do you want to proceed?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Proceed", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.startCampaignAPICall()
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

extension StartCampaignVC {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAddedEmailToStartCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrContactId = []
                self.arrContactEmail = []
                self.arrContactName = []
                self.arrCreatedDate = []
                let result = JsonDict!["result"] as! [String : AnyObject]
                self.lblCampaignName.text = result["campaignTitle"] as? String ?? ""
                self.lblCreatedDate.text = "Email Campaign Created On \(result["campaignDateTime"] as? String ?? "")"
                self.messageText = result["scheduleMessage"] as? String ?? ""
                let emailDetails = result["campaignEmails"] as! [AnyObject]
                if emailDetails.count > 0 {
                    for obj in emailDetails {
                        self.arrContactId.append(obj.value(forKey: "contactCampaignId") as! String)
                        self.arrContactEmail.append(obj.value(forKey: "contact_email") as! String)
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
    
    func startCampaignAPICall(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "startEmailCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
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

extension StartCampaignVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContactEmail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! StartCampaignCell
        cell.lblUsername.text = self.arrContactName[indexPath.row]
        cell.lblUserEmail.text = self.arrContactEmail[indexPath.row]
        cell.lblCreatedDate.text = "Created on \(self.arrCreatedDate[indexPath.row])"
        
        return cell
    }
}
