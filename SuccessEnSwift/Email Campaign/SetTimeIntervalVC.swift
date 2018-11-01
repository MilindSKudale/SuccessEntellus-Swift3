//
//  SetReminderVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 23/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class SetTimeIntervalVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var btnIntervalType: UIButton!
    @IBOutlet var txtInterval: UITextField!
    var timeIntervalValue = "0"
    var timeIntervalType = "Select"
    var templateId = ""
    var isEditInterval = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI() {
        btnIntervalType.layer.cornerRadius = 5.0
        btnIntervalType.clipsToBounds = true
        btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        btnIntervalType.layer.borderWidth = 0.5
        
        if isEditInterval == false {
            timeIntervalValue = "0"
            timeIntervalType = "Select"
        }
        txtInterval.text = timeIntervalValue
        btnIntervalType.setTitle(timeIntervalType, for: .normal)
    }
    

    @IBAction func actionSetInterval(_ sender : UIButton){
        
        if timeIntervalType == "Select" {
            OBJCOM.setAlert(_title: "", message: "Please set time interval type.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.setTimeIntervalAPI()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionClose(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setTimeIntervalAPI(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepId":templateId,
                         "campaignStepSendInterval":timeIntervalValue,
                         "campaignStepSendIntervalType":timeIntervalType]

        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        print(dictParamTemp)
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setTimeIntervalReminder", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                 OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NotificationCenter.default.post(name: Notification.Name("ReloadTempData"), object: nil)
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

extension SetTimeIntervalVC {
    @IBAction func actionSetIntervalType(_ sender : UIButton){
        selectIntervalType()
    }
    
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
}
