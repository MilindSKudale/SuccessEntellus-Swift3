//
//  EditEventTVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 26/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import EventKit
import AMGCalendarManager

class EditEventTVC: UITableViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet var txtEventName : SkyFloatingLabelTextField!
    @IBOutlet var txtTag : SkyFloatingLabelTextField!
    @IBOutlet var txtStartDate : SkyFloatingLabelTextField!
    @IBOutlet var txtEndDate : SkyFloatingLabelTextField!
    @IBOutlet var txtStartTime : SkyFloatingLabelTextField!
    @IBOutlet var txtEndTime : SkyFloatingLabelTextField!
    @IBOutlet var txtNoOfGoals : SkyFloatingLabelTextField!
    @IBOutlet var txtEventDetails : SkyFloatingLabelTextField!
    @IBOutlet var txtReminder : SkyFloatingLabelTextField!
    @IBOutlet var btnOnlyThisEvent : UIButton!
    @IBOutlet var btnThisAndFollowing : UIButton!
    @IBOutlet var btnAllEvents : UIButton!
    @IBOutlet var btnUpdateEvent : UIButton!
    @IBOutlet var btnGoogleEvent : UIButton!
    @IBOutlet var lblRecEvent : UILabel!
    @IBOutlet var lblOTEvent : UILabel!
    @IBOutlet var lblFEvent : UILabel!
    @IBOutlet var lblAllEvent : UILabel!
    
    var eventData : [String:AnyObject]!
    var eventId = ""
    var googleEventId = ""
    var applyAll = "1"
    var startDateValue = ""
    var reminderValue = ""
    var receiveOn = ""
    var isAppleEvent = "0"
    
    var endDate = Date()
    var startDate = Date()
    var startTime = Date()
    var endTime = Date()
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnUpdateEvent.layer.cornerRadius = 5.0
        btnUpdateEvent.clipsToBounds = true
        self.tableView.tableFooterView = UIView()
        assignEventData()
        print(eventData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSetReminder(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            isGoogleEvent = "No"
        }else{
            let randomNumber = "\(eventData["randomNumber"]!)"
            if randomNumber == "" || randomNumber == "0" {
                if googleSyncFlag == "login" || googleSyncFlag == "desync" {
                    OBJCOM.popUp(context: self, msg: "Log in with Google calendar & then try adding event into Google calendar.")
                    btnGoogleEvent.isSelected = false
                    isGoogleEvent = "No"
                }else{
                    btnGoogleEvent.isSelected = true
                    isGoogleEvent = "Yes"
                }
            }else{
                OBJCOM.popUp(context: self, msg: "Modify recurring events with google calendar will available very soon with calender.")
                sender.isSelected = false
                isGoogleEvent = "No"
            }
        }
    }
    
    func assignEventData(){
        
        txtEventName.text = eventData["goal_name"] as? String
        txtTag.text = eventData["tag"] as? String
        txtNoOfGoals.text = eventData["completedGoals"] as? String
        txtEventDetails.text = eventData["task_details"] as? String
        eventId = eventData["edit_id"] as! String
        receiveOn = eventData["reciveOn"] as? String ?? ""
        isAppleEvent = "\(eventData["iosEventFlag"]!)"
        
        if receiveOn != "" {
            txtReminder.text = receiveOn
            reminderValue = "on"
        }else{
            reminderValue = ""
            txtReminder.text = ""
        }
        startDate = self.stringToDate(strDate: eventData["task_fromdt"] as? String ?? "")
        startDateValue = eventData["task_fromdt"] as? String ?? ""
        endDate = self.stringToDate(strDate: eventData["task_todt"] as? String ?? "")
        startTime = self.stringToDate(strDate: eventData["task_fromdt"] as? String ?? "")
        endTime = self.stringToDate(strDate: eventData["task_todt"] as? String ?? "")
        
        let sd = self.dateToString(dt: startDate)
        let ed = self.dateToString(dt: endDate)
        let st = self.dateToStringTime(dt: startDate)
        let et = self.dateToStringTime(dt: endDate)
        
        txtStartDate.text = sd
        txtEndDate.text = ed
        txtStartTime.text = st
        txtEndTime.text = et
        
        let isGoogle = "\(eventData["googleCalRecurEventId"]!)"
        if isGoogle != "" {
            lblRecEvent.isHidden = false
            lblOTEvent.isHidden = false
            lblFEvent.isHidden = false
            lblAllEvent.isHidden = false
            btnOnlyThisEvent.isHidden = false
            btnThisAndFollowing.isHidden = false
            btnAllEvents.isHidden = false
            btnOnlyThisEvent.isSelected = true
            btnThisAndFollowing.isSelected = false
            btnAllEvents.isSelected = false
            btnGoogleEvent.isSelected = true
            isGoogleEvent = "Yes"
            googleEventId = "\(eventData["googleCalEventId"]!)"
        }else{
            let randomNumber = "\(eventData["randomNumber"]!)"
            if randomNumber != "" && randomNumber != "0" {
                lblRecEvent.isHidden = false
                lblOTEvent.isHidden = false
                lblFEvent.isHidden = false
                lblAllEvent.isHidden = false
                btnOnlyThisEvent.isHidden = false
                btnThisAndFollowing.isHidden = false
                btnAllEvents.isHidden = false
                btnOnlyThisEvent.isSelected = true
            }else{
                lblRecEvent.isHidden = true
                lblOTEvent.isHidden = true
                lblFEvent.isHidden = true
                lblAllEvent.isHidden = true
                btnOnlyThisEvent.isHidden = true
                btnThisAndFollowing.isHidden = true
                btnAllEvents.isHidden = true
            }
            
            btnGoogleEvent.isSelected = false
            isGoogleEvent = "No"
            googleEventId = ""
        }
    }
    
    @IBAction func actionSetOnlyThisEvent(sender: UIButton) {
        btnOnlyThisEvent.isSelected = true
        btnThisAndFollowing.isSelected = false
        btnAllEvents.isSelected = false
        self.applyAll = "1"
    }
    
    @IBAction func actionSetThisAndAllFollowing(sender: UIButton) {
        btnOnlyThisEvent.isSelected = false
        btnThisAndFollowing.isSelected = true
        btnAllEvents.isSelected = false
        self.applyAll = "2"
    }
    
    @IBAction func actionSetAllEvents(sender: UIButton) {
        btnOnlyThisEvent.isSelected = false
        btnThisAndFollowing.isSelected = false
        btnAllEvents.isSelected = true
        self.applyAll = "3"
    }
    
    @IBAction func actionUpdateEvent(_ sender:UIButton){

        if validate() == true {
            
                var dictParam : [String:String] = [:]
                dictParam["user_id"] = userID
                dictParam["platform"] = "3"
                dictParam["edit_id"] = eventData["edit_id"] as? String ?? ""
                dictParam["tag"] = txtTag.text
                dictParam["task_to_date"] = txtEndDate.text ?? ""
                dictParam["task_to_time"] = txtEndTime.text ?? ""
                dictParam["goal_id"] = txtEventName.text ?? ""
                dictParam["task_details"] = txtEventDetails.text ?? ""
                dictParam["complete_goals"] = txtNoOfGoals.text ?? ""
                dictParam["task_from_time"] = txtStartTime.text ?? ""
                dictParam["task_from_date"] = txtStartDate.text ?? ""
                dictParam["reciveOn"] = receiveOn
                dictParam["reminder"] = reminderValue
                dictParam["applyAll"] = self.applyAll
                dictParam["googleCalRecurEvent"] = eventData["googleCalRecurEventId"] as? String ?? ""
                dictParam["randomNumberValue"] = eventData["randomNumber"] as? String ?? ""
                dictParam["repeatEventFlag"] = eventData["googleCalEventFlag"] as? String ?? ""
                dictParam["iosEventFlag"] = isAppleEvent
                dictParam["iosCalEventId"] = eventData["iosCalEventId"] as? String ?? ""
                dictParam["iosCalenderRecurData"] = eventData["iosCalenderRecurData"] as? String ?? ""
            
                print(dictParam)
                if isAppleEvent == "1" {
                    let recString = eventData["iosCalenderRecurData"] as? String ?? ""
                    if recString == "" {
                        self.editAppleCalenderThisEventOnly(dict : dictParam)
                    }else{
                         self.updateAppCalendarEvents(dict : dictParam)
                    }
                   
                }else{
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.updateEvent(dict : dictParam)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }

                }
                
        }
    }
    
    func validate() -> Bool {
        
        if txtEventName.text! == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter event name.")
            return false
        }
        return true
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
}

extension EditEventTVC {
    
    func datePickerTapped(textfield:UITextField) {
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        if textfield == self.txtStartDate {
            datePicker.show("Set date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: nil,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MM-dd-yyyy"
                                    self.txtStartDate.text = formatter.string(from: dt)
                                    self.txtEndDate.text = formatter.string(from: dt)
                                    self.startDate = dt
                                    if self.txtStartTime.text != self.startDateValue {
                                        self.lblAllEvent.isHidden = true
                                        self.btnAllEvents.isHidden = true
                                        self.btnOnlyThisEvent.isSelected = true
                                        self.applyAll = "1"
                                    }
                                }
            }
        }else if textfield == self.txtEndDate {
            datePicker.show("Set date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: startDate,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MM-dd-yyyy"
                                    
                                    self.txtEndDate.text = formatter.string(from: dt)
                                    self.endDate = dt
                                    if self.txtStartTime.text != self.startDateValue {
                                        self.lblAllEvent.isHidden = true
                                        self.btnAllEvents.isHidden = true
                                        self.btnOnlyThisEvent.isSelected = true
                                        self.applyAll = "1"
                                    }
                                }
            }
        }
    }
    
   
    func timePickerTapped(textfield:UITextField) {
       // let currentDate = Date()
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        if textfield == self.txtStartTime {
            datePicker.show("Set Start Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: nil,
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "hh:mm a"
                                    self.txtStartTime.text = formatter.string(from: dt)
                                    self.txtEndTime.text = formatter.string(from: dt)
                                    self.startTime = dt
                                    
                                    
                                }
            }
        }else{
            datePicker.show("Set End Time",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: self.startTime,
                            datePickerMode: .time) { (date) in
                                if let dt = date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "hh:mm a"
                                    self.txtEndTime.text = formatter.string(from: dt)
                                    self.endDate = dt
                                }
            }
        }
    }
    
    func setReminder() {
        let alert = UIAlertController(title: "", message: "Please Select", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Email", style: .default , handler:{ (UIAlertAction)in
            self.txtReminder.text = "Email"
            self.reminderValue = "on"
            self.receiveOn = "Email"
        }))
        
        alert.addAction(UIAlertAction(title: "SMS", style: .default , handler:{ (UIAlertAction)in
            self.txtReminder.text = "SMS"
            self.reminderValue = "on"
            self.receiveOn = "Sms"
        }))
        
        alert.addAction(UIAlertAction(title: "Both", style: .default, handler:{ (UIAlertAction)in
            self.txtReminder.text = "SMS & Email"
            self.reminderValue = "on"
            self.receiveOn = "Both"
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func stringToDateApple(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: dt)
    }
    func dateToStringTime(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
}

extension EditEventTVC: UITextFieldDelegate {
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
        }else if textField == txtReminder {
            setReminder()
            return false
        }
        return true
    }
    
    func updateEvent(dict : [String:Any]){
        
    
        OBJCOM.modalAPICall(Action: "updateDailytask", param:dict as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                OBJCOM.hideLoader()
                if isGoogleEvent == "Yes" {
                    GIDSignIn.sharedInstance().delegate=self
                    GIDSignIn.sharedInstance().uiDelegate=self
                    GIDSignIn.sharedInstance().scopes = self.scopes
                    if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
                        GIDSignIn.sharedInstance().signInSilently()
                    }else{
                        GIDSignIn.sharedInstance().signIn()
                    }
                }else{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    NotificationCenter.default.post(name: Notification.Name("EditTaskList"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    //=====================================================
    
    func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func signIn(_ signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(_ signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            OBJCOM.setAlert(_title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()
            self.updateGoogleEvent()
        }
    }

    func updateGoogleEvent() {
        
            let calendarEvent = GTLRCalendar_Event()
            
            calendarEvent.summary = txtEventName.text ?? ""
            calendarEvent.descriptionProperty = txtEventDetails.text  ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            let startTime = "\(txtStartDate.text ?? "") \(txtStartTime.text ?? "")"
            let endTime = "\(txtEndDate.text ?? "") \(txtEndTime.text ?? "")"
            
            let startDate = dateFormatter.date(from: startTime)
            let endDate = dateFormatter.date(from: endTime)
            
            if startDate == nil || endDate == nil {
                return
            }
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.EEEE"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            calendarEvent.start = GTLRCalendar_EventDateTime()
            calendarEvent.start?.dateTime = GTLRDateTime(date: startDate!)
            calendarEvent.start?.timeZone = TimeZone.autoupdatingCurrent.identifier
            
            calendarEvent.end = GTLRCalendar_EventDateTime()
            calendarEvent.end?.dateTime = GTLRDateTime(date: endDate!)
            calendarEvent.end?.timeZone = TimeZone.autoupdatingCurrent.identifier
            
            calendarEvent.status = "confirmed"
            calendarEvent.location = ""
            
            let remaindar = GTLRCalendar_EventReminder()
            remaindar.minutes = 300
            remaindar.method = "email"
            
            calendarEvent.reminders = GTLRCalendar_Event_Reminders()
            calendarEvent.reminders?.overrides = [remaindar]
            calendarEvent.reminders?.useDefault = false
            
            
            print(calendarEvent)
            
            let updateQuery = GTLRCalendarQuery_EventsUpdate.query(withObject: calendarEvent, calendarId: "primary", eventId: googleEventId)
            updateQuery.maxAttendees = 2
            updateQuery.supportsAttachments = false
        
            service.executeQuery(
                updateQuery,
                delegate: self,
                didFinish: #selector(updateGoogleEvents(ticket:finishedWithObject:error:)))
    }
    
    @objc func updateGoogleEvents(
        ticket:GTLRServiceTicket,
        finishedWithObject event:GTLRCalendar_Event,
        error:NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message: "\(error!.localizedDescription)")
            return
        }else{
            var dictParam : [String:String] = [:]
            dictParam["user_id"] = userID
            dictParam["edit_id"] = eventData["edit_id"] as? String ?? ""
            dictParam["tag"] = txtTag.text
            dictParam["task_to_date"] = txtEndDate.text ?? ""
            dictParam["task_to_time"] = txtEndTime.text ?? ""
            dictParam["goal_id"] = txtEventName.text ?? ""
            dictParam["task_details"] = txtEventDetails.text ?? ""
            dictParam["complete_goals"] = txtNoOfGoals.text ?? ""
            dictParam["task_from_time"] = txtStartTime.text ?? ""
            dictParam["task_from_date"] = txtStartDate.text ?? ""
            dictParam["reciveOn"] = eventData["reciveOn"] as? String ?? ""
            dictParam["reminder"] = "on"
            print(dictParam)
            DispatchQueue.main.async(execute: {
                self.updateEvent(dict : dictParam)
            })
            
            NotificationCenter.default.post(name: Notification.Name("EditTaskList"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dateToStringG(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: dt)
    }
    
    func updateAppCalendarEvents(dict : [String:Any]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Only this event", style: .default , handler:{ (UIAlertAction)in
            self.editAppleCalenderThisEventOnly(dict : dict)
        }))
        
        alert.addAction(UIAlertAction(title: "All future events", style: .default , handler:{ (UIAlertAction)in
           self.editAppleCalenderAllFutureEvents(dict : dict)
        }))
       
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func editAppleCalenderThisEventOnly(dict : [String:Any]){
       
    
        if let eventId = eventData["iosCalEventId"] {

            let strDt = self.stringToDateApple(strDate: "\(self.txtStartDate.text!) \(self.txtStartTime.text!)")
            let endDt = self.stringToDateApple(strDate: "\(self.txtEndDate.text!) \(self.txtEndTime.text!)")

            let event = self.eventStore.event(withIdentifier: eventId as! String)
            
            event?.startDate = strDt
            event?.endDate = endDt
            event?.title = "\(dict["goal_id"]!)"
            event?.notes = "\(dict["task_details"]!)"
            event?.recurrenceRules = nil
                
            do {
                try self.eventStore.save(event!, span: .thisEvent, commit: true)
                self.updateEvent(dict : dict)
            } catch {
                
            }
        }
    }
    
    func editAppleCalenderAllFutureEvents(dict : [String:Any]){
        
        if let eventId = eventData["iosCalEventId"] {
            
            let strDt = self.stringToDateApple(strDate: "\(self.txtStartDate.text!) \(self.txtStartTime.text!)")
            let endDt = self.stringToDateApple(strDate: "\(self.txtEndDate.text!) \(self.txtEndTime.text!)")
            
            let event = self.eventStore.event(withIdentifier: eventId as! String)
            
            event?.startDate = strDt
            event?.endDate = endDt
            event?.title = "\(dict["goal_id"]!)"
            event?.notes = "\(dict["task_details"]!)"
            
//            if event!.hasRecurrenceRules {
//                var strFreq = ""
//                var interVal = ""
//
//                if event?.recurrenceRules?.first?.frequency == .daily {
//                    strFreq = "daily"
//                    interVal = "\(event?.recurrenceRules?.first?.interval ?? 1)"
//                    let recRule = self.getRepeatValue(strFreq, interval: interVal, day: [])
//                    if recRule != nil {
//                        event?.recurrenceRules = [recRule!]
//                    }
//                }else if event?.recurrenceRules?.first?.frequency == .weekly {
//                    strFreq = "weekly"
//                    interVal = "\(event?.recurrenceRules?.first?.interval ?? 1)"
//                    let weekDays = event?.recurrenceRules?.first?.daysOfTheWeek
//
//                    let recRule = self.getRepeatValue(strFreq, interval: interVal, day: weekDays!)
//                    if recRule != nil {
//                        event?.recurrenceRules = [recRule!]
//                    }
//                }else if event?.recurrenceRules?.first?.frequency == .monthly {
//                    strFreq = "monthly"
//                    interVal = "\(event?.recurrenceRules?.first?.interval ?? 1)"
//                    let recRule = self.getRepeatValue(strFreq, interval: interVal, day: [])
//                    if recRule != nil {
//                        event?.recurrenceRules = [recRule!]
//                    }
//                }
//
//            }
            
            do {
                try self.eventStore.save(event!, span: .futureEvents, commit: true)
                self.updateEvent(dict : dict)
            } catch {
                
            }
        }
    }
    
    
//    func getRepeatValue (_ option : String, interval : String, day : [EKRecurrenceDayOfWeek]) -> EKRecurrenceRule?{
//        switch option {
//        case "daily":
//            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: Int(interval)!, end: nil)
//            return rule
//        case "weekly":
//
//            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: Int(interval)!, daysOfTheWeek: day, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
//            return rule
//        case "monthly":
//            let rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: Int(interval)!, end: nil)
//            return rule
//        default:
//            return nil
//        }
//    }
//
//    func getWeekDays(_ day:String) -> EKRecurrenceDayOfWeek?{
//        switch day {
//        case "SU":
//            return EKRecurrenceDayOfWeek(.sunday)
//        case "MO":
//            return EKRecurrenceDayOfWeek(.monday)
//        case "TU":
//            return EKRecurrenceDayOfWeek(.tuesday)
//        case "WE":
//            return EKRecurrenceDayOfWeek(.wednesday)
//        case "TH":
//            return EKRecurrenceDayOfWeek(.thursday)
//        case "FR":
//            return EKRecurrenceDayOfWeek(.friday)
//        case "SA":
//            return EKRecurrenceDayOfWeek(.saturday)
//        default:
//            return nil
//        }
//    }
//
//    func getWeekDaysFromRecEvent(_ day:EKRecurrenceDayOfWeek) -> String?{
//        switch day {
//        case EKRecurrenceDayOfWeek(.sunday):
//            return "SU"
//        case EKRecurrenceDayOfWeek(.monday):
//            return "MO"
//        case EKRecurrenceDayOfWeek(.tuesday):
//            return "TU"
//        case EKRecurrenceDayOfWeek(.wednesday):
//            return "WE"
//        case EKRecurrenceDayOfWeek(.thursday):
//            return "TH"
//        case EKRecurrenceDayOfWeek(.friday):
//            return "FR"
//        case EKRecurrenceDayOfWeek(.saturday):
//            return "SA"
//        default:
//            return ""
//        }
//    }
}
