//
//  AddEditGoalsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var strCSA = ""
var strCA = ""
var strBLA = ""

class AddEditGoalsVC: SliderVC, UITextFieldDelegate {
    
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblDefaultDate : UILabel!
    @IBOutlet var lblDefaultDateTitle : UILabel!
    @IBOutlet var lblBusinessDate : UILabel!
    @IBOutlet var txtDate : UITextField!
    
    @IBOutlet var viewProgGoals : UIView!
    @IBOutlet var btnCriticalSuccessArea : UIButton!
    @IBOutlet var btnCoreActivity : UIButton!
    @IBOutlet var btnBaselineActivity : UIButton!
    
    @IBOutlet var btnPrev : UIButton!
    @IBOutlet var btnNext : UIButton!
    @IBOutlet var btnSubmit : UIButton!
    
    var dictCSA = [String:String]()
    var dictCA = [String:String]()
    var dictBLA = [String:String]()
    
    @IBOutlet var tblEditGoals : UITableView!
    @IBOutlet var viewProgGoalsHeight : NSLayoutConstraint!
    
    var showFlag = "1"
   
    var mainTitle = [String]()
    var mainRecGoals = [String]()
    var mainPersonalGoals = [String]()
    var mainGoalId = [String]()
    var mainToolTip = [String]()
    
    var CSATitle = [String]()
    var CSARecGoals = [String]()
    var CSAPersonalGoals = [String]()
    var CSAGoalId = [String]()
    var CSAToolTip = [String]()
    
    var CATitle = [String]()
    var CARecGoals = [String]()
    var CAPersonalGoals = [String]()
    var CAGoalId = [String]()
    var CAToolTip = [String]()
    
    var BLATitle = [String]()
    var BLARecGoals = [String]()
    var BLAPersonalGoals = [String]()
    var BLAGoalId = [String]()
    var BLAToolTip = [String]()
    var flag1 = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flag1 = true
        if isOnboarding == false {
            lblTitle.isHidden = true
            lblDefaultDate.isHidden = true
            lblDefaultDateTitle.isHidden = true
            lblBusinessDate.isHidden = false
            lblBusinessDate.text = "Business Start Date :"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            txtDate.text = formatter.string(from: Date())
            UserDefaults.standard.set(txtDate.text, forKey: "BUSY_START_DATE")
        }else{
            lblTitle.isHidden = false
            lblDefaultDate.isHidden = false
            lblDefaultDateTitle.isHidden = false
            lblBusinessDate.isHidden = false
            lblBusinessDate.text = "90 days plan date :"
            if UserDefaults.standard.value(forKey: "BUSY_START_DATE") != nil {
                lblDefaultDate.text = UserDefaults.standard.value(forKey: "BUSY_START_DATE") as? String
            }else{
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                lblBusinessDate.text = formatter.string(from: Date())
            }
        }
        
        
        designUI()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.apiCallForCriticalSuccess()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
    }
}

extension AddEditGoalsVC {
    func designUI(){
        
        self.setSelected(btnCriticalSuccessArea)
        self.setDeSelected(btnCoreActivity)
        self.setDeSelected(btnBaselineActivity)
        btnSubmit.layer.cornerRadius = 5.0
        btnSubmit.clipsToBounds = true
        viewProgGoals.layer.cornerRadius = 5.0
        viewProgGoals.layer.borderColor = APPGRAYCOLOR.cgColor
        viewProgGoals.layer.borderWidth = 0.3
        viewProgGoals.clipsToBounds = true
        txtDate.leftViewMode = UITextFieldViewMode.always
        txtDate.layer.cornerRadius = 5.0
        txtDate.layer.borderColor = APPGRAYCOLOR.cgColor
        txtDate.layer.borderWidth = 0.3
        txtDate.clipsToBounds = true
        txtDate.delegate = self
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: txtDate.frame.size.height, height: txtDate.frame.size.height))
        let imageView = UIImageView(frame: CGRect(x: 2.5, y: 2.5, width: txtDate.frame.size.height-5, height: txtDate.frame.size.height-5))
        let image = #imageLiteral(resourceName: "calendar")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        uiView.addSubview(imageView)
        txtDate.leftView = uiView
        
        viewProgGoalsHeight.constant = 100
        tblEditGoals.tableFooterView = UIView()

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtDate {
            DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .date) {
                (date) -> Void in
                if let dt = date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    textField.text = formatter.string(from: dt)
                }
            }
        }
    }//
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtDate {
            UserDefaults.standard.set(txtDate.text, forKey: "BUSY_START_DATE")
        }
    }
}

extension AddEditGoalsVC : UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func actionCriticalSuccessArea(_ sender:UIButton){
        selectCriticalSuccessArea()
    }
    
    @IBAction func actionCoreActivity(_ sender:UIButton){
        
        if self.dictCSAIsEmpty(dict: dictCSA) == true {
            selectCoreActivity()
        }else{
            OBJCOM.setAlert(_title: "", message: "Empty space or 0 is not allow in Critical success area's personal goals. Please enter valid value in personal goals.")
        }
    }
    
    @IBAction func actionBaselineActivity(_ sender:UIButton){
        
        if self.dictCSAIsEmpty(dict: dictCSA) == true {
            selectBaselineActivity()
        }else{
            OBJCOM.setAlert(_title: "", message: "Empty space or 0 is not allow in Critical success area's personal goals. Please enter valid value in personal goals.")
        }
    }
    
    func selectCriticalSuccessArea(){
        btnPrev.isHidden = true
        btnNext.isHidden = false
        btnSubmit.isHidden = true
        
        self.showFlag = "1"
        
        self.setSelected(btnCriticalSuccessArea)
        self.setDeSelected(btnCoreActivity)
        self.setDeSelected(btnBaselineActivity)
        
        self.mainTitle = self.CSATitle
        self.mainRecGoals = self.CSARecGoals
        self.mainPersonalGoals = self.CSAPersonalGoals
        self.mainGoalId = self.CSAGoalId
        self.mainToolTip = self.CSAToolTip
        
        self.viewProgGoalsHeight.constant = 152*CGFloat(self.mainTitle.count)+110
        self.tblEditGoals.reloadData()
    }
    
    func selectCoreActivity(){
        btnPrev.isHidden = false
        btnNext.isHidden = false
        btnSubmit.isHidden = true
        
        self.setSelected(btnCoreActivity)
        self.setDeSelected(btnCriticalSuccessArea)
        self.setDeSelected(btnBaselineActivity)
        
        self.showFlag = "2"
        
        self.mainTitle = self.CATitle
        self.mainRecGoals = self.CARecGoals
        self.mainPersonalGoals = self.CAPersonalGoals
        self.mainGoalId = self.CAGoalId
        self.mainToolTip = self.CAToolTip
        
        self.viewProgGoalsHeight.constant = 152*CGFloat(self.mainTitle.count)+110
        self.tblEditGoals.reloadData()
    }
    
    func selectBaselineActivity(){
        
        btnPrev.isHidden = false
        btnNext.isHidden = true
        btnSubmit.isHidden = false
        
        self.showFlag = "3"
        
        self.setSelected(btnBaselineActivity)
        self.setDeSelected(btnCoreActivity)
        self.setDeSelected(btnCriticalSuccessArea)
        
        self.mainTitle = self.BLATitle
        self.mainRecGoals = self.BLARecGoals
        self.mainPersonalGoals = self.BLAPersonalGoals
        self.mainGoalId = self.BLAGoalId
        self.mainToolTip = self.BLAToolTip
        
        self.viewProgGoalsHeight.constant = 152*CGFloat(self.mainTitle.count)+110
        self.tblEditGoals.reloadData()
    }
    
    func setSelected(_ btn : UIButton){
        btn.backgroundColor = APPGRAYCOLOR
        btn.setTitleColor(.white, for: .normal)
    }
    func setDeSelected(_ btn : UIButton){
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        
        btn.layer.borderColor = APPGRAYCOLOR.cgColor
        btn.layer.borderWidth = 0.3
        btn.clipsToBounds = true
    }
    
    @IBAction func actionPrevious(_ sender:UIButton){
        if self.showFlag == "2" {
            selectCriticalSuccessArea()
        }else if self.showFlag == "3" {
            selectCoreActivity()
        }
    }
    
    @IBAction func actionNext(_ sender:UIButton){
        
            if self.showFlag == "1" {
                if self.dictCSAIsEmpty(dict: dictCSA) == true {
                    
                    selectCoreActivity()
                   
                }else{
                    OBJCOM.setAlert(_title: "", message: "Empty space or 0 is not allow in Critical success area's personal goals. Please enter valid value in personal goals.")
                }
            }else if self.showFlag == "2" {
                selectBaselineActivity()
            }
        
    }
    
    @IBAction func actionSubmit(_ sender:UIButton){
        if txtDate.text == ""{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSubmitGoals(strDate: self.lblDefaultDate.text!)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            let alertController = UIAlertController(title: "", message: "You are about to change your Business Start Date & all Program Goals details. Your all current & previous working details will be get vanished. Are you sure?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Allow", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.apiCallForSubmitGoals(strDate: self.txtDate.text!)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            let cancelAction = UIAlertAction(title: "Deny", style: UIAlertActionStyle.cancel) {
                UIAlertAction in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblEditGoals.dequeueReusableCell(withIdentifier: "Cell") as! AddEditGoalsCell
        cell.lblGoalName.text = self.mainTitle[indexPath.row]
        cell.txtRecomendedGoals.text = self.mainRecGoals[indexPath.row]
        if self.showFlag == "1"{
            cell.txtPersonalGoals.text = dictCSA[self.CSAGoalId[indexPath.row]]
        }else if self.showFlag == "2"{
            cell.txtPersonalGoals.text = dictCA[self.CAGoalId[indexPath.row]]
        }else if self.showFlag == "3"{
            cell.txtPersonalGoals.text = dictBLA[self.BLAGoalId[indexPath.row]]
        }
//        cell.txtPersonalGoals.text = dictCSA[self.CSAGoalId[indexPath.row]]//self.mainPersonalGoals[indexPath.row]
        cell.btnHelpTip.tag = indexPath.row
        cell.btnHelpTip.addTarget(self, action: #selector(makeToast), for: .touchUpInside)
        cell.txtPersonalGoals.tag = indexPath.row
        cell.txtPersonalGoals.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        if self.showFlag == "1"{
           // if textField.text = "" {
                dictCSA[self.CSAGoalId[textField.tag]] = textField.text!
           // }
            
            print(dictCSA)
        }else if self.showFlag == "2"{
          //  if textField.text != "" {
                dictCA[self.CAGoalId[textField.tag]] = textField.text!
          //  }
            
            print(dictCA)
        }else if self.showFlag == "3"{
          //  if textField.text != "" {
                dictBLA[self.BLAGoalId[textField.tag]] = textField.text!
           // }
           
            print(dictBLA)
        }
    }
}

extension AddEditGoalsVC {
    func apiCallForCriticalSuccess(){
        let dictParam = ["user_id": userID]

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllGoalDetails", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.CSATitle = []; self.CSARecGoals = []; self.CSAPersonalGoals = []; self.CSAGoalId = []; self.CATitle = []; self.CARecGoals = []; self.CAPersonalGoals = []; self.CAGoalId = []; self.BLATitle = []; self.BLARecGoals = []; self.BLAPersonalGoals = []; self.BLAGoalId = []; self.CSAToolTip = []; self.CAToolTip = []; self.BLAToolTip = []
                
                self.dictCSA = [:]
                self.dictCA = [:]
                self.dictBLA = [:]
                
              //  self.lblDefaultDate.text = JsonDict!["usPacificeDate"] as? String ?? ""
                for obj in result {
                    if obj["goal_type_id"] as! String == "1"{
                        self.CSATitle.append(obj["goal_name"] as! String)
                        self.CSARecGoals.append(obj["goal_count_admin"] as! String)
                        self.CSAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.CSAGoalId.append(obj["zo_goal_id"] as! String)
                        self.CSAToolTip.append(obj["help_tip"] as! String)
                        
                        self.dictCSA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                        
                    }else if obj["goal_type_id"] as! String == "2"{
                        self.CATitle.append(obj["goal_name"] as! String)
                        self.CARecGoals.append(obj["goal_count_admin"] as! String)
                        self.CAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.CAGoalId.append(obj["zo_goal_id"] as! String)
                        self.CAToolTip.append(obj["help_tip"] as! String)
                        self.dictCA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                    }else if obj["goal_type_id"] as! String == "3"{
                        self.BLATitle.append(obj["goal_name"] as! String)
                        self.BLARecGoals.append(obj["goal_count_admin"] as! String)
                        self.BLAPersonalGoals.append(obj["goal_count_user"] as! String)
                        self.BLAGoalId.append(obj["zo_goal_id"] as! String)
                        self.BLAToolTip.append(obj["help_tip"] as! String)
                        self.dictBLA[obj["zo_goal_id"] as! String] = obj["goal_count_user"] as? String
                    }
                }
                strCSA = self.dictToJSONString(self.dictCSA)
                strCA = self.dictToJSONString(self.dictCA)
                strBLA = self.dictToJSONString(self.dictBLA)
                OBJCOM.hideLoader()
                self.selectCriticalSuccessArea()
            }else{

                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func apiCallForSubmitGoals(strDate:String){
        
        strCSA = dictToJSONString(dictCSA)
        strCA = dictToJSONString(dictCA)
        strBLA = dictToJSONString(dictBLA)
        
        let dictParam = ["user_id": userID,
                         "start_date": strDate,
                         "firstGoalDetails": strCSA,
                         "secondGoalDetails": strCA,
                         "thirdGoalDetails": strBLA]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        if isOnboarding == false {
            self.setBuinessDateAndGoals(dictParamTemp: dictParamTemp as! [String:String])
        }else{
            self.updateBuinessDateAndGoals(dictParamTemp: dictParamTemp as! [String:String])
        }
        
    }
    
    func setBuinessDateAndGoals(dictParamTemp : [String:Any]){
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setBuinessDateAndGoalsIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
                if self.flag1 == true {
                    self.flag1 = false
                    isOnboarding = true
                    let appDelegate = AppDelegate.shared
                    appDelegate.setRootVC()
                }
                OBJCOM.hideLoader()
            }else{
                
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateBuinessDateAndGoals(dictParamTemp : [String:Any]){
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateBuinessDateAndGoalsIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
            
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.apiCallForCriticalSuccess()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                OBJCOM.hideLoader()
            }else{
                
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
                OBJCOM.hideLoader()
            }
        };
    }
    
    func dictToJSONString(_ dict : [String:String]) -> String{
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: dict,
            options: .prettyPrinted
            ),
            var jsonStr = String(data: theJSONData,
                                     encoding: String.Encoding.ascii) {
            print("JSON string = \n\(jsonStr)")
            jsonStr = jsonStr.replacingOccurrences(of: "{", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "}", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "\n", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: " ", with: "")
            jsonStr = jsonStr.replacingOccurrences(of: "\"", with: "")
            print("JSON string = \n\(jsonStr)")
            return jsonStr
        }
        return ""
    }
    
    @objc func makeToast(_ sender:UIButton){
        if self.mainToolTip[sender.tag] != "" {
            OBJCOM.popUp(context: self, msg: self.mainToolTip[sender.tag])
        }
    }
    
    func dictCSAIsEmpty(dict:[String:String]) -> Bool{
        
        if dict.values.contains(""){
            return false
        }else if dict.values.contains("0"){
            return false
        }else{
            return true
        }
        
    }
}
