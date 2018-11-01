//
//  WeeklyTrackingVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 07/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class WeeklyTrackingVC: SliderVC {

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
        self.title = "Weekly Tracking"
        self.noDataView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
    func getWTDataOnLaunch(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        getWeeklyTrackingData(action: "trackingIos", param: dictParam as [String : AnyObject])
    }
    //get data after week selection
    func getWTDataOnWeekSelection(weekID:String){
        let dictParam = ["user_id": userID,
                         "week_id" : weekID,
                         "platform":"3"]
        getWeeklyTrackingData(action: "indWeekDetails", param: dictParam as [String : AnyObject])
    }
    
    func getWeeklyTrackingData(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.noDataView.isHidden = true
                self.arrWeeklyTrackingData = JsonDict!["goal_details"] as! [AnyObject]
                if action == "trackingIos"{
                    self.arrDropDownData = JsonDict!["week"] as! [AnyObject]
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
                        print(arrWeekId.count)
                        print(arrDdTitle.count)
                        print(arrWeekId)
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
                }
             
                let tScore = JsonDict!["total_score"] as AnyObject
                self.lblTotalScore.text = "Total score \(tScore)"
                
                if self.arrWeeklyTrackingData.count > 0 {
                    self.arrGoalName = self.arrWeeklyTrackingData.compactMap { $0["goal_name"] as AnyObject }
                    self.arrRemainingGoals = self.arrWeeklyTrackingData.compactMap { $0["remaining_goals"] as AnyObject }
                    self.arrGoalCount = self.arrWeeklyTrackingData.compactMap { $0["goal_count"] as AnyObject }
                    self.arrGoalDoneCount = self.arrWeeklyTrackingData.compactMap { $0["user_done_goal_count"] as AnyObject }
                    self.arrRemainGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["remainingGoalsfor90Days"] as AnyObject }
                    self.arrCompleGoalsfor90Days = self.arrWeeklyTrackingData.compactMap { $0["completedGoalsfor90Days"] as AnyObject }
                    self.expandableTableView.reloadData()
                }
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                self.noDataView.isHidden = false
                self.lblTotalScore.text = "Total score 0.00"
                OBJCOM.hideLoader()
//                let result = JsonDict!["goal_details"] as! String
//                OBJCOM.setAlert(_title: "", message: result)
            }
        };
    }
}



// MARK: - LUExpandableTableViewDataSource
extension WeeklyTrackingVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int { return self.arrWeeklyTrackingData.count }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyTableViewCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        cell.lblWeeklyGoals.text = "Completed goals : \(self.arrGoalDoneCount[indexPath.section])";
        cell.lblGoalCount.text = "Remaining goals : \(self.arrRemainingGoals[indexPath.section])";
        cell.lblScore.text = "Remaining goals for 90 days : \(self.arrRemainGoalsfor90Days[indexPath.section])";
        cell.lblRemainingGoalCount.text = "Completed goals for 90 days : \(self.arrCompleGoalsfor90Days[indexPath.section])";
        
       /* if indexPath.section%2 != 0 {
            cell.backgroundColor = UIColor(red:0.90, green:0.91, blue:0.91, alpha:1.0)
        }else{cell.backgroundColor = .white}*/
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "MySectionHeader") as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        sectionHeader.label.text = self.arrGoalName[section] as? String ?? ""
     /*   if section%2 != 0 {
            sectionHeader.bgView.backgroundColor = UIColor(red:0.90, green:0.91, blue:0.91, alpha:1.0)
        }else{sectionHeader.bgView.backgroundColor = .white}*/
        
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension WeeklyTrackingVC: LUExpandableTableViewDelegate {
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

