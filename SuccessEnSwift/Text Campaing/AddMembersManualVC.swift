//
//  AddMembersManualVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddMembersManualVC: UIViewController {
    
    @IBOutlet var txtFirstName : SkyFloatingLabelTextField!
    @IBOutlet var txtLastName : SkyFloatingLabelTextField!
  //  @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtMobile : SkyFloatingLabelTextField!
    @IBOutlet var btnAssign : UIButton!
    @IBOutlet var btnCancel : UIButton!
    var CampaignId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        btnAssign.layer.cornerRadius = 5.0
        btnAssign.clipsToBounds = true
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAssign(_ sender:UIButton){
        if Validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForAddMemberManually()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func apiCallForAddMemberManually(){
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtcontactMainCampaignId":self.CampaignId,
                         "fname":self.txtFirstName.text!,
                         "lname":self.txtLastName.text!,
                         "email": "",
                         "phone":self.txtMobile.text!] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addMemberManually", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("UpdateTextCampaignVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    func Validate() -> Bool {
        if txtFirstName.text == "" && txtLastName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            OBJCOM.hideLoader()
            return false
        }else if txtMobile.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter phone number.")
            OBJCOM.hideLoader()
            return false
        }else if txtMobile.text != "" {
            if txtMobile.text!.length < 5 || txtMobile.text!.length > 19 {
                OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits and less than or equal to 19 digits.")
                OBJCOM.hideLoader()
                return false
            }
        }
        return true
    }
}
