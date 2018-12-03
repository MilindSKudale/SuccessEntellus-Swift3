//
//  AssignECforMultipleCrm.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 19/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AssignECforMultipleCrm: UIViewController {
    
    @IBOutlet var uiView : UIView!
    @IBOutlet var ddSelectCampaign : UIDropDown!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnAssignCamp : UIButton!
    var arrCampaignTitle = [String]()
    var arrCampaignID = [String]()
    
    var campaignId = ""
    var contactsId = ""
    var campaignTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getEmailCampaignList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    func designUI(){
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        
        btnAssignCamp.layer.cornerRadius = btnAssignCamp.frame.height/2
        btnAssignCamp.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.height/2
        btnCancel.clipsToBounds = true
    }
    
    @IBAction func actionCancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender:UIButton){
        if campaignTitle == " Select Email Campaign" {
            OBJCOM.setAlert(_title: "", message: "Please select email campaign.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.assignEmailCampaignToMultipleRecords()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            
        }
    }

}

extension AssignECforMultipleCrm {
    func getEmailCampaignList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignID.append(obj.value(forKey: "campaignId") as! String)
                }
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func loadDropDown() {
        self.ddSelectCampaign.textColor = .black
        self.ddSelectCampaign.tint = .black
        self.ddSelectCampaign.optionsSize = 15.0
        self.ddSelectCampaign.placeholder = " Select Email Campaign"
        self.ddSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.ddSelectCampaign.textAlignment = NSTextAlignment.left
        self.ddSelectCampaign.options = self.arrCampaignTitle
        campaignTitle = " Select Email Campaign"
        self.ddSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignID[index]
        }
    }
    
    func assignEmailCampaignToMultipleRecords(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":self.campaignId,
                         "contactIds":self.contactsId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "assignMultipleCampaignCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let result = JsonDict!["result"] as? String ?? ""
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as? String ?? ""
                print("result:",JsonDict ?? "")
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}
