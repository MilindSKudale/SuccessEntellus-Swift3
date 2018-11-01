//
//  SetSelfReminderVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class SetSelfReminderVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet var btnEmail : UIButton!
    @IBOutlet var btnSMSEmail : UIButton!
    @IBOutlet var btnClose : UIButton!
    @IBOutlet var btnSubmit : UIButton!
    @IBOutlet var btnIntervalType : UIButton!
    @IBOutlet var txtInterval : UITextField!
    @IBOutlet var txtNotes : UITextView!
    
    var timeIntervalValue = "0"
    var timeIntervalType = "Select"
    var reminderType = "1"
    var campaignId = ""
    var isUpdate = false
    let dict = [String:String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        btnClose.layer.cornerRadius = 5
        btnSubmit.layer.cornerRadius = 5
        setCornerBorder(btnIntervalType)
        setCornerBorder(txtNotes)
        setCornerBorder(txtInterval)
        
        if isUpdate == true {
            if reminderType == "1"{
                btnEmail.isSelected = true
                btnSMSEmail.isSelected = false
            }else{
                btnSMSEmail.isSelected = true
                btnEmail.isSelected = false
            }
            btnSubmit.setTitle("Update", for: .normal)
        }else{
            btnEmail.isSelected = true
            btnSubmit.setTitle("Add", for: .normal)
        }
        txtNotes.text = "This is a self-reminder for yourself. We'll send you with the status of prospects email."
        txtNotes.textColor = UIColor.lightGray
        txtInterval.text = timeIntervalValue
        btnIntervalType.setTitle(timeIntervalType, for: .normal)
    }
    
    func setCornerBorder(_ vw : UIView){
        vw.layer.cornerRadius = 5.0
        vw.layer.borderColor = APPGRAYCOLOR.cgColor
        vw.layer.borderWidth = 0.5
        vw.clipsToBounds = true
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnEmail(sender: UIButton) {
        btnEmail.isSelected = true
        btnSMSEmail.isSelected = false
        reminderType = "1"
    }
    
    @IBAction func actionBtnSMSEmail(sender: UIButton) {
        btnEmail.isSelected = false
        btnSMSEmail.isSelected = true
        reminderType = "2"
    }
    
    @IBAction func actionBtnIntervalType(sender: UIButton) {
        selectIntervalType()
    }
    
    @IBAction func actionBtnSubmit(sender: UIButton) {
        if timeIntervalType == "Select" {
            OBJCOM.setAlert(_title: "", message: "Please select interval type.")
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    if self.isUpdate == false{
                        self.setSelfReminderAPI(action:"addSelfEmailTemplate")
                    }else{
                    self.updateSelfReminderAPI(action:"updateSelfEmailTemplate")
                    }
                    
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func setSelfReminderAPI(action:String){
        if txtNotes.text == "This is a self-reminder for yourself. We'll send you with the status of prospects email." {
            txtNotes.text = ""
        }
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepCamId":campaignId,
                         "campaignStepSendTo":reminderType,
                         "campaignStepSendInterval":self.txtInterval.text!,
                         "campaignStepSendIntervalType":timeIntervalType,
                         "campaignStepContent":txtNotes.text!]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateSelfReminderAPI(action:String){
        if txtNotes.text == "This is a self-reminder for yourself. We'll send you with the status of prospects email." {
            txtNotes.text = ""
        }
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepId":campaignId,
                         "campaignStepSendTo":reminderType,
                         "campaignStepSendInterval":txtInterval.text!,
                         "campaignStepSendIntervalType":timeIntervalType,
                         "campaignStepContent":txtNotes.text!]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                     NotificationCenter.default.post(name: Notification.Name("UpdateSelfReminder"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension SetSelfReminderVC {
    func selectIntervalType() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionDay = UIAlertAction(title: "days", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "days"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionDay.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionWeek = UIAlertAction(title: "weeks", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "week"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionWeek.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionMonth = UIAlertAction(title: "months", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "month"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionMonth.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Dismiss", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionDay)
        alert.addAction(actionWeek)
        alert.addAction(actionMonth)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtInterval {
            if txtInterval.text == "" {
                self.timeIntervalValue = "0"
                self.timeIntervalType = "Select"
                self.txtInterval.text = timeIntervalValue
                self.btnIntervalType.setTitle(timeIntervalType, for: .normal)
            }else{
                self.timeIntervalValue = txtInterval.text ?? "0"
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtNotes.textColor == UIColor.lightGray {
            txtNotes.text = nil
            txtNotes.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtNotes.text.isEmpty {
            txtNotes.text = "This is self reminder for yourself. We will send you with prospects."
            txtNotes.textColor = UIColor.lightGray
        }
    }
}

