//
//  TaskListVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import AMGCalendarManager
import EventKit


let arrColor = [UIColor(red:0.09, green:0.56, blue:0.24, alpha:1.0),
                UIColor(red:0.00, green:0.51, blue:0.66, alpha:1.0),
                UIColor(red:0.73, green:0.11, blue:0.08, alpha:1.0),
                UIColor(red:0.15, green:0.14, blue:0.56, alpha:1.0)]
class TaskListVC: UIViewController {

    @IBOutlet var tblTaskList : UITableView!
    @IBOutlet var noEventView : UIView!
    @IBOutlet var selectedDate : String!
    
    var arrEvent = [AnyObject]()
    var arrEventId = [String]()
    var arrEventName = [String]()
    var arrEventDetails = [String]()
    var arrStartTime = [String]()
    var arrEndTime = [String]()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblTaskList.tableFooterView = UIView()
        tblTaskList.rowHeight = UITableViewAutomaticDimension
        tblTaskList.estimatedRowHeight = 100.0
        self.noEventView.isHidden = true
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTaskListFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getTaskListFromServer(){
        let dictParam = ["user_id": userID,
                         "from_date":self.selectedDate]
        
        OBJCOM.modalAPICall(Action: "getEventListByDate", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEvent = []
            self.arrEventName = []
            self.arrEventDetails = []
            self.arrStartTime = []
            self.arrEndTime = []
            self.arrEventId = []
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]

                for obj in result {
                    self.arrEvent.append(obj)
                    self.arrEventName.append(obj["goal_name"] as! String)
                    self.arrEventDetails.append(obj["task_details"] as! String)
                    self.arrStartTime.append(obj["task_fromdt"] as! String)
                    self.arrEndTime.append(obj["task_todt"] as! String)
                    self.arrEventId.append(obj["edit_id"] as! String)
                }
                self.noEventView.isHidden = true
                OBJCOM.hideLoader()
            }else{
                self.noEventView.isHidden = false
                OBJCOM.hideLoader()
            }
            self.tblTaskList.reloadData()
        };
    }

    @IBAction func actionCancel(_ sender : UIButton){
       //UpdateCalender
        NotificationCenter.default.post(name: Notification.Name("UpdateCalender"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension TaskListVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEvent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblTaskList.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskListCell
        
        cell.lblEventName.text = self.arrEventName[indexPath.row]
        cell.lblEventDetails.text = self.arrEventDetails[indexPath.row]
        
        let st = self.stringToDate(strDate: self.arrStartTime[indexPath.row])
        let strSt = self.dateToString(dt: st)
        
        let et = self.stringToDate(strDate: self.arrEndTime[indexPath.row])
        let strEt = self.dateToString(dt: et)
        
        cell.lblStartTime.text = strSt
        cell.lblEndTime.text = strEt
        
        if (indexPath.row % 4 == 0){
            cell.uiView.backgroundColor = arrColor[0]
        }else if (indexPath.row % 4 == 1){
            cell.uiView.backgroundColor = arrColor[1]
        }else if (indexPath.row % 4 == 2){
            cell.uiView.backgroundColor = arrColor[2]
        }else if (indexPath.row % 4 == 3){
            cell.uiView.backgroundColor = arrColor[3]
        } else {
            cell.uiView.backgroundColor = UIColor.white
        }
        
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        cell.btnDelete.addTarget(self, action: #selector(deleteEvent(_ :)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editEvent(_ :)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
  
}

extension TaskListVC {
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
    //
    @objc func editEvent(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.EditTaskList),
            name: NSNotification.Name(rawValue: "EditTaskList"),
            object: nil)
        let storyboard = UIStoryboard(name: "Calender", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditEventTVC") as! EditEventTVC
        vc.eventData = self.arrEvent[sender.tag] as! [String:AnyObject]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func EditTaskList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTaskListFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func deleteEvent(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.EditTaskList),
            name: NSNotification.Name(rawValue: "EditTaskList"),
            object: nil)
        
        let eventData = self.arrEvent[sender.tag]
        let googleCalEventFlag = "\(eventData["googleCalEventFlag"] as AnyObject)"
        let googleCalRecurEventId = "\(eventData["googleCalRecurEventId"] as AnyObject)"
        let googleCalEventId = "\(eventData["googleCalEventId"] as AnyObject)"
        let randomNumber = "\(eventData["randomNumber"] as AnyObject)"
        let editId = "\(eventData["edit_id"] as AnyObject)"
        let isAppleEvent = "\(eventData["iosEventFlag"] as AnyObject)"
        
        print(googleCalEventFlag, googleCalRecurEventId, randomNumber)
        
        if googleCalEventFlag != "0" {
            
            if googleCalRecurEventId != ""{
                let dict = ["eventEditId":editId,
                            "googleEventFlag":googleCalEventFlag,
                            "recurringEventId":googleCalRecurEventId,
                            "RandomNumberValue":randomNumber,
                            "googleCalEventId":googleCalEventId]
                
                let storyboard = UIStoryboard(name: "Calender", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idDeleteRecurringEvent") as! DeleteRecurringEvent
                //vc.eventData = self.arrEvent[sender.tag] as! [String:AnyObject]
                vc.eventData = dict
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }
        }else{
            
            if randomNumber != "" && randomNumber != "0"{
                //DeleteMultiEventsActionSheet(index : sender.tag)
                let dict = ["eventEditId":editId,
                            "googleEventFlag":googleCalEventFlag,
                            "recurringEventId":googleCalRecurEventId,
                            "RandomNumberValue":randomNumber,
                            "googleCalEventId":googleCalEventId]
                
                let storyboard = UIStoryboard(name: "Calender", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idDeleteRecurringEvent") as! DeleteRecurringEvent
                //vc.eventData = self.arrEvent[sender.tag] as! [String:AnyObject]
                vc.eventData = dict
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }else if isAppleEvent == "1" {
                let recString = eventData["iosCalenderRecurData"] as? String ?? ""
                if recString == "" {
                    self.deleteSingleEvent(index : sender.tag)
                }else{
                    self.DeleteMultiEventsActionSheet(index : sender.tag)
                }
               
            }else{
                deleteSingleEvent(index : sender.tag)
            }
        }
    }
    
    func deleteSingleEvent(index:Int){
        
        let eventData = self.arrEvent[index]
        let iosEventId = "\(eventData["iosCalEventId"] as AnyObject)"
        let alertController = UIAlertController(title: "", message: "Do you want to delete '\(self.arrEventName[index])' event", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                let dictParam = ["user_id": userID,
                                 "edit_id":self.arrEventId[index]]

                OBJCOM.modalAPICall(Action: "deleteEvent", param:dictParam as [String : AnyObject],  vcObject: self){
                    JsonDict, staus in
                    let success:String = JsonDict!["IsSuccess"] as! String
                    if success == "true"{
                        let result = JsonDict!["result"] as AnyObject
                        OBJCOM.hideLoader()
                        OBJCOM.setAlert(_title: "", message: result as! String)
                        
//                        let st = self.stringToDate(strDate: self.arrStartTime[index])
//                        let et = self.stringToDate(strDate: self.arrEndTime[index])
                        do {
                            if let event = self.eventStore.event(withIdentifier: iosEventId){
                                try self.eventStore.remove(event, span: .thisEvent, commit: true)
                            }
                        } catch {

                        }
                        
                        if OBJCOM.isConnectedToNetwork(){
                            OBJCOM.setLoader()
                            self.getTaskListFromServer()
                        }else{
                            OBJCOM.NoInternetConnectionCall()
                        }
                    }else{
                        print("result:",JsonDict ?? "")
                        OBJCOM.hideLoader()
                    }
                };
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func DeleteMultiEventsActionSheet(index : Int){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let actionSupport = UIAlertAction(title: "Delete this event only", style: .default)
        {
            UIAlertAction in
            
            self.deleteSingleEvent(index : index)
        }
        actionSupport.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionFeedback = UIAlertAction(title: "Delete all future events", style: .default)
        {
            UIAlertAction in
            self.deleteAllMultiEvents(index:index)
        }
        actionFeedback.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(actionSupport)
        alert.addAction(actionFeedback)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAllMultiEvents(index:Int){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()

            let eventData = self.arrEvent[index]
            let googleCalEventFlag = "\(eventData["googleCalEventFlag"] as AnyObject)"
            let randomNumber = "\(eventData["randomNumber"] as AnyObject)"
            let editId = "\(eventData["edit_id"] as AnyObject)"
            let iosEventId = "\(eventData["iosCalEventId"] as AnyObject)"
            
//            dictParam["iosEventFlag"] = isAppleEvent
//            dictParam["iosCalEventId"] = eventData["iosCalEventId"] as? String ?? ""
//            dictParam["iosCalenderRecurData"] = eventData["iosCalenderRecurData"] as? String ?? ""

            let dictParam = ["user_id": userID,
                             "edit_id":editId,
                             "repeatValue": randomNumber,
                             "googleflag":googleCalEventFlag]

            OBJCOM.modalAPICall(Action: "deleteRecurringEventDBRandom", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as AnyObject
                    OBJCOM.hideLoader()
                    OBJCOM.setAlert(_title: "", message: result as! String)
                    
                    do {
                        if let event = self.eventStore.event(withIdentifier: iosEventId) {
                            try self.eventStore.remove(event, span: .futureEvents, commit: true)
                        }
                    } catch {
                        
                    }
                    
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getTaskListFromServer()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

