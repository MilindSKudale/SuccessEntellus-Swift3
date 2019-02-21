//
//  NewEmailSetTimeIntervalVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 04/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class NewEmailSetTimeIntervalVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var uiView : UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnImmediate: UIButton!
    @IBOutlet weak var btnSchedule: UIButton!
    @IBOutlet weak var btnReapeat: UIButton!
    @IBOutlet weak var btnIntervalType: UIButton!
    @IBOutlet weak var txtInterval: UITextField!
    
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var viewReapeat: UIView!
    @IBOutlet weak var viewScheduleHeight: NSLayoutConstraint!
    @IBOutlet weak var viewReapeatHeight: NSLayoutConstraint!
    @IBOutlet var btnDaysCollection: [UIButton]!
    
    @IBOutlet weak var txtRepeatWeek: UITextField!
    @IBOutlet weak var stepperRepeatOccurance: PKYStepper!
    
    var arrSelectedDays = [String]()
    var timeIntervalValue = "0"
    var timeIntervalType = "Select"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    
    var templateData = [String:Any]()
    var templateId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtRepeatWeek.text = "1"
        txtRepeatWeek.delegate = self
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.designUI()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdateTimeInterval(_ sender:UIButton){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.updateTimeIntervalAPICall()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionSetInterval(_ sender:UIButton){
        self.selectIntervalType()
    }
    
}

extension NewEmailSetTimeIntervalVC {
    
    func designUI(){
        OBJCOM.setStepperValues(stepper: stepperRepeatOccurance, min: 0, max: 100)
        self.setCornerRedius(uiView)
        self.setCornerRedius(btnCancel)
        self.setCornerRedius(btnUpdate)
        self.setCornerRedius(btnIntervalType)
        self.btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        self.btnIntervalType.layer.borderWidth = 0.5
        for btn in btnDaysCollection {
            btn.layer.borderColor = APPGRAYCOLOR.cgColor
            btn.layer.borderWidth = 0.5
            self.setCornerRedius(btn)
        }
        self.txtInterval.delegate = self
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "stepId":templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailTemplateById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                OBJCOM.hideLoader()
                
                self.timeIntervalValue = result["campaignStepSendInterval"] as? String ?? "0"
                self.timeIntervalType = result["campaignStepSendIntervalType"] as? String ?? "days"
                
                let reminderType = result["campaignStepRepeat"] as? String ?? "0"
                
                self.txtInterval.text = self.timeIntervalValue
                self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
                
                if reminderType == "1" {
                    self.btnImmediate.isSelected = false
                    self.btnSchedule.isSelected = false
                    self.btnReapeat.isSelected = true
                    self.isImmediate = "3"
                    self.view.layoutIfNeeded()
                    self.viewScheduleHeight.constant = 0.0
                    self.viewReapeatHeight.constant = 150.0
                    self.viewReapeat.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                    self.repeatWeeks = result["campRepeatWeeks"] as? String ?? "0"
                    self.repeatOn = result["campRepeatDays"] as? String ?? ""
                    self.repeatEnd = result["campRepeatEndOccurrence"] as? String ?? "0"
                    
                    self.txtRepeatWeek.text = self.repeatWeeks
                    self.stepperRepeatOccurance.countLabel.text = self.repeatEnd
                    
                    
                    let dayArray = self.repeatOn.components(separatedBy: ",")
                    for day in dayArray {
                        if day != "" {
                            self.arrSelectedDays.append(day)
                        }
                    }
                    
                    if self.arrSelectedDays.count > 0 {
                        for view in self.btnDaysCollection as [UIView] {
                            if let btn = view as? UIButton {
                                if self.arrSelectedDays.contains ((btn.titleLabel?.text)!){
                                    btn.backgroundColor = APPORANGECOLOR
                                    btn.setTitleColor(.white, for: .normal)
                                }else{
                                    btn.backgroundColor = .white
                                    btn.setTitleColor(.black, for: .normal)
                                }
                            }
                        }
                    }
                }else{
                    self.repeatWeeks = ""
                    self.repeatOn = ""
                    self.repeatEnd = ""
                    self.txtRepeatWeek.text = "1"
                    self.stepperRepeatOccurance.countLabel.text = "1"
                    
                    if self.timeIntervalValue == "0" {
                        self.btnImmediate.isSelected = true
                        self.btnSchedule.isSelected = false
                        self.btnReapeat.isSelected = false
                        self.isImmediate = "1"
                        self.view.layoutIfNeeded()
                        self.viewScheduleHeight.constant = 0.0
                        self.viewReapeatHeight.constant = 0.0
                        self.viewReapeat.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                    }else{
                        self.btnImmediate.isSelected = false
                        self.btnSchedule.isSelected = true
                        self.btnReapeat.isSelected = false
                        self.isImmediate = "2"
                        self.view.layoutIfNeeded()
                        self.viewScheduleHeight.constant = 50.0
                        self.viewReapeatHeight.constant = 0.0
                        self.viewReapeat.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                    }
                }
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
    
    func setCornerRedius(_ uiView:UIView){
        uiView.layer.cornerRadius = 5.0
        uiView.clipsToBounds = true
    }
    
}

extension NewEmailSetTimeIntervalVC {
    
    @IBAction func actionImmediate(_ sender : UIButton){
        btnImmediate.isSelected = true
        btnSchedule.isSelected = false
        btnReapeat.isSelected = false
        self.isImmediate = "1"
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSchedule(_ sender : UIButton){
        btnImmediate.isSelected = false
        btnSchedule.isSelected = true
        btnReapeat.isSelected = false
        self.isImmediate = "2"
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 50.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionRepeat(_ sender : UIButton){
        btnImmediate.isSelected = false
        btnSchedule.isSelected = false
        btnReapeat.isSelected = true
        self.isImmediate = "3"
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 150.0
        viewReapeat.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSetWeekDaysForRepeat(_ sender : UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case 1:
            if self.arrSelectedDays.contains("Sun") == false {
                self.arrSelectedDays.append("Sun")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sun")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 2:
            if self.arrSelectedDays.contains("Mon") == false {
                self.arrSelectedDays.append("Mon")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Mon")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 3:
            if self.arrSelectedDays.contains("Tue") == false {
                self.arrSelectedDays.append("Tue")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Tue")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 4:
            if self.arrSelectedDays.contains("Wed") == false {
                self.arrSelectedDays.append("Wed")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Wed")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
                
            }
            break
        case 5:
            if self.arrSelectedDays.contains("Thu") == false {
                self.arrSelectedDays.append("Thu")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Thu")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 6:
            if self.arrSelectedDays.contains("Fri") == false {
                self.arrSelectedDays.append("Fri")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Fri")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 7:
            if self.arrSelectedDays.contains("Sat") == false {
                self.arrSelectedDays.append("Sat")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sat")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        default:
            break
        }
        
        print(self.arrSelectedDays)
    }
    
    func selectIntervalType() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionDay = UIAlertAction(title: "Days", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "days"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionDay.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionWeek = UIAlertAction(title: "Weeks", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "week"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionWeek.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionMonth = UIAlertAction(title: "Months", style: .default)
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
    
    func updateTimeIntervalAPICall(){
        
        print(timeIntervalValue)
        if self.isImmediate == "3" {
            if self.txtRepeatWeek.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                OBJCOM.hideLoader()
                return
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                OBJCOM.hideLoader()
                return
            }
        }
        if self.isImmediate == "1" || self.isImmediate == "2" {
            self.repeatWeeks = ""
            self.repeatOn = ""
            self.repeatEnd = ""
        }else{
            if self.arrSelectedDays.count > 0 {
                self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            }
            self.repeatWeeks = txtRepeatWeek.text ?? "1"
            self.repeatEnd = self.stepperRepeatOccurance.countLabel.text ?? "1"
        }
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "campaignStepId":self.templateId,
                         "campaignStepSendInterval":self.timeIntervalValue,
                         "campaignStepSendIntervalType":self.timeIntervalType,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatWeek.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd] as [String : Any]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setTimeIntervalTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("ReloadTempData"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtInterval {
            if txtInterval.text == "" {
                self.timeIntervalValue = "0"
                self.timeIntervalType = "days"
                self.txtInterval.text = timeIntervalValue
                self.btnIntervalType.setTitle(timeIntervalType, for: .normal)
            }else{
                self.timeIntervalValue = txtInterval.text!
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtRepeatWeek {
            OBJCOM.setRepeateWeeks(txtRepeatWeek)
            return false
        }
        return true
    }
}


