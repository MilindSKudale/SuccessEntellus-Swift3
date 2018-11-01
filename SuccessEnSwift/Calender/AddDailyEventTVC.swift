//
//  AddDailyEventTVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit


var dictForRepeate = [String:String]()
var isGoogleEvent = ""
import EventKit
import AMGCalendarManager

class AddDailyEventTVC: UITableViewController {

    @IBOutlet var txtEventName : SkyFloatingLabelTextField!
    @IBOutlet var txtTag : SkyFloatingLabelTextField!
    @IBOutlet var txtStartDate : SkyFloatingLabelTextField!
    @IBOutlet var txtEndDate : SkyFloatingLabelTextField!
    @IBOutlet var txtStartTime : SkyFloatingLabelTextField!
    @IBOutlet var txtEndTime : SkyFloatingLabelTextField!
    @IBOutlet var txtRepeat : SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var txtReminder : SkyFloatingLabelTextField!
    @IBOutlet var txtNoOfGoals : SkyFloatingLabelTextField!
    @IBOutlet var txtEventDetails : SkyFloatingLabelTextField!
    @IBOutlet var btnAddDailyTask : UIButton!
    @IBOutlet var btnGoogleCalender : UIButton!
    
    var reminder = ""
    var reminderType = ""
    var selection = ""
    var strStartDate = ""
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        txtStartDate.text = formatter.string(from: date)
        txtEndDate.text = formatter.string(from: date)
        strStartDate = formatter.string(from: date)
        
        formatter.dateFormat = "hh:mm a"
        txtStartTime.text = formatter.string(from: date)
        txtEndTime.text = formatter.string(from: date.addingTimeInterval(3600))
        
        btnAddDailyTask.layer.cornerRadius = 5.0
        btnAddDailyTask.clipsToBounds = true
        self.tableView.tableFooterView = UIView()
        
        txtReminder.text = ""
        reminder = ""
        reminderType = ""
        
        if googleSyncFlag == "login" || googleSyncFlag == "desync" {
          //  btnGoogleCalender.isEnabled = false
            btnGoogleCalender.isSelected = false
            isGoogleEvent = "No"
        }else{
          //  btnGoogleCalender.isEnabled = true
            btnGoogleCalender.isSelected = true
            isGoogleEvent = "Yes"
        }
        
        dictForRepeate = ["repeatEvery":"1",
                          "repeatBy":"",
                          "day":"",
                          "ends":"",
                          "ondate":"",
                          "Occurences":""]
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionBtnMore(_ sender: Any) {
        setRepeatEvent()
    }
    
    @IBAction func actionSelectGoogleCalender(sender: UIButton) {
       // sender.isSelected = !sender.isSelected;
        
        if sender.isSelected {
            sender.isSelected = false
            isGoogleEvent = "No"
        }else{
            if googleSyncFlag == "login" || googleSyncFlag == "desync" {
                OBJCOM.popUp(context: self, msg: "Log in with Google calendar & then try adding event into Google calendar.")
                btnGoogleCalender.isSelected = false
                isGoogleEvent = "No"
            }else{
                sender.isSelected = true
                isGoogleEvent = "Yes"
            }
        }
    }
    
    // Add Event ==========================================
    @IBAction func actionBtnAddEvent(sender: UIButton) {
       // sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: CGFloat(0.10),
//                       initialSpringVelocity: CGFloat(1.0),
//                       options: UIViewAnimationOptions.allowUserInteraction,
//                       animations: {
//                        sender.transform = CGAffineTransform.identity
//        }, completion: { Void in()
            if self.validate() == true {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    
                    if isGoogleEvent == "Yes" {
                        self.createEventGoogleCalender()
                    }else{
                        self.addEventInAppCalender()
//                        self.addEventInAppleCalendar()
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
//        }
    }
    
    func setRepeatEvent() {
        let alert = UIAlertController(title: "", message: "Please Select Repeat Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Weekly", style: .default , handler:{ (UIAlertAction)in
            self.txtRepeat.text = "Weekly"
            self.selection = "weekly"
            let storyboard = UIStoryboard(name: "Calender", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpWeeklyRepeatTVC") as! PopUpWeeklyRepeatTVC
            vc.strStartDate = self.strStartDate
            self.present(vc, animated: false, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Monthly", style: .default , handler:{ (UIAlertAction)in
            self.txtRepeat.text = "Monthly"
            self.selection = "monthly"
            let storyboard = UIStoryboard(name: "Calender", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpMonthlyRepeatTVC")  as! PopUpMonthlyRepeatTVC
            vc.strStartDate = self.strStartDate
            self.present(vc, animated: false, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "For 90 days", style: .default, handler:{ (UIAlertAction)in
            self.txtRepeat.text = "For 90 days"
            self.selection = "daily"
            let storyboard = UIStoryboard(name: "Calender", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idPopUp90DaysRepeatTVC") as! PopUp90DaysRepeatTVC
            vc.strStartDate = self.strStartDate
            self.present(vc, animated: false, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setReminder() {
        let alert = UIAlertController(title: "", message: "Please Select", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Email", style: .default , handler:{ (UIAlertAction)in
            self.txtReminder.text = "Email"
            self.reminder = "on"
            self.reminderType = "Email"
        }))
        
        alert.addAction(UIAlertAction(title: "SMS", style: .default , handler:{ (UIAlertAction)in
            self.txtReminder.text = "SMS"
            self.reminder = "on"
            self.reminderType = "Sms"
        }))
        
        alert.addAction(UIAlertAction(title: "Both", style: .default, handler:{ (UIAlertAction)in
            self.txtReminder.text = "SMS & Email"
            self.reminder = "on"
            self.reminderType = "Both"
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    var startDate = Date()
    var endDate = Date()
    func datePickerTapped(textfield:UITextField) {
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
            if textfield == self.txtStartDate {
                datePicker.show("Set date",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                minimumDate: Date(),
                                datePickerMode: .date) { (date) in
                                    if let dt = date {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM-dd-yyyy"
                                        self.txtStartDate.text = formatter.string(from: dt)
                                        self.txtEndDate.text = formatter.string(from: dt)
                                        self.strStartDate = formatter.string(from: dt)
                                        self.startDate = dt
                                    }
                }
            }else if textfield == self.txtEndDate {
                datePicker.show("Set date",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                minimumDate: startDate.addingTimeInterval(3600),
                                datePickerMode: .date) { (date) in
                                    if let dt = date {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM-dd-yyyy"
                                    
                                        self.txtEndDate.text = formatter.string(from: dt)
                                        
//                                        self.endDate = dt
                                        //self.startDate = self.endDate.addingTimeInterval(-3600)
                                    }
            }
        }
    }
    
    var startTime = Date()
    var endTime = Date()
    func timePickerTapped(textfield:UITextField) {
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        if textfield == self.txtStartTime {
            datePicker.show("Set Start Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: Date(),
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "hh:mm a"
                                    self.txtStartTime.text = formatter.string(from: dt)
                                    self.txtEndTime.text = formatter.string(from: dt.addingTimeInterval(3600))
                                    self.startTime = dt
//                                    self.endTime = dt.addingTimeInterval(3600)
                                }
            }
        }else{
            datePicker.show("Set End Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: self.startTime.addingTimeInterval(3600),
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm a"
                                    self.txtEndTime.text = formatter.string(from: dt)
//                                    self.endTime = dt
//                                    self.startTime = self.endTime.addingTimeInterval(-3600)
                                }
            }
        }
    }
}

extension AddDailyEventTVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtStartDate {
            datePickerTapped(textfield: textField)
            return false
        } else if textField == txtEndDate {
            datePickerTapped(textfield: textField)
            return false
        } else if textField == txtStartTime {
            timePickerTapped(textfield: textField)
            return false
        } else if textField == txtEndTime {
            timePickerTapped(textfield: textField)
            return false
        } else if textField == txtRepeat {
            if isGoogleEvent == "Yes" {
                OBJCOM.popUp(context: self, msg: "Google recurring events will available very soon with calender.")
            }else{
                setRepeatEvent()
            }
            return false
        } else if textField == txtReminder {
            setReminder()
            return false
        }
        return true
    }
    
    func addEventInAppCalender(){
        
        var dictParam : [String:String] = [:]
        dictParam["user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["selection"] = self.selection
        dictParam["occurence"] = dictForRepeate["Occurences"] ?? ""
        dictParam["tag"] = txtTag.text ?? ""
        dictParam["goal_id"] = txtEventName.text ?? ""
        dictParam["task_to_date"] = txtEndDate.text ?? ""
        dictParam["task_to_time"] = txtEndTime.text ?? ""
        dictParam["task_details"] = txtEventDetails.text ?? ""
        dictParam["complete_goals"] = txtNoOfGoals.text ?? ""
        dictParam["task_from_time"] = txtStartTime.text ?? ""
        dictParam["task_from_date"] = txtStartDate.text ?? ""
        dictParam["intervalVal"] = dictForRepeate["repeatEvery"] ?? ""
        dictParam["reminder"] = reminder
        dictParam["ends"] = dictForRepeate["ends"] ?? "" 
        dictParam["day"] = dictForRepeate["day"] ?? ""
        dictParam["onDate"] = dictForRepeate["ondate"] ?? ""
        dictParam["repeatBy"] = dictForRepeate["repeatBy"] ?? ""
        dictParam["reciveOn"] = self.reminderType
        dictParam["calenderGoogle"] = "0"
        print(dictParam)
        
        OBJCOM.modalAPICall(Action: "createEventAppCalender", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
        
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                self.addEventInAppleCalendar(dict: dictParam)
                NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil, userInfo: dictParam)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func createEventGoogleCalender(){
        OBJCOM.hideLoader()
        var dictParam : [String:String] = [:]
        dictParam["user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["selection"] = self.selection
        dictParam["occurence"] = dictForRepeate["Occurences"] ?? ""
        dictParam["tag"] = txtTag.text ?? ""
        dictParam["goal_id"] = txtEventName.text ?? ""
        dictParam["task_to_date"] = txtEndDate.text ?? ""
        dictParam["task_to_time"] = txtEndTime.text ?? ""
        dictParam["task_details"] = txtEventDetails.text ?? ""
        dictParam["complete_goals"] = txtNoOfGoals.text ?? ""
        dictParam["task_from_time"] = txtStartTime.text ?? ""
        dictParam["task_from_date"] = txtStartDate.text ?? ""
        dictParam["intervalVal"] = dictForRepeate["repeatEvery"] ?? ""
        dictParam["reminder"] = reminder
        dictParam["ends"] = dictForRepeate["ends"] ?? ""
        dictParam["day"] = dictForRepeate["day"] ?? ""
        dictParam["onDate"] = dictForRepeate["ondate"] ?? ""
        dictParam["repeatBy"] = dictForRepeate["repeatBy"] ?? ""
        dictParam["reciveOn"] = self.reminderType
        dictParam["calenderGoogle"] = "1"
        print(dictParam)
        self.addEventInAppleCalendar(dict: dictParam)
        
       NotificationCenter.default.post(name: Notification.Name("CreateGoogleEvent"), object: nil, userInfo: dictParam)
        self.dismiss(animated: true, completion: nil)
        OBJCOM.hideLoader()
    }
    
    func addEventInAppleCalendar(dict: [String:String]){
        
//        var dictParam : [String:String] = [:]
//        dictParam["user_id"] = userID
//        dictParam["platform"] = "3"
//        dictParam["selection"] = self.selection
//        dictParam["occurence"] = dictForRepeate["Occurences"] ?? ""
//        dictParam["tag"] = txtTag.text ?? ""
//        dictParam["goal_id"] = txtEventName.text ?? ""
//        dictParam["task_to_date"] = txtEndDate.text ?? ""
//        dictParam["task_to_time"] = txtEndTime.text ?? ""
//        dictParam["task_details"] = txtEventDetails.text ?? ""
//        dictParam["complete_goals"] = txtNoOfGoals.text ?? ""
//        dictParam["task_from_time"] = txtStartTime.text ?? ""
//        dictParam["task_from_date"] = txtStartDate.text ?? ""
//        dictParam["intervalVal"] = dictForRepeate["repeatEvery"] ?? ""
//        dictParam["reminder"] = reminder
//        dictParam["ends"] = dictForRepeate["ends"] ?? ""
//        dictParam["day"] = dictForRepeate["day"] ?? ""
//        dictParam["onDate"] = dictForRepeate["ondate"] ?? ""
//        dictParam["repeatBy"] = dictForRepeate["repeatBy"] ?? ""
//        dictParam["reciveOn"] = self.reminderType
//        dictParam["calenderGoogle"] = "0"
//        print(dictParam)
        
        AMGCalendarManager.shared.createEvent(completion: { (event) in
            guard let event = event else { return }
            let strDt = self.stringToDate(strDate: "\(dict["task_from_date"]!) \(dict["task_from_time"]!)")
            let endDt = self.stringToDate(strDate: "\(dict["task_to_date"]!) \(dict["task_to_time"]!)")
            
            event.startDate = strDt
            event.endDate = endDt
            event.title = "\(dict["goal_id"]!)"
            event.notes = "\(dict["task_details"]!)"
            let recRule = self.getRepeatValue(dict["selection"]!, interval: dict["intervalVal"]!, day: dict["day"]!)
            if recRule != nil {
                event.recurrenceRules = [recRule!]
            }
            AMGCalendarManager.shared.saveEvent(event: event)
            NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil, userInfo: dict)
            self.dismiss(animated: true, completion: nil)
        })
        OBJCOM.hideLoader()
    }
    
    func getRepeatValue (_ option : String, interval : String, day : String) -> EKRecurrenceRule?{
        switch option {
        case "daily":
            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: Int(interval)!, end: nil)
            return rule
        case "weekly":
            var weekDays = [EKRecurrenceDayOfWeek]()
            let dayVal = day.components(separatedBy: ",")
            for obj in dayVal {
                weekDays.append(self.getWeekDays(obj)!)
            }
            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: Int(interval)!, daysOfTheWeek: weekDays, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            return rule
        case "monthly":
            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: Int(interval)!, end: nil)
            return rule
        default:
            return nil
        }
    }
    
    func getWeekDays(_ day:String) -> EKRecurrenceDayOfWeek?{
        switch day {
        case "SU":
            return EKRecurrenceDayOfWeek(.sunday)
        case "MO":
            return EKRecurrenceDayOfWeek(.monday)
        case "TU":
            return EKRecurrenceDayOfWeek(.tuesday)
        case "WE":
            return EKRecurrenceDayOfWeek(.wednesday)
        case "TH":
            return EKRecurrenceDayOfWeek(.thursday)
        case "FR":
            return EKRecurrenceDayOfWeek(.friday)
        case "SA":
            return EKRecurrenceDayOfWeek(.saturday)
        default:
            return nil
        }
    }
   
    
    func validate() -> Bool {
        if txtEventName.text! == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter event name.")
            return false
        }
        return true
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        return dateFormatter.date(from: strDate)!
    }
}
//"RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=SA;UNTIL=20181218";





