//
//  EditTextCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EditTextCampaignVC: UIViewController {

    @IBOutlet var txtCampaignName : SkyFloatingLabelTextField!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var btnCancel : UIButton!
    
    var txtCampId = ""
    var textCampaignTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.layer.cornerRadius = 5.0
        btnSave.clipsToBounds = true
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        self.txtCampaignName.text = textCampaignTitle
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdateCampaign(_ sender:UIButton){
        OBJCOM.setLoader()
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name to add new text campaign.")
            OBJCOM.hideLoader()
            return
        }
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtCampId":txtCampId,
                         "campaignTitle":txtCampaignName.text!,
                         "txtCampDescription":""] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
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
}

