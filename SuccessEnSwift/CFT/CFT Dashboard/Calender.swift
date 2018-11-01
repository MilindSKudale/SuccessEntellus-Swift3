//
//  Calender.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import FSCalendar


class Calender: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    
    var arrEventTitle = [String]()
    var arrEventStart = [String]()
    var arrEventEnd = [String]()
    var arrEventId = [String]()
    var eventData = [Data]()
    var allEvents = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CFT Dashboard"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadView),
            name: NSNotification.Name(rawValue: "ReloadView"),
            object: nil)
        
       user = "cft"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if selectedCFTUser == "" {
            return
        }
        DispatchQueue.main.async {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getCalenderDataFromServer()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @objc func reloadView(notification: NSNotification){
        if selectedCFTUser == "" {
            return
        }
        DispatchQueue.main.async {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getCalenderDataFromServer()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        DispatchQueue.main.async {
            let dateString = self.dateToString(dt: date)
            if self.arrEventStart.contains(dateString) || self.arrEventEnd.contains(dateString){
                let storyboard = UIStoryboard(name: "CFT", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idEventListVC") as! EventListVC
                vc.selectedDate = self.dateToString(dt: date)
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: false, completion: nil)
            }
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateString = self.dateToString(dt: date)
        if self.arrEventStart.contains(dateString) || self.arrEventEnd.contains(dateString){
            return 1
        }
        
        return 0
    }
}

extension Calender {
    
    func getCalenderDataFromServer(){
        let dictParam = ["user_id": selectedCFTUser,
                         "platform":"3"]
        
        OBJCOM.modalAPICall(Action: "getCalendarData", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            self.arrEventTitle = []
            self.arrEventStart = []
            self.arrEventEnd = []
            self.arrEventId = []
            self.allEvents = []
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                
                for obj in result {
                    self.allEvents.append(obj)
                    self.arrEventTitle.append(obj["title"] as! String)
                    self.arrEventId.append(obj["zo_user_daily_task_id"] as! String)
                    
                    let sdt = self.stringToDate(strDate: obj["start"] as! String)
                    let edt = self.stringToDate(strDate: obj["end"] as! String)
                    let strDt = self.dateToString(dt: sdt)
                    let endDt = self.dateToString(dt: edt)
                  //  print(strDt)
                    self.arrEventStart.append(strDt)
                    self.arrEventEnd.append(endDt)
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            DispatchQueue.main.async {
                self.calendarView.dataSource = self
                self.calendarView.delegate = self
                self.calendarView.reloadData()
            }
        };
    }
}

extension Calender {
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dt)
    }
}
