//
//  DailyChecklistView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import EAIntroView
import EAIntroView

var currDay = ""
var currDate = ""

class DailyChecklistView: SliderVC, TableViewReorderDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EAIntroDelegate {
    
    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet weak var btnShowHiddenGoals: UIButton!
    @IBOutlet weak var btnSubmitGoals: UIButton!
    @IBOutlet weak var tblChecklist: UITableView!
    @IBOutlet weak var tblChecklistHeight: NSLayoutConstraint!
    @IBOutlet weak var uiView: UIView!
    
   // var subFlag = 1
    var moduleId = "1"
    
    var arrGoalName = [String]()
    var arrDefaultValues = [String]()
    var arrDayValues = [String]()
    var arrDateValues = [String]()
    var arrchecklistData = [AnyObject]()
    var showIconFlag = 0;
    var currentDayName = ""
    var selectedDate = ""
    var submitFlag = ""
    var dictTxtValues = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSubmitGoals.layer.cornerRadius = 5.0
        btnShowHiddenGoals.layer.cornerRadius = 5.0
        tblChecklist.delegate = self;
        tblChecklist.dataSource = self;
        tblChecklist.allowsSelection = false
        tblChecklistHeight.constant = 300.0
        tblChecklist.tableFooterView = UIView()
        tblChecklist.reorder.delegate = self
        tblChecklist.reorder.cellOpacity = 0.7
        tblChecklist.reorder.cellScale = 1.05
        tblChecklist.reorder.shadowOpacity = 0.5
        tblChecklist.reorder.shadowRadius = 20
        tblChecklist.reorder.shadowOffset = CGSize(width: 0, height: 10)
        
        self.dropDown.borderColor = .white
        self.dropDown.cornerRadius = 5.0
        self.dropDown.textColor = .white
        self.dropDown.options = self.arrDayValues
        // self.dropDown.optionsFont = "Raleway-Bold"
        self.dropDown.optionsSize = 15.0
        self.dropDown.optionsTextAlignment = NSTextAlignment.center
    }
    
    func createIntroductionView(){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "page1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "page2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "page3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "page4")
        let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "page5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage2!,ingropage3!,ingropage4!, ingropage5!, ingropage1!])
        introView?.delegate = self
        
        introView?.show(in: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
    }
    
    @IBAction func actionMenu(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionWeeklyArchive = UIAlertAction(title: "Help", style: .default)
        {
            UIAlertAction in
            self.createIntroductionView()
        }
        actionWeeklyArchive.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionWeeklyArchive)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionSubmitGoals(sender: UIButton) {
        
        if sender.titleLabel?.text == "Submit"{
            submitFlag = "submit"
        }else if sender.titleLabel?.text == "Edit & Submit"{
            submitFlag = "edit"
        }
       
        print(dictTxtValues)
//        let arrVal = dictTxtValues.values
        
        let set = NSSet(array: Array(dictTxtValues.values))
        if(set.count == 1) {
            let myObj = set.anyObject() as! String?
            let equalTo = "0"
            if  myObj == equalTo {
                OBJCOM.setAlert(_title: "", message: "Please fill up checklist count.")
                return
            }
        }
        
    
        
        if let _ = dictTxtValues["0"] {
           dictTxtValues.removeValue(forKey: "0")
        }
        if let _ = dictTxtValues["5"] {
            dictTxtValues.removeValue(forKey: "5")
        }
        if self.arrDayValues.count > 0 {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.SubmitCheckListData(flag:self.submitFlag, dict: self.dictTxtValues)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Your business is not started yet.")
        }
    
    }
    
    func SubmitCheckListData(flag:String, dict:[String:String]){
        let jsonDataStr = try? JSONSerialization.data(withJSONObject: dict, options: [])
        var strGoal = String(data: jsonDataStr!, encoding: .utf8)
        strGoal = strGoal?.replacingOccurrences(of: "{", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "}", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "\"", with: "")
        strGoal = strGoal?.replacingOccurrences(of: "\n", with: "")
        strGoal = strGoal?.replacingOccurrences(of: " ", with: "")
        let dictParam = ["user_id": userID,
                         "submitdate": self.selectedDate,
                         "goalstr": strGoal,
                         "flag": flag]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "submitUpdateChecklistIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                if OBJCOM.isConnectedToNetwork(){
                    DispatchQueue.main.async {
                        //self.getDropDownData()
                        if self.dropDown.placeholder == "Today (\(currDay))" {
                            self.getChecklistDashboard()
                        }else{
                            self.updateChecklistDashboard(date: self.selectedDate)
                        }
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionShowHiddenGoals(sender: UIButton) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadChecklist),
            name: NSNotification.Name(rawValue: "ReloadChecklist"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idShowHideGoalsVC") as! ShowHideGoalsVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func reloadChecklist(notification: NSNotification){
        DispatchQueue.main.async {
            self.getChecklistDashboard()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getDropDownData()
                self.getChecklistDashboard()
//                let moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
//                if moduleIds.contains(self.moduleId) {
//                    if let vc = UIStoryboard(name: "Packages", bundle: nil).instantiateViewController(withIdentifier: "idPackagesFilterVC") as? PackagesFilterVC {
//
//                        let bizVC = BIZPopupViewController.init(contentViewController: vc, contentSize: CGSize(width: self.view.frame.width - 30, height: 300))
//                        bizVC?.showDismissButton = true
//                        self.present(bizVC!, animated: false, completion: nil)
//                    }
//                }
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getDropDownData(){
        let dictParam = ["user_id": userID]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getalldates", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                let arrCurrentDay = dictJsonData.value(forKey: "currentDay") as! [String]
                self.arrDayValues = dictJsonData.value(forKey: "dayName") as! [String]
                self.arrDateValues = dictJsonData.value(forKey: "date") as! [String]
                
                for i in 0..<arrCurrentDay.count{
                    if arrCurrentDay[i] == "curr" {
                        self.dropDown.placeholder = "Today (\(self.arrDayValues[i]))"
                        currDay = self.arrDayValues[i]
                        currDate = self.arrDateValues[i]
                        
                        self.dropDown.currentDay = self.arrDayValues[i]
                        self.btnSubmitGoals.setTitle("Submit", for: .normal)
                    }
                }
                self.arrDateValues.insert(currDate, at:0)
                self.arrDayValues.insert("Today", at:0)
                self.selectedDate = self.arrDateValues[0]
                self.dropDown.options = self.arrDayValues
                self.dropDown.didSelect { (option, index) in
                    print("You just select: \(option) at index: \(index)")
                    self.selectedDate = self.arrDateValues[index]
                    let dt = Date();
                    print(dt)
                    let dateString = self.selectedDate
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from: dateString)
                    if Date().compare(date!) == ComparisonResult.orderedAscending {
                        self.dropDown.placeholder = "Today (\(currDay))"
                        self.getChecklistDashboard()
                        OBJCOM.setAlert(_title: "", message: "Future week days not allowed to select.")
                    }else if Date().compare(date!) == ComparisonResult.orderedDescending || Date().compare(date!) == ComparisonResult.orderedSame {
                        if self.arrDayValues[index] == "Today"{
                            self.dropDown.placeholder = "Today (\(currDay))"
                            self.getChecklistDashboard()
                        }else{
                            self.dropDown.placeholder = self.arrDayValues[index]
                            self.updateChecklistDashboard(date: self.selectedDate)
                        }
                        
                        if(currDay == self.arrDayValues[index]){
                            self.btnSubmitGoals.setTitle("Edit & Submit", for: .normal)
                        }else if self.arrDayValues[index] == "Today" {
                            self.btnSubmitGoals.setTitle("Submit", for: .normal)
                        }else{
                            self.btnSubmitGoals.setTitle("Edit & Submit", for: .normal)
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func GetDateFromString(DateStr: String) -> Date {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let DateArray = DateStr.components(separatedBy: "-")
        let components = NSDateComponents()
        components.year = Int(DateArray[2])!
        components.month = Int(DateArray[1])!
        components.day = Int(DateArray[0])!
        components.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = calendar?.date(from: components as DateComponents)

        return date!
    }
    
    func getChecklistDashboard(){
        let dictParam = ["user_id": userID]
        OBJCOM.modalAPICall(Action: "showChecklistDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let business_start = JsonDict!["business_start"] as! String
                UserDefaults.standard.set(business_start, forKey: "BUSY_START_DATE")
                self.showIconFlag = JsonDict!["showIconFlag"] as! Int
                self.currentDayName = JsonDict!["currentDayName"] as! String
                self.arrchecklistData = JsonDict!["result"] as! [AnyObject];
                self.tblChecklistHeight.constant = CGFloat(self.arrchecklistData.count*47)
                self.tblChecklist.reloadData()
            }else{
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
    
    func updateChecklistDashboard(date:String){
        
        let dictParam = ["user_id": userID, "date":date]
        OBJCOM.modalAPICall(Action: "updateChecklistDashboard", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                self.showIconFlag = JsonDict!["showIconFlag"] as! Int
                self.arrchecklistData = JsonDict!["result"] as! [AnyObject]
                self.tblChecklist.reloadData()
            }else{
                OBJCOM.hideLoader()
                print("result:",JsonDict ?? "")
            }
        };
    }
}

extension DailyChecklistView {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrchecklistData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChecklistTableViewCell
        
        if self.showIconFlag == 1 {
            cell.btnHideGoals.isHidden = false;
            cell.btnHideGoals.tag = indexPath.row;
            cell.txtCompletedGoal.tag = indexPath.row;
            
            if currDay == self.currentDayName{
                let cumplusoryFlag = arrchecklistData[indexPath.row]["cumplusoryFlag"] as? String ?? "0";
                if cumplusoryFlag == "1"{
                    cell.btnHideGoals.setImage(#imageLiteral(resourceName: "unhide_ic"), for: .normal)
                }else{
                    cell.btnHideGoals.setImage(#imageLiteral(resourceName: "hide_ic"), for: .normal)
                }
            }else{
                cell.btnHideGoals.setImage(#imageLiteral(resourceName: "hide_ic"), for: .normal)
            }
        }else{
            cell.btnHideGoals.isHidden = true;
        }
        let goalCount = arrchecklistData[indexPath.row]["goal_count"] as? String ?? ""
        cell.lblGoalName.text = "\(arrchecklistData[indexPath.row]["goal_name"] as? String ?? "") (\(goalCount)) ";
        cell.txtCompletedGoal.text = arrchecklistData[indexPath.row]["goal_done_count"] as? String ?? "";
        cell.lblDefaultValues.text = "\(arrchecklistData[indexPath.row]["remainingGoals"] as AnyObject)"
        cell.btnHideGoals.addTarget(self, action: #selector(hideGoals), for: .touchUpInside)
        
        let goalID = arrchecklistData[indexPath.row]["goal_id"] as? String ?? ""
        var txtVal = cell.txtCompletedGoal.text!
        if txtVal == ""{
            txtVal = "0"
        }
        dictTxtValues[goalID] = txtVal;
        
        return cell
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = IndexPath(row: textField.tag, section: 0)
        let cell = tblChecklist.cellForRow(at: index) as! ChecklistTableViewCell
        
        let goalID = arrchecklistData[index.row]["goal_id"] as? String ?? ""
        var txtVal = cell.txtCompletedGoal.text!
        if txtVal == ""{
            txtVal = "0"
        }
        dictTxtValues.updateValue(txtVal, forKey: goalID)
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = arrchecklistData[sourceIndexPath.row]
        arrchecklistData.remove(at: sourceIndexPath.row)
        arrchecklistData.insert(item, at: destinationIndexPath.row)
    }
    @IBAction func hideGoals(sender:UIButton){
        if sender.image(for: .normal) == #imageLiteral(resourceName: "hide_ic") {
            let strSelected = arrchecklistData[sender.tag]["goal_id"] as? String ?? ""
            
            let alertController = UIAlertController(title: "", message: "Do you want to hide \(arrchecklistData[sender.tag]["goal_name"] as? String ?? "") goal", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Hide Goal", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.hideGoalsAPICall(goalID: strSelected)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "This goal is from ‘Critical Success Area’ category & it’s mandatory. You can’t hide this goal.")
        }
    }
    
    func hideGoalsAPICall(goalID:String){
        let dictParam = ["user_id": userID,
                         "zo_goal_id":goalID]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "hideGoals", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
                self.getChecklistDashboard()
            }else{
                OBJCOM.hideLoader()
                let dict = JsonDict!["result"] as! String;
                OBJCOM.setAlert(_title: "", message: dict)
            }
        };
    }
}

extension Array where Element : Equatable {
    func allEqual() -> Bool {
        if let firstElem = first {
            return !dropFirst().contains { $0 != firstElem }
        }
        return true
    }
}
