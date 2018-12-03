//
//  EditNoteDetailsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EditNoteDetailsVC: UIViewController {

    @IBOutlet weak var viewNote : UIView!
    @IBOutlet weak var txtTitle : UITextField!
    @IBOutlet weak var txtViewNote : GrowingTextView!
    @IBOutlet weak var viewNoteOptions : UIView!
    @IBOutlet weak var btnAddNote : UIButton!
    
    @IBOutlet weak var btnSetDate : UIButton!
    @IBOutlet weak var btnSetTime : UIButton!
    @IBOutlet weak var btnSetColor : UIButton!
    
    @IBOutlet var stackBtn : UIStackView!
    @IBOutlet var stackBtnR : UIButton!
    @IBOutlet var stackBtnB : UIButton!
    @IBOutlet var stackBtnG : UIButton!
    @IBOutlet var stackBtnV : UIButton!
    @IBOutlet var stackBtnO : UIButton!
    // @IBOutlet var stackBtnBlack : UIButton!
    @IBOutlet var stackBtnWhite : UIButton!
    
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBOutlet weak var viewRepeat : UIView!
    @IBOutlet weak var viewRepeatHeight : NSLayoutConstraint!
    @IBOutlet weak var btnDaily : UIButton!
    @IBOutlet weak var btnWeekly : UIButton!
    @IBOutlet weak var viewDaily : UIView!
    @IBOutlet weak var viewWeekly : UIView!
    
    @IBOutlet var btnEndsOn : UIButton!
    @IBOutlet var weekBtnSun : UIButton!
    @IBOutlet var weekBtnMon : UIButton!
    @IBOutlet var weekBtnTue : UIButton!
    @IBOutlet var weekBtnWed : UIButton!
    @IBOutlet var weekBtnThu : UIButton!
    @IBOutlet var weekBtnFri : UIButton!
    @IBOutlet var weekBtnSat : UIButton!
    @IBOutlet var txtWeeks : UITextField!
    
    var arrSelectedWeekDays = [String]()
    var repeatFlag = "0"
    var repeatEndDate = ""
    var repeatNoOfWeeks = ""
    var repeatWeekDays = ""
    var minDateRepeat = Date()
    
    var setDate = ""
    var setTime = ""
    var setColor = ""
    var arrStackBtn = [UIButton]()
    var noteId = ""
    var isView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if noteId == "" {
            return
        }
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getScratchnoteById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
    
        btnAddNote.layer.cornerRadius = btnAddNote.frame.height/2
        btnAddNote.clipsToBounds = true
        
        txtViewNote.minHeight = self.view.frame.height - 280
        
        arrStackBtn = [stackBtnR, stackBtnB, stackBtnG, stackBtnO, stackBtnV, stackBtnWhite]
        for i in 0 ..< arrStackBtn.count {
            arrStackBtn[i].backgroundColor = arrNotesColor[i]
            arrStackBtn[i].layer.cornerRadius = arrStackBtn[i].frame.height/2
            arrStackBtn[i].layer.borderColor = UIColor.lightGray.cgColor
            arrStackBtn[i].layer.borderWidth = 0.3
            arrStackBtn[i].clipsToBounds = true
        }
        
        let dt = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        setDate = formatter.string(from: dt)
        self.repeatEndDate = formatter.string(from: dt)
        formatter.dateFormat = "hh:mm a"
        setTime = formatter.string(from: dt)
        
        let arrWeekDays = [weekBtnSun, weekBtnMon, weekBtnTue, weekBtnWed, weekBtnThu, weekBtnFri, weekBtnSat]
        for i in 0 ..< arrWeekDays.count {
            self.setBtnBorder(arrWeekDays[i]!)
        }
        
        self.setBtnBorder(self.btnEndsOn)
        self.setBtnBorder(self.btnSetDate)
        self.setBtnBorder(self.btnSetTime)
        self.setBtnBorder(self.viewNote)
        
        
    }
    
    @IBAction func actionSetDate(_ sender:UIButton){
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        var dt = format.date(from: "\(self.setDate) \(self.setTime)")
//        if dt?.isSmallerThan(Date()) == true {
//            dt = Date()
//        }
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setDate = formatter.string(from: dt)
                self.repeatEndDate = formatter.string(from: dt)
                self.minDateRepeat = dt
                
                
                self.btnEndsOn.setTitle(self.repeatEndDate, for: .normal)
            }
        }
    }
    
    @IBAction func actionSetTime(_ sender:UIButton){
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let dt = format.date(from: "\(self.setDate) \(self.setTime)")
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .time) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm:ss a"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setTime = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func actionSetColorRed(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "pink"
    }
    
    @IBAction func actionSetColorBlue(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "blue"
    }
    
    @IBAction func actionSetColorGreen(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "green"
    }
    
    @IBAction func actionSetColorOrange(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "orange"
    }
    
    @IBAction func actionSetColorViolet(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "violet"
    }
    
    @IBAction func actionSetColorDefault(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "white"
    }
    
    func updateButton(_ sender: UIButton){
        arrStackBtn.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdateNote(_ sender:UIButton){
        if txtViewNote.text != "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                actionUpdateNoteAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Please write contents in note.")
        }
    }
}

extension EditNoteDetailsVC {
  
    func assignDataToFields(_ data: AnyObject){
        let str = data["scratchNoteText"] as? String ?? ""
        txtViewNote.text = str.htmlToString
        let dtStr = data["scratchNoteReminderDate"] as? String ?? "0000-00-00 00:00"
        let arrDateTime = dtStr.components(separatedBy: " ")
        setDate = arrDateTime[0]
        setTime = arrDateTime[1]
        self.btnSetDate.setTitle(setDate, for: .normal)
        self.btnSetTime.setTitle(setTime, for: .normal)
        self.setColor = data["scratchNoteColor"] as? String ?? ""
        self.selectColor(self.setColor)
        
        let endDtStr = data["scratchNoteReminderDailyEndDate"] as? String ?? "0000-00-00 00:00:00"
        let arrRepeatEndDate = endDtStr.components(separatedBy: " ")
        if endDtStr == "0000-00-00 00:00:00" {
            let dt = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.btnEndsOn.setTitle(formatter.string(from: dt), for: .normal)
            self.repeatEndDate = formatter.string(from: dt)
        }else{
            self.btnEndsOn.setTitle(arrRepeatEndDate[0], for: .normal)
            self.repeatEndDate = arrRepeatEndDate[0]
        }
      
        self.repeatFlag = data["scratchNoteReminderRepeat"] as? String ?? "0"
        if self.repeatFlag == "0" {
            self.repeatSwitch.isOn = false
            self.viewRepeatHeight.constant = 0
            self.viewRepeat.isHidden = true
           // self.repeatEndDate = ""
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "1" {
            self.repeatSwitch.isOn = true
            self.viewRepeatHeight.constant = 130.0
            self.viewRepeat.isHidden = false
            self.btnDaily.isSelected = true
            self.btnWeekly.isSelected = false
            self.viewDaily.isHidden = false
            self.viewWeekly.isHidden = true
        
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "2" {
            self.repeatSwitch.isOn = true
            self.viewRepeatHeight.constant = 130.0
            self.viewRepeat.isHidden = false
            self.btnDaily.isSelected = false
            self.btnWeekly.isSelected = true
            self.viewDaily.isHidden = true
            self.viewWeekly.isHidden = false

           // self.repeatEndDate = ""
            self.repeatNoOfWeeks = data["scratchNoteReminderWeeklyEnds"] as? String ?? "1"
            self.txtWeeks.text = self.repeatNoOfWeeks
        
            self.repeatWeekDays = data["scratchNoteReminderWeeklyDays"] as? String ?? ""
            
            let arrWeekDays = [weekBtnSun, weekBtnMon, weekBtnTue, weekBtnWed, weekBtnThu, weekBtnFri, weekBtnSat]
            let arrDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            self.arrSelectedWeekDays = []
            if self.repeatWeekDays != "" {
                let arrSelectedDays = self.repeatWeekDays.components (separatedBy: ",")
                
                for i in 0 ..< arrDays.count {
                    if arrSelectedDays.contains(arrDays[i]){
                        arrWeekDays[i]?.isSelected = true
                        self.arrSelectedWeekDays.append(arrDays[i])
                    }else{
                        arrWeekDays[i]?.isSelected = false
                    }
                }
            }else{
                for i in 0 ..< arrWeekDays.count {
                    arrWeekDays[i]?.isSelected = false
                }
            }
        }
    }
    
    func getScratchnoteById(){

        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.assignDataToFields(result)
                OBJCOM.hideLoader()
            }else{
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func actionUpdateNoteAPI(){
        
        if self.repeatFlag == "0" {
            self.repeatEndDate = ""
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "1" {
            self.repeatNoOfWeeks = ""
            self.repeatWeekDays = ""
        }else if self.repeatFlag == "2" {
            self.repeatEndDate = ""
            if self.txtWeeks.text == "" || self.txtWeeks.text == "0" {
                OBJCOM.setAlert(_title: "", message: "Please set week count greater than 0.")
                self.txtWeeks.text = "1"
                OBJCOM.hideLoader()
                return
            }else{
                self.repeatNoOfWeeks = self.txtWeeks.text ?? "1"
            }
            
            if self.arrSelectedWeekDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select atleast one  week day for set reminder.")
                OBJCOM.hideLoader()
                return
            }else{
                self.repeatWeekDays = self.arrSelectedWeekDays.joined(separator: ",")
            }
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId,
                         "scratchNoteText":String(txtViewNote.text),
                         "scratchNoteColor":setColor,
                         "scratchNoteReminderDate":setDate,
                         "scratchNoteReminderTime":setTime,
                         "scratchNoteReminderRepeat":self.repeatFlag,
                         "scratchNoteReminderWeeklyDays":self.repeatWeekDays,
                         "scratchNoteReminderWeeklyEnds":self.repeatNoOfWeeks,
                         "scratchNoteReminderDailyEndDate":self.repeatEndDate] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "editScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                print(result)
                let alert = UIAlertController(title: nil, message: "\(result)", preferredStyle: .alert)
                
                let actionOk = UIAlertAction(title: "OK", style: .default)
                {
                    UIAlertAction in
                    if self.isView == true {
                        NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList1"), object: nil)
                        self.presentingViewController?.presentingViewController?.dismiss (animated: true, completion: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                actionOk.setValue(UIColor.black, forKey: "titleTextColor")
                alert.addAction(actionOk)
                self.present(alert, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                OBJCOM.setAlert(_title: "", message: "Something went wrong..")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func getColor(_ color:String) -> UIColor {
        
        if color == "blue" {
            return UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0)
        }else if color == "pink" {
            return UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0)
        }else if color == "green" {
            return UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0)
        }else if color == "orange" {
            return UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0)
        }else if color == "violet" {
            return UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0)
        }else if color == "white"{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }else{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }
    }
    
    func selectColor(_ color:String){
        if color == "blue" {
            updateButton(arrStackBtn[1])
        }else if color == "pink" {
            updateButton(arrStackBtn[0])
        }else if color == "green" {
            updateButton(arrStackBtn[2])
        }else if color == "orange" {
            updateButton(arrStackBtn[3])
        }else if color == "violet" {
            updateButton(arrStackBtn[4])
        }else if color == "white"{
            updateButton(arrStackBtn[5])
        }else{
            updateButton(arrStackBtn[5])
        }
    }
    
}

extension EditNoteDetailsVC {
    
    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        if repeatSwitch.isOn == true {
            self.viewRepeat.isHidden = false
            self.viewRepeatHeight.constant = 130.0
            self.repeatFlag = "1"
            self.btnDaily.isSelected = true
            self.btnWeekly.isSelected = false
            self.viewDaily.isHidden = false
            self.viewWeekly.isHidden = true
        } else {
            self.viewRepeat.isHidden = true
            self.viewRepeatHeight.constant = 0.0
            self.repeatFlag = "0"
        }
    }
    
    @IBAction func actionSetReminderDaily(_ sender:UIButton){
        self.btnDaily.isSelected = true
        self.btnWeekly.isSelected = false
        self.viewDaily.isHidden = false
        self.viewWeekly.isHidden = true
        self.repeatFlag = "1"
    }
    
    @IBAction func actionSetReminderWeekly(_ sender:UIButton){
        self.btnDaily.isSelected = false
        self.btnWeekly.isSelected = true
        self.viewDaily.isHidden = true
        self.viewWeekly.isHidden = false
        self.repeatFlag = "2"
    }
    
    @IBAction func actionSetEndDateForDailyReminder(_ sender:UIButton){
        DatePickerDialog().show("Reminder ends on", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: self.minDateRepeat, maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                
                if self.minDateRepeat > dt {
                    OBJCOM.setAlert(_title: "", message: "Please select end date greater than reminder date.")
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    sender.setTitle(formatter.string(from: self.minDateRepeat), for: .normal)
                    self.repeatEndDate = formatter.string(from: self.minDateRepeat)
                }else{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    sender.setTitle(formatter.string(from: dt), for: .normal)
                    self.repeatEndDate = formatter.string(from: dt)
                }
            }
        }
    }
    
    @IBAction func actionBtnSunday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Sun") {
            if let index = self.arrSelectedWeekDays.index(of: "Sun") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Sun")
        }
    }
    @IBAction func actionBtnMonday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Mon") {
            if let index = self.arrSelectedWeekDays.index(of: "Mon"){
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Mon")
        }
    }
    @IBAction func actionBtnTuesday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Tue") {
            if let index = self.arrSelectedWeekDays.index(of: "Tue") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Tue")
        }
    }
    @IBAction func actionBtnWedensday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Wed") {
            if let index = self.arrSelectedWeekDays.index(of: "Wed") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Wed")
        }
    }
    @IBAction func actionBtnThursday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Thu") {
            if let index = self.arrSelectedWeekDays.index(of: "Thu") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Thu")
        }
    }
    @IBAction func actionBtnFriday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Fri") {
            if let index = self.arrSelectedWeekDays.index(of: "Fri") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Fri")
        }
    }
    @IBAction func actionBtnSaterday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if self.arrSelectedWeekDays.contains("Sat") {
            if let index = self.arrSelectedWeekDays.index(of: "Sat") {
                self.arrSelectedWeekDays.remove(at: index)
            }
        }else{
            self.arrSelectedWeekDays.append("Sat")
        }
    }
    
    func setBtnBorder (_ btn:UIView){
        btn.layer.borderColor = APPGRAYCOLOR.cgColor
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
    }
}
extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
}
