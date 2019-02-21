//
//  EditCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EditCampaignVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtCampaignName : UITextField!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var btnClose : UIButton!
    
    var campaignName = ""
    var campaignId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdate.layer.cornerRadius = 5.0
        btnUpdate.clipsToBounds = true
        btnClose.layer.cornerRadius = 5.0
        btnClose.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtCampaignName.text = campaignName
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnUpdate(sender: UIButton) {
        
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name to update campaign")
        }else{
            //updateCampaign
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.updateCampaign()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func updateCampaign(){
       
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId,
                         "campaignTitle":txtCampaignName.text,
                         "campaignContent":""] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NotificationCenter.default.post(name: Notification.Name("AddTemplate"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCampaignName {
            if txtCampaignName.text == "" {
                self.txtCampaignName.text = self.campaignName
            }else{
                self.campaignName = txtCampaignName.text ?? ""
            }
        }
    }
}
