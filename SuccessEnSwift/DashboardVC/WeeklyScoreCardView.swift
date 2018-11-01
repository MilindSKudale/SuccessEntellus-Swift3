//
//  WeeklyScoreCardView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class WeeklyScoreCardView: UIViewController {
    
    @IBOutlet var expandableTableView : LUExpandableTableView!
    let cellReuseIdentifier = "MyCell"
    let sectionHeaderReuseIdentifier = "MySectionHeader"
    
    @IBOutlet var noDataView : UIView!
    @IBOutlet var lblTotalScore : UILabel!
    
    var arrScoreCardData = [AnyObject]()
    var arrGoalName = [String]()
    var arrGoalScore = [AnyObject]()
    var arrRemainingGoals = [AnyObject]()
    var arrGoalCount = [String]()
    var arrGoalDoneCount = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTotalScore.text = ""
        self.noDataView.isHidden = true
        self.title = "Dashboard"
        expandableTableView.register(MyTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        expandableTableView.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        expandableTableView.expandableTableViewDataSource = self
        expandableTableView.expandableTableViewDelegate = self
        expandableTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getChecklistDashboard()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    func getChecklistDashboard(){
        let dictParam = ["user_id": userID]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getWeeklyScoreDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                self.noDataView.isHidden = true
                self.arrScoreCardData = JsonDict!["result"] as! [AnyObject];
                let totalScore = "\(JsonDict!["total_score"] as! NSNumber)"
                //let formatted = String(format: "%.3f", totalScore)
                self.lblTotalScore.text = "Total score : \(totalScore)"
                
                
                
                self.arrGoalName = self.arrScoreCardData.flatMap { $0["goal_name"] as? String }
                self.arrGoalScore = self.arrScoreCardData.flatMap { $0["goal_score"] as? AnyObject }
                self.arrRemainingGoals = self.arrScoreCardData.flatMap { $0["remaining_goals"] as? AnyObject }
                self.arrGoalCount = self.arrScoreCardData.flatMap { $0["goal_count"] as? String }//
                self.arrGoalDoneCount = self.arrScoreCardData.flatMap { $0["goal_done_count"] as? AnyObject }
                self.expandableTableView.reloadData()
            }else{
                self.lblTotalScore.text = "Total score : 0.00"
                self.noDataView.isHidden = false
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
}

// MARK: - LUExpandableTableViewDataSource
extension WeeklyScoreCardView: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int { return self.arrGoalName.count }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyTableViewCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        cell.lblWeeklyGoals.text = "My weekly goals :\(self.arrGoalCount[indexPath.section])";
        cell.lblGoalCount.text = "My completed goals :\(self.arrGoalDoneCount[indexPath.section])";
        cell.lblScore.text = "My score :\(self.arrGoalScore[indexPath.section])";
        cell.lblRemainingGoalCount.text = "My remaining goals :\(self.arrRemainingGoals[indexPath.section])";

        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "MySectionHeader") as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        sectionHeader.label.text = self.arrGoalName[section]
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension WeeklyScoreCardView: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 100 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat { return 44 }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select section header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
}

