//
//  AddProspectVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class AddProspectVC: UIViewController   {
    //Personal info
    @IBOutlet var viewPersonalInfo : UIView!
    @IBOutlet var viewPersonalInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtFname : SkyFloatingLabelTextField!
    @IBOutlet var txtLname : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailHome : SkyFloatingLabelTextField!
    @IBOutlet var txtPhoneHome : SkyFloatingLabelTextField!
   
    
    // Other info
    @IBOutlet var viewOtherInfo : UIView!
    @IBOutlet var viewOtherInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtGroup : SkyFloatingLabelTextField!
    @IBOutlet var txtDOB : SkyFloatingLabelTextField!
//    @IBOutlet var txtDOAnni : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailWork : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailOther : SkyFloatingLabelTextField!
    @IBOutlet var txtPhoneWork : SkyFloatingLabelTextField!
    @IBOutlet var txtPhoneOther : SkyFloatingLabelTextField!
 
    //Prospect info
    @IBOutlet var viewProspectInfo : UIView!
    @IBOutlet var viewProspectInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtProspectFor : SkyFloatingLabelTextField!
    @IBOutlet var txtProspectStatus : SkyFloatingLabelTextField!
    @IBOutlet var txtProspectSource : SkyFloatingLabelTextField!
    @IBOutlet var txtIndustry : SkyFloatingLabelTextField!
//    @IBOutlet var txtAnnualIncome : SkyFloatingLabelTextField!
//    @IBOutlet var txtContractRenewDate : SkyFloatingLabelTextField!
//    @IBOutlet var txtCustPolicyNumber : SkyFloatingLabelTextField!
//    @IBOutlet var txtCurrentPolicy : SkyFloatingLabelTextField!
//    @IBOutlet var txtCurrentPolicyAmount : SkyFloatingLabelTextField!
//    @IBOutlet var txtPolicyCompany : SkyFloatingLabelTextField!
    
    //Social info
    @IBOutlet var viewSocialInfo : UIView!
    @IBOutlet var viewSocialInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtTag : SkyFloatingLabelTextField!
    @IBOutlet var txtCompanyName : SkyFloatingLabelTextField!
//    @IBOutlet var txtTwitter : SkyFloatingLabelTextField!
//    @IBOutlet var txtFacebook : SkyFloatingLabelTextField!
//    @IBOutlet var txtSkype : SkyFloatingLabelTextField!
//    @IBOutlet var txtLinkedIn : SkyFloatingLabelTextField!
    //Address info
    @IBOutlet var viewAddressInfo : UIView!
    @IBOutlet var viewAddressInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtAddress : SkyFloatingLabelTextField!
    @IBOutlet var txtCity : SkyFloatingLabelTextField!
    @IBOutlet var txtState : SkyFloatingLabelTextField!
    @IBOutlet var txtCountry : SkyFloatingLabelTextField!
    @IBOutlet var txtZip : SkyFloatingLabelTextField!
    //Notes info
    @IBOutlet var viewNotesInfo : UIView!
    @IBOutlet var viewNotesInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtNotes : UITextView!
    @IBOutlet var btnAddToCalender : UIButton!
    @IBOutlet var btnCalReminderDate : UIButton!
    @IBOutlet var btnCalReminderTime : UIButton!
    
    @IBOutlet var btnArrPersonal : UIButton!
    @IBOutlet var btnArrOther : UIButton!
    @IBOutlet var btnArrProspect : UIButton!
    @IBOutlet var btnArrSocial : UIButton!
    @IBOutlet var btnArrAddress : UIButton!
    @IBOutlet var btnArrNotes : UIButton!
    
    
    
    var arrProspectFor = [String]()
    var arrProspectStatus = [String]()
    var arrProspectSource = [String]()
    var arrProspectStatusID = [String]()
    var arrProspectSourceID = [String]()
    
    var prospectStatusID = "0"
    var prospectSourceID = "0"
    
    var arrGrpTitle = [String]()
    var arrGrpId = [String]()
    var grpId = ""
    var calDate = ""
    var calTime = ""
    var isAddToCal = "0"
    var isCustomTag = false
    var selectedTagTitle = ""
    var selectedTagId = "0"
    var arrTagTitle = [String]()
    var arrTagId = [String]()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDropDownData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        self.isCustomTag = false
    }
    
    func getGroupData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                self.arrGrpTitle = []
                self.arrGrpId = []
                for obj in result {
                    self.arrGrpTitle.append(obj.value(forKey: "group_name") as! String)
                    self.arrGrpId.append(obj.value(forKey: "group_id")  as! String)
                }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
  
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddProspect(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        if isValidate() == true{
           
//            if txtTag.text != "Select tag" {
//                self.selectedTagTitle = txtTag.text!
//                self.selectedTagId = "0"
//            }
            var prospectForTitle = ""
            if txtProspectFor.text != "Please Select" {
                prospectForTitle = txtProspectFor.text!
            }
        
            var dictParam : [String:AnyObject] = [:]
            dictParam["contact_users_id"] = userID as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_flag"] = "3" as AnyObject
            dictParam["contact_fname"] = txtFname.text as AnyObject
            dictParam["contact_lname"] = txtLname.text as AnyObject
            dictParam["contact_email"] = txtEmailHome.text as AnyObject
            dictParam["contact_phone"] = txtPhoneHome.text as AnyObject
            dictParam["contact_other_email"] = txtEmailOther.text as AnyObject
            dictParam["contact_work_email"] = txtEmailWork.text as AnyObject
            dictParam["contact_work_phone"] = txtPhoneWork.text as AnyObject
            dictParam["contact_other_phone"] = txtPhoneOther.text as AnyObject
            dictParam["contact_company_name"] = txtCompanyName.text as AnyObject
           // dictParam["contact_title"] = "" as AnyObject
            dictParam["contact_date_of_birth"] = txtDOB.text as AnyObject
//            dictParam["contact_date_of_anniversary"] = txtDOAnni.text as AnyObject
            dictParam["contact_address"] = txtAddress.text as AnyObject
            dictParam["contact_city"] = txtCity.text as AnyObject
            dictParam["contact_zip"] = txtZip.text as AnyObject
            dictParam["contact_state"] = txtState.text as AnyObject
            dictParam["contact_country"] = txtCountry.text as AnyObject
            dictParam["contact_description"] = txtNotes.text as AnyObject
//            dictParam["contact_skype_id"] = txtSkype.text as AnyObject
//            dictParam["contact_twitter_name"] = txtTwitter.text as AnyObject
//            dictParam["contact_facebookurl"] = txtFacebook.text as AnyObject
//            dictParam["contact_linkedinurl"] = txtLinkedIn.text as AnyObject
            dictParam["contact_lead_prospecting_for"] = prospectForTitle as AnyObject
            dictParam["contact_lead_status_id"] = prospectStatusID as AnyObject
            dictParam["contact_lead_source_id"] = prospectSourceID as AnyObject
            dictParam["contact_industry"] = txtIndustry.text as AnyObject
//            dictParam["contact_annual_revenue"] = txtAnnualIncome.text as AnyObject
//            dictParam["contact_customer_policy_number"] = txtCustPolicyNumber.text as AnyObject
//            dictParam["contact_customer_current_policy"] = txtCurrentPolicy.text as AnyObject
//            dictParam["contact_customer_policy_comp"] = txtPolicyCompany.text as AnyObject
//            dictParam["contact_customer_policy_amt"] = txtCurrentPolicyAmount.text as AnyObject
//            dictParam["contact_customer_contract_renewal_date"] = txtContractRenewDate.text as AnyObject
            dictParam["contact_category_title"] = self.selectedTagTitle as AnyObject
            dictParam["contact_category"] = self.selectedTagId as AnyObject
            dictParam["contact_group"] = grpId as AnyObject
            dictParam["caldate"] = calDate as AnyObject
            dictParam["calTime"] = calTime as AnyObject
            dictParam["addToCalendar"] = isAddToCal as AnyObject
            dictParam["eventDescripId"] = "0" as AnyObject
            print(dictParam)
        
//            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//            let jsonString = String(data: jsonData!, encoding: .utf8)
//            print(jsonString ?? "")
           
            performRequest( requestURL: SITEURL+"addCrm", params: dictParam){ json in
                if let json = json {
                    let success:String = json["IsSuccess"] as? String ?? ""
                    if success == "true"{
                        let result = json["result"] as! String
                        OBJCOM.setAlert(_title: "", message: result)
                        OBJCOM.hideLoader()
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        let result = json["result"] as! String
                        OBJCOM.setAlert(_title: "", message: result)
                        OBJCOM.hideLoader()
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Something went to wrong.")
                    OBJCOM.hideLoader()
                }
                
            };
        }
    }
    
    func performRequest(requestURL: String, params: [String: AnyObject], comletion: @escaping (_ json: AnyObject?) -> Void) {
        
        Alamofire.request(requestURL, method: .post, parameters: params, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
            switch(response.result) {
            case .success(_):
                let  JSON : [String:Any]
                if let json = response.result.value{
                    JSON = json as! [String : Any]
                    comletion(JSON as AnyObject)
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "Error")
                
                comletion(nil)
                break
                
            }
        }
    }
    
    func getDropDownData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "fillDropDownCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                if dictJsonData.count > 0 {
                    let arrTag = dictJsonData.value(forKey: "contact_category") as! [AnyObject]
                    for tag in arrTag {
                        self.arrTagTitle.append("\(tag["userTagName"] as? String ?? "")")
                        self.arrTagId.append("\(tag["userTagId"] as? String ?? "")")
                    }
                    self.arrProspectFor = dictJsonData.value(forKey: "contact_lead_prospecting_for") as! [String]
                    let arrStatus = dictJsonData.value(forKey: "contact_lead_status_id") as! [AnyObject]
                    for obj in arrStatus {
                        self.arrProspectStatus.append(obj.value(forKey: "zo_lead_status_name") as! String)
                        self.arrProspectStatusID.append(obj.value(forKey: "zo_lead_status_id") as! String)
                    }
                    let arrSource = dictJsonData.value(forKey: "contact_lead_source_id") as! [AnyObject]
                    for obj in arrSource {
                    self.arrProspectSource.append(obj.value(forKey:"zo_lead_source_name") as! String)
                    self.arrProspectSourceID.append(obj.value(forKey:"zo_lead_source_id") as! String)
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension AddProspectVC {
    @IBAction func actionBtnPersonalInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrPersonal,view:viewPersonalInfo, height:242, heightContraints:viewPersonalInfoHeight)
    }
    
    @IBAction func actionBtnOtherInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrOther,view:viewOtherInfo, height:425, heightContraints:viewOtherInfoHeight)
    }

    @IBAction func actionBtnProspectInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrProspect,view:viewProspectInfo, height:300, heightContraints:viewProspectInfoHeight)
    }
    
    @IBAction func actionBtnSocialInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrSocial,view:viewSocialInfo, height:66, heightContraints:viewSocialInfoHeight)
    }
    
    @IBAction func actionBtnAddressInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrAddress,view:viewAddressInfo, height:182, heightContraints:viewAddressInfoHeight)
    }
    @IBAction func actionBtnNotesInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrNotes,view:viewNotesInfo, height:200, heightContraints:viewNotesInfoHeight)
    }
    
    func showHideSelectedView (btnArr : UIButton, view:UIView, height:CGFloat, heightContraints:NSLayoutConstraint){
        view.layoutIfNeeded()
        self.view.layoutIfNeeded()
        if heightContraints.constant == 0 {
            btnArr.isSelected = true
            heightContraints.constant = height
            UIView.animate(withDuration: 0.5, animations: {
                view.isHidden = false
            })
            self.view.layoutIfNeeded()
            view.layoutIfNeeded()
        }else{
            btnArr.isSelected = false
            heightContraints.constant = 0.0
            view.isHidden = true
        }
        UIView.animate(withDuration: 0.5, animations: {
            view.layoutIfNeeded()
            self.view.layoutIfNeeded()
        })
    }
}

extension AddProspectVC {
    func designUI(){
        viewPersonalInfoHeight.constant = 242.0
        viewOtherInfoHeight.constant = 0.0
        viewProspectInfoHeight.constant = 0.0
        viewSocialInfoHeight.constant = 0.0
        viewAddressInfoHeight.constant = 0.0
        viewNotesInfoHeight.constant = 0.0
        
        viewPersonalInfo.isHidden = false
        viewOtherInfo.isHidden = true
        viewProspectInfo.isHidden = true
        viewSocialInfo.isHidden = true
        viewAddressInfo.isHidden = true
        viewNotesInfo.isHidden = true
        
        btnArrPersonal.isSelected = true
        btnArrOther.isSelected = false
        btnArrProspect.isSelected = false
        btnArrSocial.isSelected = false
        btnArrAddress.isSelected = false
        btnArrNotes.isSelected = false
        
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.borderColor = APPGRAYCOLOR.cgColor
        txtNotes.layer.borderWidth = 1
        
        btnAddToCalender.isSelected = false
        btnCalReminderDate.isHidden = true
        btnCalReminderTime.isHidden = true
        btnCalReminderDate.layer.cornerRadius = 5.0
        btnCalReminderDate.layer.borderColor = APPGRAYCOLOR.cgColor
        btnCalReminderDate.layer.borderWidth = 1
        btnCalReminderTime.layer.cornerRadius = 5.0
        btnCalReminderTime.layer.borderColor = APPGRAYCOLOR.cgColor
        btnCalReminderTime.layer.borderWidth = 1
        
        self.calDate = ""
        self.calTime = ""
        self.isAddToCal = "0"
    }
    
    func isValidate() -> Bool {
        if txtFname.isEmpty && txtLname.isEmpty && txtEmailHome.isEmpty && txtEmailWork.isEmpty && txtEmailOther.isEmpty && txtPhoneHome.isEmpty && txtPhoneWork.isEmpty && txtPhoneOther.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter required fields i.e. first name or last name & email or phone number.")
            return false
        }else if txtFname.isEmpty && txtLname.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            return false
        }else if txtEmailHome.isEmpty && txtEmailWork.isEmpty && txtEmailOther.isEmpty && txtPhoneHome.isEmpty && txtPhoneWork.isEmpty && txtPhoneOther.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either email or phone number.")
            return false
        }else if !txtEmailHome.isEmpty && txtEmailHome.text?.containsWhitespace == true {
             OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmailHome.isEmpty && OBJCOM.validateEmail(uiObj: txtEmailHome.text!) != true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmailWork.isEmpty && OBJCOM.validateEmail(uiObj: txtEmailWork.text!) != true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmailWork.isEmpty && txtEmailWork.text?.containsWhitespace == true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmailOther.isEmpty && OBJCOM.validateEmail(uiObj: txtEmailOther.text!) != true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmailOther.isEmpty && txtEmailOther.text?.containsWhitespace == true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtPhoneHome.isEmpty && txtPhoneHome.text!.length < 5 || txtPhoneHome.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 5 digits and less than 19 digits.")
            return false
        }else if !txtPhoneWork.isEmpty && txtPhoneWork.text!.length < 5 || txtPhoneWork.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 5 digits and less than 19 digits.")
            return false
        }else if !txtPhoneOther.isEmpty && txtPhoneOther.text!.length < 5 || txtPhoneOther.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 5 digits and less than 19 digits.")
            return false
        }
        return true
    }
    
}

extension AddProspectVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtTag {
            if self.isCustomTag == false {
                setTag()
                return false
            }else{
                self.selectedTagTitle = ""
                self.selectedTagId = "0"
                return true
            }
        }else if textField == txtGroup {
            selectGroup()
            return false
        }else if textField == txtProspectFor {
            setProspectingForActionSheet()
            return false
        }else if textField == txtProspectStatus {
            setProspectStatusActionSheet()
            return false
        }else if textField == txtProspectSource {
            setProspectSourceActionSheet()
            return false
        }else if textField == txtDOB {
            self.datePickerTapped(txtFld: txtDOB)
            return false
        }
//        else if textField == txtDOAnni {
//            self.datePickerTapped(txtFld: txtDOAnni)
//            return false
//        }else if textField == txtContractRenewDate {
//            self.datePickerTapped1(txtFld: txtContractRenewDate)
//            return false
//        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtTag {
            self.selectedTagTitle = self.txtTag.text!
            self.selectedTagId = "0"
            self.isCustomTag = false
            self.txtTag.resignFirstResponder()
            
        }
    }
    
    func setProspectingForActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<self.arrProspectFor.count{
            alert.addAction(UIAlertAction(title: self.arrProspectFor[i], style: .default , handler:{ (UIAlertAction)in
                self.txtProspectFor.text = self.arrProspectFor[i]
            }))
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setProspectStatusActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<self.arrProspectStatus.count{
            alert.addAction(UIAlertAction(title: self.arrProspectStatus[i], style: .default , handler:{ (UIAlertAction)in
                self.txtProspectStatus.text = self.arrProspectStatus[i]
                self.prospectStatusID = self.arrProspectStatusID[i]
            }))
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setProspectSourceActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<self.arrProspectSource.count{
            alert.addAction(UIAlertAction(title: self.arrProspectSource[i], style: .default , handler:{ (UIAlertAction)in
                self.txtProspectSource.text = self.arrProspectSource[i]
                self.prospectSourceID = self.arrProspectSourceID[i]
            }))
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectGroup(){
        let alert = UIAlertController(title: "Select Group", message: nil, preferredStyle: .actionSheet)
        if self.arrGrpTitle.count == 0 {
            OBJCOM.setAlert(_title: "", message: "No group assigned yet.")
            return
        }
        for i in self.arrGrpTitle {
            alert.addAction(UIAlertAction(title: i, style: .default, handler: doSomething))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        self.present(alert, animated: true, completion: nil)
    }
    
    func doSomething(action: UIAlertAction) {
        //Use action.title
        print(action.title ?? "")
        self.txtGroup.text = action.title
        
        for i in 0..<self.arrGrpTitle.count {
            if action.title == self.arrGrpTitle[i] {
                grpId = self.arrGrpId[i]
            }
        }
    }
    
    func setTag(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<self.arrTagTitle.count{
            alert.addAction(UIAlertAction(title: self.arrTagTitle[i], style: .default , handler:{ (UIAlertAction)in
                self.txtTag.text = self.arrTagTitle[i]
                self.selectedTagTitle = self.arrTagTitle[i]
                self.selectedTagId = self.arrTagId[i]
                self.isCustomTag = false
            }))
        }
        alert.addAction(UIAlertAction(title: "Add Custom Tag", style: .default , handler:{ (UIAlertAction)in
            self.txtTag.text = ""
            self.txtTag.placeholder = "Enter your custom tag here"
            self.isCustomTag = true
            self.txtTag.becomeFirstResponder()
        }))
        alert.addAction(UIAlertAction(title: "No Tag", style: .default , handler:{ (UIAlertAction)in
            self.txtTag.text = ""
            self.txtTag.placeholder = "Enter your tag here"
            self.selectedTagTitle = ""
            self.selectedTagId = ""
            self.isCustomTag = false
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func datePickerTapped(txtFld:SkyFloatingLabelTextField) {
        
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: nil, maximumDate: Date(), datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                txtFld.text = formatter.string(from: dt)
            }
        }
    }
    
    func datePickerTapped1(txtFld:SkyFloatingLabelTextField) {
        
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate:  Date(), maximumDate:nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                txtFld.text = formatter.string(from: dt)
            }
        }
    }
}

extension AddProspectVC {
    @IBAction func actionAddToCalender(_ sender:UIButton) {
        
        if !sender.isSelected {
            if txtNotes.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please add notes to add reminder in calendar.")
                return
            }
            sender.isSelected = true
            
            let currentDate = self.dateToDateString(dt: Date())
            let currentTime = self.dateToTimeString(dt: Date())
            btnCalReminderDate.setTitle(currentDate, for: .normal)
            btnCalReminderTime.setTitle(currentTime, for: .normal)
            btnCalReminderDate.isHidden = false
            btnCalReminderTime.isHidden = false
            self.calDate = currentDate
            self.calTime = currentTime
            self.isAddToCal = "1"
        }else{
            sender.isSelected = false
            btnCalReminderDate.isHidden = true
            btnCalReminderTime.isHidden = true
            btnCalReminderDate.setTitle("", for: .normal)
            btnCalReminderTime.setTitle("", for: .normal)
            self.calDate = ""
            self.calTime = ""
            self.isAddToCal = "0"
        }
        
    }
    
    @IBAction func actionAddToCalenderDate(_ sender:UIButton) {
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: subscriptionDate, maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.calDate = formatter.string(from: dt)
                
            }
        }
    }
    
    @IBAction func actionAddToCalenderTime(_ sender:UIButton) {
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: subscriptionDate, maximumDate: nil, datePickerMode: .time) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.calTime = formatter.string(from: dt)
            }
        }
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToTimeString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
    func dateToDateString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: dt)
    }
}

