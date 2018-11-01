//
//  CurrentWeekSummery.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class CurrentWeekSummery: UIViewController {
    
    var arrGoalName = [AnyObject]()
    var arrRemainingGoals = [AnyObject]()
    var arrGoalCount = [AnyObject]()
    var arrGoalDoneCount = [AnyObject]()
    var arrRemainGoalsfor90Days = [AnyObject]()
    var arrCompleGoalsfor90Days = [AnyObject]()
    var arrDropDownData = [AnyObject]()
    var arrWeeklyTrackingData = [AnyObject]()
    
    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var lblSelectedWeeks: UILabel!
    @IBOutlet weak var lblTotalScore: UILabel!
    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet var expandableTableView : LUExpandableTableView!
    let cellReuseIdentifier = "MyCell"
    let sectionHeaderReuseIdentifier = "MySectionHeader"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.isHidden = true
        user = "cft"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getCFTLaunch),
            name: NSNotification.Name(rawValue: "GetCFTData"),
            object: nil)
        
        self.lblSelectedWeeks.text = "Current week's tracking details";
        expandableTableView.register(MyTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        expandableTableView.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        expandableTableView.expandableTableViewDataSource = self
        expandableTableView.expandableTableViewDelegate = self
        expandableTableView.tableFooterView = UIView()
        uiView.addShadow(offset: CGSize.init(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.35)
        uiView.clipsToBounds = true
        
        self.dropDown.textColor = .black
        self.dropDown.tint = .black
        self.dropDown.optionsSize = 15.0
        self.dropDown.placeholder = " Current Week"
        self.dropDown.optionsTextAlignment = NSTextAlignment.left
        self.dropDown.textAlignment = NSTextAlignment.left
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getWTDataOnLaunch()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @objc func getCFTLaunch(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getWTDataOnLaunch()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    //get data at the time of view launching
    public func getWTDataOnLaunch(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "fromUserId": selectedCFTUser]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        if selectedCFTUser == "" {
            return
        }
        getWeeklyTrackingData(action: "getCftCheckList", param: dictParamTemp as [String : AnyObject])
    }
    //get data after week selection
    public func getWTDataOnWeekSelection(weekID:String){
        let dictParam = ["userId": userID,
                         "weekId" : weekID,
                         "platform":"3",
                         "fromUserId": selectedCFTUser]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        if selectedCFTUser == "" {
            return
        }
        getDataAfterWeekSelection(action: "getCftIndWeek", param: dictParamTemp as [String : AnyObject])
    }
    
    func getWeeklyTrackingData(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.noDataView.isHidden = true
                let trackingData = JsonDict!["trackingDetails"] as! [String:AnyObject]
                
                self.arrWeeklyTrackingData = trackingData["goal_details"] as! [AnyObject]
                self.arrDropDownData = trackingData["week"] as! [AnyObject]
                
                if self.arrDropDownData.count > 0{
                    var arrDdTitle = [String]()
                    var arrWeekId = [String]()
                    arrDdTitle.append("Current week")
                    arrWeekId.append("0")
                    for i in 0..<self.arrDropDownData.count{
                        let a = self.arrDropDownData[i]["week_name"] ?? ""
                        let b = self.arrDropDownData[i]["week_start_date"] ?? ""
                        let c = self.arrDropDownData[i]["week_end_date"] ?? ""
                        let str = " \(a!) (\(b!) To \(c!))"
                        arrDdTitle.append(str)
                        arrWeekId.append(self.arrDropDownData[i]["week_id"] as! String)
                    }
                    self.dropDown.options = arrDdTitle
                    self.dropDown.didSelect { (option, index) in
                        if arrWeekId[index] == "0" {
                            self.lblSelectedWeeks.text = "Current week's tracking details";
                            self.dropDown.placeholder = " Current Week"
                            self.getWTDataOnLaunch()
                        }else{
                            self.lblSelectedWeeks.text = "\(arrDdTitle[index])";
                            let week_id = arrWeekId[index]
                            self.getWTDataOnWeekSelection(weekID:week_id)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
              
                
                let tScore = trackingData["total_score"] as AnyObject
                self.lblTotalScore.text = "Total score is \(tScore)"
                
                if self.arrWeeklyTrackingData.count > 0 {
                    self.arrGoalName = self.arrWeeklyTrackingData.compactMap { $0["goal_name"] as AnyObject }
                    self.arrRemainingGoals = self.arrWeeklyTrackingData.compactMap { $0["remaining_goals"] as AnyObject }
                    self.arrGoalCount = self.arrWeeklyTrackingData.compactMap { $0["goal_count"] as AnyObject }
                    self.arrGoalDoneCount = self.arrWeeklyTrackingData.compactMap { $0["user_done_goal_count"] as AnyObject }
                    self.arrRemainGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["remainingGoalsfor90Days"] as AnyObject }
                    self.arrCompleGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["completedGoalsfor90Days"] as AnyObject }
                }
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                self.noDataView.isHidden = false
                self.lblTotalScore.text = "Total score : 0.00"
                OBJCOM.hideLoader()
            }
            self.expandableTableView.reloadData()
        };
    }
    
    func getDataAfterWeekSelection(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.noDataView.isHidden = true
                let trackingData = JsonDict!["trackingDetails"] as! [String:AnyObject]
                self.arrWeeklyTrackingData = trackingData["details"] as! [AnyObject]
            
                
                
                if self.arrWeeklyTrackingData.count > 0 {
                    self.arrGoalName = self.arrWeeklyTrackingData.compactMap { $0["goal_name"] as AnyObject }
                    self.arrRemainingGoals = self.arrWeeklyTrackingData.compactMap { $0["remaining_goals"] as AnyObject }
                    self.arrGoalCount = self.arrWeeklyTrackingData.compactMap { $0["goal_count"] as AnyObject }
                    self.arrGoalDoneCount = self.arrWeeklyTrackingData.compactMap { $0["user_done_goal_count"] as AnyObject }
                    self.arrRemainGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["remainingGoalsfor90Days"] as AnyObject }
                    self.arrCompleGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["completedGoalsfor90Days"] as AnyObject }
                   
                }
                
                if self.arrWeeklyTrackingData.count == 0 {
                    self.noDataView.isHidden = false
                    self.lblTotalScore.text = "Total score : 0.00"
                }else{
                    self.noDataView.isHidden = true
                    let tScore = trackingData["total_score"] as AnyObject
                    self.lblTotalScore.text = "Total score is \(tScore)"
                }
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                self.noDataView.isHidden = false
                self.lblTotalScore.text = "Total score : 0.00"
                OBJCOM.hideLoader()
                
            }
             self.expandableTableView.reloadData()
        };
    }
}


// MARK: - LUExpandableTableViewDataSource
extension CurrentWeekSummery: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int { return self.arrWeeklyTrackingData.count }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyTableViewCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        if self.arrGoalDoneCount[indexPath.section] as! String == "" {
            cell.lblWeeklyGoals.text = "Completed goals : 0";
        }else{
            cell.lblWeeklyGoals.text = "Completed goals : \(self.arrGoalDoneCount[indexPath.section] as! String)";
        }
        
        cell.lblGoalCount.text = "Remaining goals :\(self.arrRemainingGoals[indexPath.section])";
        cell.lblScore.text = "Remaining goals for 90 days :\(self.arrRemainGoalsfor90Days[indexPath.section])";
        cell.lblRemainingGoalCount.text = "Completed goals for 90 days :\(self.arrCompleGoalsfor90Days[indexPath.section])";
        
       
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "MySectionHeader") as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        sectionHeader.label.text = self.arrGoalName[section] as? String ?? ""
       
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension CurrentWeekSummery: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 100 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat { return 44.0 }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        //print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        //print("Did select section header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //  print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        //print("Will display section header for section \(section)")
    }
}



