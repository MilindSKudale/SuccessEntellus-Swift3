//
//  CalenderVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import FSCalendar
import GoogleAPIClientForREST
import GoogleSignIn
import EventKit
import AMGCalendarManager

var googleSyncFlag = ""
var googleSync = ""


class CalenderVC: SliderVC, FSCalendarDataSource, FSCalendarDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var calendarView: FSCalendar!
    var arrEventTitle = [String]()
    var arrEventStart = [String]()
    var arrEventEnd = [String]()
    var arrEventId = [String]()
    var eventData = [Data]()
    
    var eventDataForAdd = [String:Any]()

    var addEvent = ""
    var activeEmail = ""
   
    var createdDate : GTLRDateTime!
    var updatedDate : GTLRDateTime!
    var startDate : GTLRDateTime!
    var endDate : GTLRDateTime!
    
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    let eventStore = EKEventStore()
    var iCalEvents = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Calendar"
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = APPORANGECOLOR
        actionButton.addItem(title: "Add Event", image: nil) { item in
            print("Action Float button")
            OBJCOM.animateButton(button: actionButton)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.CreateGoogleEvent),
                name: NSNotification.Name(rawValue: "CreateGoogleEvent"),
                object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.calendarChanged), name: .EKEventStoreChanged, object: self.eventStore)
            
            let storyboard = UIStoryboard(name: "Calender", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddDailyEventTVC")
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.addEvent = "addEvent"
            self.present(vc, animated: false, completion: nil)
        }
        
        actionButton.display(inViewController: self)
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateCalender),
            name: NSNotification.Name(rawValue: "UpdateCalender"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //
        
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                //DispatchQueue.main.async {
                 //   self.fetchEventsFromDeviceCalendar()
               // }
                self.getCalenderDataFromServer()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
      //
        
        
    }
    
    @objc func UpdateCalender(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
//            self.fetchEventsFromDeviceCalendar()
            
            self.getCalenderDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func calendarChanged(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
//            self.fetchEventsFromDeviceCalendar()
            self.getCalenderDataFromServer()
            
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        //DispatchQueue.main.async {
            if monthPosition == .previous || monthPosition == .next {
                calendar.setCurrentPage(date, animated: true)
            }else{
                let dateString = self.dateToString(dt: date)
                if self.arrEventStart.contains(dateString) || self.arrEventEnd.contains(dateString) {
                    let storyboard = UIStoryboard(name: "Calender", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "idTaskListVC") as! TaskListVC
                    vc.selectedDate = self.dateToString(dt: date)
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: false, completion: nil)
                }
                
            }
       // }
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
         //DispatchQueue.main.async {
            let dateString = self.dateToString(dt: date)
            if self.arrEventStart.contains(dateString) || self.arrEventEnd.contains(dateString) {
                return 1
            }
            return 0
       // }
    }
   
    @IBAction func actionBtnMore(_ sender: Any) {
        setOptions()
    }
    
    func setOptions() {
        let alert = UIAlertController(title: "Calendar Menu", message: self.activeEmail, preferredStyle: .actionSheet)
        
        if googleSyncFlag == "login" {
            googleSync = ""
            alert.addAction(UIAlertAction(title: "Sign In With Google Calendar", style: .default , handler:{ (UIAlertAction)in
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().delegate = self
                GIDSignIn.sharedInstance().uiDelegate = self
                GIDSignIn.sharedInstance().scopes = self.scopes
                GIDSignIn.sharedInstance().signIn()
            })
            )
            alert.addAction(UIAlertAction(title: "Sync iPhone Calendar", style: .default , handler:{ (UIAlertAction)in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.fetchEventsFromDeviceCalendarSync()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            })
            )
        }else{
            alert.addAction(UIAlertAction(title: "Sign Out From Google Calendar", style: .default , handler:{ (UIAlertAction)in
                googleSyncFlag = "login"
                googleSync = "login"
                GIDSignIn.sharedInstance().signOut()
                self.fetchEvents()

            }))
            alert.addAction(UIAlertAction(title: "Sync Google Calendar", style: .default , handler:{ (UIAlertAction)in
                googleSyncFlag = "sync"
                googleSync = "login"
                
                GIDSignIn.sharedInstance().delegate=self
                GIDSignIn.sharedInstance().uiDelegate=self
                GIDSignIn.sharedInstance().scopes = self.scopes
                if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
                    GIDSignIn.sharedInstance().signInSilently()
                }else{
                    GIDSignIn.sharedInstance().signIn()
                }
                
               // GIDSignIn.sharedInstance().signInSilently()
//                self.fetchEvents()
            }))
            alert.addAction(UIAlertAction(title: "Desync Google Calendar", style: .default , handler:{ (UIAlertAction)in
                
                googleSyncFlag = "desync"
                googleSync = "login"
                GIDSignIn.sharedInstance().signOut()
                self.fetchEvents()
            }))
            alert.addAction(UIAlertAction(title: "Sync iPhone Calendar", style: .default , handler:{ (UIAlertAction)in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    //DispatchQueue.main.async {
                        self.fetchEventsFromDeviceCalendarSync()
                   // }
                    
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            })
            )
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension CalenderVC {
    
    func getCalenderDataFromServer(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEventTitle = []
            self.arrEventStart = []
            self.arrEventEnd = []
            self.arrEventId = []
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]

                for obj in result {
                    self.arrEventTitle.append(obj["title"] as! String)
                    self.arrEventId.append(obj["zo_user_daily_task_id"] as! String)
                    
                    let dt = self.stringToDate(strDate: obj["original_start"] as! String)
                    let strDt = self.dateToString(dt: dt)
                  //  print(strDt)
                    self.arrEventStart.append(strDt)
                    self.arrEventEnd.append(obj["end"] as! String)

                }
               // DispatchQueue.main.async(execute: {
                self.calendarView.delegate = self
                self.calendarView.dataSource = self
                self.calendarView.reloadData()
                //})
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForCheckCalenderEmailActive()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
}

extension DateFormatter {
    static var sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
}

extension CalenderVC {
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dt)
    }
    
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
            self.fetchEvents()
            
            if addEvent != "addEvent" {
                if googleSyncFlag == "login" {
                   // DispatchQueue.main.async {
                        googleSync = "login"
                        let dictParam = ["user_id" : userID,
                                         "platform": "3",
                                         "access_token" : user.authentication.accessToken!,
                                         "refresh_token" : user.authentication.refreshToken,
                                         "email_id" : user.profile.email!]
                        
                        if OBJCOM.isConnectedToNetwork(){
                            OBJCOM.setLoader()
                            self.apiCallForAddUserInfoInDB(dictParam: dictParam as [String : AnyObject])
                           
                        }else{
                            OBJCOM.NoInternetConnectionCall()
                        }
                    //}
                }
            }else{
                self.addEvent = ""
                self.addEventoToGoogleCalendar(dict: self.eventDataForAdd)
            }
        }
    }
    
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId:"primary")
        query.maxResults = 100
        query.timeMin = GTLRDateTime(date: Date()) // startDate
//        query.timeMax = endDate
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        //query.orderBy = kGTLRCalendarOrderByUpdated
    
        if googleSyncFlag == "sync"{
            service.executeQuery(
                query,
                delegate: self,
                didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        }else if googleSyncFlag == "desync"{
            let queryClear = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        service.executeQuery(
            queryClear,
            delegate: self,
        didFinish: #selector(desyncGoogleEvents(ticket:finishedWithObject:error:)))
        }else if googleSyncFlag == "login" {
            self.apiCallForDesyncEventWithServer()
        }
    }
    
    func deleteEvents(eventId : String) {
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(deleteGoogleEvents(ticket:finishedWithObject:error:)))
    }
    
    @objc func deleteGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Event,
        error : NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
        print(response)
        OBJCOM.popUp(context: self, msg: "Event deleted successfully from google calender.")
    }
    
    
    @objc func desyncGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
        GIDSignIn.sharedInstance().signOut()
        OBJCOM.setLoader()
        self.apiCallForDesyncEventWithServer()
    }

    // Display the start dates and event summaries in the UITextView
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        var googleEvents = [AnyObject]()
        
        if error != nil {
            OBJCOM.popUp(context: self, msg: "No new event(s) found to sync with Success Entellus app calender.")
            return
        }
        
        if let events = response.items, !events.isEmpty {
            for event in events {
                self.createdDate = event.created
                self.updatedDate = event.updated
                if event.start?.dateTime == nil {
                    self.startDate = event.start?.date
                }else{
                    self.startDate = event.start?.dateTime
                }
                
                if event.end?.dateTime == nil {
                    self.endDate = event.end?.date
                }else{
                    self.endDate = event.end?.dateTime
                }
                
                let strStartDate = self.dateToStringG(dt: startDate.date)
                let strEndDate = self.dateToStringG(dt: endDate.date)
                let strCreated = self.dateToStringG(dt: createdDate.date)
                let strUpdated = self.dateToStringG(dt: updatedDate.date)
                
                var dictGoogleData = [String : Any]()
                dictGoogleData["id"] = event.identifier ?? ""
                dictGoogleData["organizer"] = event.organizer?.email ?? ""
                dictGoogleData["location"] = event.location  ?? ""
                dictGoogleData["iCalUID"] = event.iCalUID  ?? ""
                dictGoogleData["description"] = event.summary!
                dictGoogleData["htmlLink"] = event.htmlLink ?? ""
                dictGoogleData["hangoutLink"] = event.hangoutLink  ?? ""
                dictGoogleData["sequence"] = "0"
                dictGoogleData["end"] = ["dateTime":strEndDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["start"] = ["dateTime":strStartDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["summary"] = event.summary!
                dictGoogleData["creator"] = event.organizer?.email!
                dictGoogleData["kind"] = event.kind ?? ""
                dictGoogleData["reminders"] = "useDefault" as String
                dictGoogleData["created"] = strCreated
                dictGoogleData["updated"] = strUpdated
                dictGoogleData["status"] = "confirmed"
                dictGoogleData["calenderGoogle"] = "1"
                dictGoogleData["recurringEventId"] = event.recurringEventId
                googleEvents.append(dictGoogleData as AnyObject)
            }
        }
        if googleEvents.count > 0 {
           // DispatchQueue.main.async(execute: {
                self.apiCallForAddGoogleEventsInDb(obj:googleEvents)
           // })
        }
    }
    
    func apiCallForAddGoogleEventsInDb(obj:[AnyObject]){
       
        let dictParam = ["user_id" : userID,
                         "platform": "3",
                         "result"  : obj] as [String : AnyObject]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        
        OBJCOM.modalAPICall(Action: "addAllGoogleEventsDBIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForCheckCalenderEmailActive(){
        let dictParam = ["user_id" : userID,
                         "platform": "3"]
 
        OBJCOM.modalAPICall(Action: "checkCalenderEmailActive", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                
                let status = JsonDict!["status"] as? String ?? ""
               // let emailId = JsonDict!["emailId"] as? String ?? ""
                
                if status == "login" {
                    let result = JsonDict!["result"] as! String
                    googleSyncFlag = status
                    self.activeEmail = ""
                    OBJCOM.popUp(context: self, msg: result)
                }else if status == "active" {
                    googleSyncFlag = status
                    self.activeEmail = JsonDict!["emailId"] as! String
                    GIDSignIn.sharedInstance().signInSilently()
                }else if status == "desync" {
                    self.activeEmail = JsonDict!["emailId"] as! String
                    googleSyncFlag = status
                }
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForAddUserInfoInDB(dictParam:[String : AnyObject]){
        OBJCOM.modalAPICall(Action: "addCalenderInfoDatabase", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.popUp(context: self, msg: result)
                googleSyncFlag = "sync"
                self.fetchEvents()
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForDesyncEventWithServer(){
        let dictParam = ["user_id":userID]
        OBJCOM.modalAPICall(Action: "deleteSyncCalendarEvent", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.popUp(context: self, msg: result)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func dateToStringG(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: dt)
    }
    
//============== add google calender events ======================
    @objc func CreateGoogleEvent(notification: NSNotification) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            GIDSignIn.sharedInstance().signInSilently()
            
            self.eventDataForAdd = notification.userInfo as! [String : Any]
            
        }else{
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func addEventoToGoogleCalendar(dict:[String:Any]) {
        let calendarEvent = GTLRCalendar_Event()
    
        calendarEvent.summary = dict["goal_id"] as? String ?? ""
        calendarEvent.descriptionProperty = dict["task_details"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startTime = "\(dict["task_from_date"] ?? "") \(dict["task_from_time"] ?? "")"
        let endTime = "\(dict["task_to_date"] ?? "") \(dict["task_to_time"] ?? "")"
        
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
      
//        let selectRec = dict["selection"] as? String ?? ""
//        if selectRec != ""{
//            var recRule = ""
//            if selectRec == "weekly"{
//                recRule = "RRULE:FREQ=WEEKLY;UNTIL=20250630;BYDAY="
////                let endOn = dict["ends"] as? String ?? ""
////                if endOn == "endOn"{
////                    var endTime = dict["ondate"] as! String
////                    endTime = endTime.replacingOccurrences(of: "-", with: "")
////                    recRule = "RRULE:FREQ=weekly;UNTIL=\(endTime);INTERVAL=\(dict["repeatEvery"] as? String ?? "");BYDAY=\(dict["day"] as? String ?? "")"
////                }else if endOn == "after" {
////                    recRule = "RRULE:FREQ=weekly;INTERVAL=\(dict["repeatEvery"] as? String ?? "");COUNT=\(dict["Occurences"] as? String ?? "")"
////                }else{
////                    recRule = "RRULE:FREQ=weekly;UNTIL=20250628;BYDAY=\(dict["day"] as? String ?? "")"
////                    //FREQ=WEEKLY;UNTIL=20110701T170000Z
////                }
//
//            }else if selectRec == "daily"{
//                recRule = "RRULE:FREQ=\(selectRec);INTERVAL=\(dict["repeatEvery"] as? String ?? "");COUNT=\(dict["Occurences"] as? String ?? "")"
//            }else if selectRec == "monthly"{
//                recRule = "RRULE:FREQ=\(selectRec);INTERVAL=\(dict["repeatEvery"] as? String ?? "");COUNT=\(dict["Occurences"] as? String ?? "")"
//            }
//
//            calendarEvent.recurrence = [recRule]
//        }
    
        print(calendarEvent)
        
        let insertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: calendarEvent, calendarId: "primary")
        insertQuery.maxAttendees = 2
        insertQuery.supportsAttachments = false
        insertQuery.sendNotifications = true
       
       
        service.executeQuery(
            insertQuery,
            delegate: self,
            didFinish: #selector(insertGoogleEvents(ticket:finishedWithObject:error:)))
    }
    

    @objc func insertGoogleEvents(
        ticket:GTLRServiceTicket,
        finishedWithObject event:GTLRCalendar_Event,
        error:NSError?) {
        
        if error != nil {
            OBJCOM.setAlert(_title: "Error", message: "\(error!.localizedDescription)")
            return
        }else{
            
            self.createdDate = event.created
            self.updatedDate = event.updated
            self.startDate = event.start?.dateTime
            self.endDate = event.end?.dateTime

            let strStartDate = self.dateToStringG(dt: startDate.date)
            let strEndDate = self.dateToStringG(dt: endDate.date)
            let strCreated = self.dateToStringG(dt: createdDate.date)
            let strUpdated = self.dateToStringG(dt: updatedDate.date)

            var dictGoogleData = [String : Any]()
            dictGoogleData["id"] = event.identifier ?? ""
            dictGoogleData["organizer"] = event.organizer?.email ?? ""
            dictGoogleData["location"] = event.location  ?? ""
            dictGoogleData["iCalUID"] = event.iCalUID  ?? ""
            dictGoogleData["description"] = event.summary!
            dictGoogleData["htmlLink"] = event.htmlLink ?? ""
            dictGoogleData["hangoutLink"] = event.hangoutLink  ?? ""
            dictGoogleData["sequence"] = "0"
            dictGoogleData["end"] = ["dateTime":strEndDate,"timeZone":"UTC"]
            dictGoogleData["start"] = ["dateTime":strStartDate,"timeZone":"UTC"]
            dictGoogleData["summary"] = event.summary!
            dictGoogleData["creator"] = event.organizer?.email!
            dictGoogleData["kind"] = event.kind ?? ""
            dictGoogleData["reminders"] = "useDefault" as String
            dictGoogleData["created"] = strCreated
            dictGoogleData["updated"] = strUpdated
            dictGoogleData["status"] = "confirmed"
            dictGoogleData["calenderGoogle"] = "1"
            dictGoogleData["recurringEventId"] = event.recurringEventId ?? ""
            print("\n--------\n\(dictGoogleData)\n-----------")
           // DispatchQueue.main.async(execute: {
                self.apiCallAddGoogleEvent(result:dictGoogleData)
          //  })
        }
    }
    
    func apiCallAddGoogleEvent(result:[String:Any]){
        
        let jsonData = try? JSONSerialization.data(withJSONObject: result, options: [])
        let resultString = String(data: jsonData!, encoding: .utf8)
        let dictParam = ["result":resultString,
                         "user_id":userID,
                         "selection":self.eventDataForAdd["selection"],
                         "occurence":self.eventDataForAdd["occurence"],
                         "repeatBy":self.eventDataForAdd["repeatBy"],
                         "tag":self.eventDataForAdd["tag"],
                    "complete_goals":self.eventDataForAdd["complete_goals"],
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "createEventGoogleCalender", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: "\(result)")
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: "\(result)")
                OBJCOM.hideLoader()
            }
            googleSyncFlag = "sync"
            googleSync = "login"
            self.fetchEvents()
        };
    }
   
    // Helper to build date
    func buildDate(date: Date) -> GTLRCalendar_EventDateTime {
        let datetime = GTLRDateTime(date: date)
        let dateObject = GTLRCalendar_EventDateTime()
        dateObject.dateTime = datetime
        return dateObject
    }
}

//IPhone Calender
extension CalenderVC {
    
    func fetchEventsFromDeviceCalendarSync(){
        AMGCalendarManager.shared.getAllEvents(completion: { (error, result) in
            self.iCalEvents = []
            
            if result != nil {
               
                for event in result! {
                    
                    if event.eventIdentifier != nil {
                        let eventStartDate = event.startDate
                        let eventEndDate = event.endDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        let strStardDate = dateFormatter.string(from: eventStartDate!)
                        let strEndDate = dateFormatter.string(from: eventEndDate!)
                        dateFormatter.dateFormat = "HH:mm:ss"
                        dateFormatter.locale = .autoupdatingCurrent
                        let strStardTime = dateFormatter.string(from: eventStartDate!)
                        let strEndTime = dateFormatter.string(from: eventEndDate!)
                        
                        var recStr = ""
                        if event.hasRecurrenceRules {
                            // print(event.recurrenceRules?.first!.description)
                            var strFreq = ""
                            if event.recurrenceRules?.first?.frequency == .daily {
                                strFreq = "DAILY"
                            }else if event.recurrenceRules?.first?.frequency == .weekly {
                                strFreq = "WEEKLY"
                            }else if event.recurrenceRules?.first?.frequency == .monthly {
                                strFreq = "MONTHLY"
                            }else {
                                strFreq = ""
                            }
                            
                            var arrDays = [String]()
                            if let daysOfWeeks = event.recurrenceRules?.first?.daysOfTheWeek {
                                for obj in daysOfWeeks {
                                    let dayStr = self.getWeekDaysFromRecEvent(obj)
                                    arrDays.append(dayStr!)
                                }
                            }
                            
                            var day = ""
                            if arrDays.count > 0 {
                                day = arrDays.joined(separator: ",")
                            }
                            
                            recStr = "RRULE FREQ=\(strFreq);BYDAY=\(day);INTERVAL=\(event.recurrenceRules?.first?.interval ?? 1)"
                        }
                        
                        let dict = ["startDate":strStardDate,
                                    "endDate":strEndDate,
                                    "startTime":strStardTime,
                                    "endTime":strEndTime,
                                    "eventTitle":event.title,
                                    "iosCalEventId":event.eventIdentifier,
                                    "iosEventFlag":1,
                                    "iosCalenderRecurData" : recStr,
                                    "task_details":event.notes ?? ""] as [String : Any]
                        
                        self.iCalEvents.append(dict as [String:Any])
                    }
                }
                OBJCOM.hideLoader()
                print(self.iCalEvents)
            }
            
            
          //  DispatchQueue.main.async {
                if self.iCalEvents.count > 0 {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.addAppleCalEventsInDBSync(self.iCalEvents)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getCalenderDataFromServerSync()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
          //  }
            
        })
    }
    
    func addAppleCalEventsInDBSync(_ eventDetails : [[String:Any]]){
        let dictParam = ["platform": "3",
                         "userId": userID,
                         "event_details":eventDetails] as [String:AnyObject]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam as [String:AnyObject], options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:AnyObject]
        
        OBJCOM.modalAPICall(Action: "addIosEvent", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getCalenderDataFromServerSync()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
               //
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCalenderDataFromServerSync(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEventTitle = []
            self.arrEventStart = []
            self.arrEventEnd = []
            self.arrEventId = []
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                
                for obj in result {
                    self.arrEventTitle.append(obj["title"] as! String)
                    self.arrEventId.append(obj["zo_user_daily_task_id"] as! String)
                    
                    let dt = self.stringToDate(strDate: obj["original_start"] as! String)
                    let strDt = self.dateToString(dt: dt)
                    //  print(strDt)
                    self.arrEventStart.append(strDt)
                    self.arrEventEnd.append(obj["end"] as! String)
                    
                }
                OBJCOM.setAlert(_title: "", message: "iPhone calendar event(s) sync successfully.")
               // DispatchQueue.main.async {
                    self.calendarView.reloadData()
               // }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func fetchEventsFromDeviceCalendar(){
        
        AMGCalendarManager.shared.getAllEvents(completion: { (error, result) in
            self.iCalEvents = []

            if result != nil {
                for event in result! {
                    
                    if event.eventIdentifier != nil {
                        let eventStartDate = event.startDate
                        let eventEndDate = event.endDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        let strStardDate = dateFormatter.string(from: eventStartDate!)
                        let strEndDate = dateFormatter.string(from: eventEndDate!)
                        dateFormatter.dateFormat = "HH:mm:ss"
                        dateFormatter.locale = .autoupdatingCurrent
                        let strStardTime = dateFormatter.string(from: eventStartDate!)
                        let strEndTime = dateFormatter.string(from: eventEndDate!)
                        
                        var recStr = ""
                        if event.hasRecurrenceRules {
                            // print(event.recurrenceRules?.first!.description)
                            var strFreq = ""
                            if event.recurrenceRules?.first?.frequency == .daily {
                                strFreq = "DAILY"
                            }else if event.recurrenceRules?.first?.frequency == .weekly {
                                strFreq = "WEEKLY"
                            }else if event.recurrenceRules?.first?.frequency == .monthly {
                                strFreq = "MONTHLY"
                            }else {
                                strFreq = ""
                            }
                            
                            var arrDays = [String]()
                            if let daysOfWeeks = event.recurrenceRules?.first?.daysOfTheWeek {
                                for obj in daysOfWeeks {
                                    let dayStr = self.getWeekDaysFromRecEvent(obj)
                                    arrDays.append(dayStr!)
                                }
                            }
                            
                            var day = ""
                            if arrDays.count > 0 {
                                day = arrDays.joined(separator: ",")
                            }
                            
                            recStr = "RRULE FREQ=\(strFreq);BYDAY=\(day);INTERVAL=\(event.recurrenceRules?.first?.interval ?? 1)"
                        }
                        
                        let dict = ["startDate":strStardDate,
                                    "endDate":strEndDate,
                                    "startTime":strStardTime,
                                    "endTime":strEndTime,
                                    "eventTitle":event.title,
                                    "iosCalEventId":event.eventIdentifier,
                                    "iosEventFlag":1,
                                    "iosCalenderRecurData" : recStr,
                                    "task_details":event.notes ?? ""] as [String : Any]
                        
                        self.iCalEvents.append(dict as [String:Any])
                    }
                }
                print(self.iCalEvents)
                OBJCOM.hideLoader()
            }
            
            
            if self.iCalEvents.count > 0 {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    
                        self.addAppleCalEventsInDB(self.iCalEvents)
                   
                    
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
//            else{
//                if OBJCOM.isConnectedToNetwork(){
//                    OBJCOM.setLoader()
//
//                        self.getCalenderDataFromServer()
//
//                }else{
//                    OBJCOM.NoInternetConnectionCall()
//                }
//            }
            
        })
    }
    
    func addAppleCalEventsInDB(_ eventDetails : [[String:Any]]){
        let dictParam = ["platform": "3",
                         "userId": userID,
                         "event_details":eventDetails] as [String:AnyObject]
    
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam as [String:AnyObject], options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:AnyObject]

        OBJCOM.modalAPICall(Action: "addIosEvent", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                   // DispatchQueue.main.async {
                        self.getCalenderDataFromServer()
                   // }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
               
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getWeekDaysFromRecEvent(_ day:EKRecurrenceDayOfWeek) -> String?{
        switch day {
        case EKRecurrenceDayOfWeek(.sunday):
            return "SU"
        case EKRecurrenceDayOfWeek(.monday):
            return "MO"
        case EKRecurrenceDayOfWeek(.tuesday):
            return "TU"
        case EKRecurrenceDayOfWeek(.wednesday):
            return "WE"
        case EKRecurrenceDayOfWeek(.thursday):
            return "TH"
        case EKRecurrenceDayOfWeek(.friday):
            return "FR"
        case EKRecurrenceDayOfWeek(.saturday):
            return "SA"
        default:
            return ""
        }
    }
    
}

