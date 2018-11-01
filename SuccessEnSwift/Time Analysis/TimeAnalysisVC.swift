//
//  TimeAnalysisVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class TimeAnalysisVC: SliderVC {

    var strDurationId = ""
    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var lblSelectedWeeks: UILabel!
    @IBOutlet var expandableTableView : LUExpandableTableView!
    
    let cellReuseIdentifier = "MyCell"
    let sectionHeaderReuseIdentifier = "MySectionHeader"
    
    var dictDDDataWithIds = [String:String]()
    var ddOptions = ["Current Week", "Past 2 Weeks", "Past 3 Weeks", "Past 4 Weeks", "Current Month", "Past 2 months", "90 days"]
    
    var arrTimeAnalysisData = [AnyObject]()
    var arrEventName = [String]()
    var arrTotalTimeSpend  = [String]()
    var arrSummery = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Time Analysis"
        self.noDataView.isHidden = true
        self.strDurationId = "1"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        dictDDDataWithIds = ["Current Week":"1",
                             "Past 2 Weeks":"4",
                             "Past 3 Weeks":"5",
                             "Past 4 Weeks":"7",
                             "Current Month":"2",
                             "Past 2 months":"6",
                             "90 days":"3"]

        
        self.lblSelectedWeeks.text = "Time analysis for current week";
        expandableTableView.register(TimeAnalysisCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        expandableTableView.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        expandableTableView.expandableTableViewDataSource = self
        expandableTableView.expandableTableViewDelegate = self
        expandableTableView.estimatedRowHeight = 60
        expandableTableView.tableFooterView = UIView()
        expandableTableView.reloadData()
       
        uiView.addShadow(offset: CGSize.init(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.35)
        uiView.clipsToBounds = true
        
        self.dropDown.textColor = .black
        self.dropDown.tint = .black
        self.dropDown.optionsSize = 15.0
        self.dropDown.placeholder = " Current Week"
        self.dropDown.options = ddOptions
        self.dropDown.optionsTextAlignment = NSTextAlignment.left
        self.dropDown.textAlignment = NSTextAlignment.left
        self.dropDown.didSelect { (item, index) in
            let selectedOpt = self.ddOptions[index]
            if let strDur = self.dictDDDataWithIds[selectedOpt] {
                self.getTADataOnLaunch(strDuration:strDur)
            }else{
                self.getTADataOnLaunch(strDuration:"1")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.setView(view: self.noDataView, hidden: true)
                self.getTADataOnLaunch(strDuration:self.strDurationId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    //get data at the time of view launching
    func getTADataOnLaunch(strDuration:String){
        let dictParam = ["user_id": userID,
                         "duration":strDuration,
                         "platform":"3"]
        getTimeAnalysisData(action: "timeAnalysis", param: dictParam as [String : AnyObject])
    }
  
    func getTimeAnalysisData(action:String, param: [String:AnyObject]){
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:param, vcObject: self){
            JsonDict, staus in
            let success = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                self.arrTimeAnalysisData = JsonDict!["result"] as! [AnyObject]
                self.arrEventName = self.arrTimeAnalysisData.flatMap { $0["event_name"] as? String }
                self.arrTotalTimeSpend = self.arrTimeAnalysisData.flatMap { $0["total_time_spend"] as? String }
                self.arrSummery = self.arrTimeAnalysisData.flatMap { $0["summary"] as? String }
                
                if self.arrTimeAnalysisData.count > 0 {
//                    self.noDataView.isHidden = true
//                    self.noDataView.layoutIfNeeded()
                    self.setView(view: self.noDataView, hidden: true)
                    
                }else{
                    self.setView(view: self.noDataView, hidden: false)
//                    self.noDataView.isHidden = false
//                    self.noDataView.layoutIfNeeded()
                }
                self.expandableTableView.reloadData()
                OBJCOM.hideLoader()
            }else{
                print(JsonDict!)
                OBJCOM.hideLoader()
                self.setView(view: self.noDataView, hidden: false)
                //self.noDataView.isHidden = false
               // self.noDataView.layoutIfNeeded()
            }
        };
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}

// MARK: - LUExpandableTableViewDataSource
extension TimeAnalysisVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return self.arrEventName.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "Cell") as? TimeAnalysisCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        cell.lblTotalTimeSpend.text = "Total time spend (hh:mm) : \(self.arrTotalTimeSpend[indexPath.section])";
        cell.lblSummery.text = "Summary : \(self.arrSummery[indexPath.section])";
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "MySectionHeader") as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        sectionHeader.label.text =  self.arrEventName[section]

        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension TimeAnalysisVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    
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
