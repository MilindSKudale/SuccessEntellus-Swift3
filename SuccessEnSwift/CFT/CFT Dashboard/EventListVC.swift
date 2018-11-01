//
//  EventListVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EventListVC: UIViewController {

    @IBOutlet var tblTaskList : UITableView!
    @IBOutlet var noEventView : UIView!
    @IBOutlet var selectedDate : String!
    
    var arrEvent = [AnyObject]()
    var arrEventId = [String]()
    var arrEventName = [String]()
    var arrEventDetails = [String]()
    var arrStartTime = [String]()
    var arrEndTime = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblTaskList.tableFooterView = UIView()
        tblTaskList.rowHeight = UITableViewAutomaticDimension
        tblTaskList.estimatedRowHeight = 100.0
        self.noEventView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if selectedCFTUser == "" {
            return
        }
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTaskListFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getTaskListFromServer(){
        let dictParam = ["user_id": selectedCFTUser,
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

extension EventListVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEvent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblTaskList.dequeueReusableCell(withIdentifier: "EventListCell") as! EventListCell
        
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
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension EventListVC {
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
}
