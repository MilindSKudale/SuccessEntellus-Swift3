//
//  EditViewRecruitVCNew.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditViewRecruitVCNew: UIViewController, TLTagsControlDelegate {

    @IBOutlet var viewPersonalInfo : UIView!
    @IBOutlet var viewPersonalInfoHeight : NSLayoutConstraint!
    @IBOutlet var txtFname : SkyFloatingLabelTextField!
    // @IBOutlet var txtMname : SkyFloatingLabelTextField!
    @IBOutlet var txtLname : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailHome : SkyFloatingLabelTextField!
    @IBOutlet var txtPhoneHome : SkyFloatingLabelTextField!
    
    
    // Other info
    @IBOutlet var viewOtherInfo : UIView!
    @IBOutlet var viewOtherInfoHeight : NSLayoutConstraint!
    // @IBOutlet var txtGroup : SkyFloatingLabelTextField!
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
//    @IBOutlet var txtNLG : SkyFloatingLabelTextField!
//    @IBOutlet var txtPFA : SkyFloatingLabelTextField!
//    @IBOutlet var txtDOJoining : SkyFloatingLabelTextField!
    
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
    
    //Assigned email campaign view
    @IBOutlet var viewAssignCampInfo : UIView!
    @IBOutlet var btnAssignCampInfo : UIButton!
    @IBOutlet var viewAssignCampInfoHeight : NSLayoutConstraint!
    @IBOutlet var tblAssignedEmailCampaign : UITableView!
    
    //Assigned text campaign view
    @IBOutlet var viewAssignTextCampInfo : UIView!
    @IBOutlet var btnAssignTextCampInfo : UIButton!
    @IBOutlet var viewAssignTextCampInfoHeight : NSLayoutConstraint!
    @IBOutlet var tblAssignedTextCampaign : UITableView!
    
    //Assigned group view
    @IBOutlet var viewAssignGroupInfo : UIView!
    @IBOutlet var btnAssignGroupInfo : UIButton!
    @IBOutlet var viewAssignGroupInfoHeight : NSLayoutConstraint!
    @IBOutlet var tblAssignedGroupCampaign : UITableView!
    
    @IBOutlet var btnArrPersonal : UIButton!
    @IBOutlet var btnArrOther : UIButton!
    @IBOutlet var btnArrProspect : UIButton!
    @IBOutlet var btnArrSocial : UIButton!
    @IBOutlet var btnArrAddress : UIButton!
    @IBOutlet var btnArrNotes : UIButton!
    @IBOutlet var btnArrAssignedGroup : UIButton!
    @IBOutlet var btnArrAssignedCamp : UIButton!
    @IBOutlet var btnArrAssignedTCamp : UIButton!
    @IBOutlet var btnViewAndEdit : UIButton!
    
    var contactID = ""
    var isEditable : Bool!
    var arrAssignedCamp = [AnyObject]()
    var arrAssignedGroups = [AnyObject]()
    var arrAssignedTextCamp = [AnyObject]()
    
    var arrProspectFor = [String]()
    var arrProspectStatus = [String]()
    var arrProspectSource = [String]()
    var arrProspectStatusID = [String]()
    var arrProspectSourceID = [String]()
    
    var prospectStatusID = "0"
    var prospectSourceID = "0"
    var calDate = ""
    var calTime = ""
    var isAddToCal = "0"
    var eventDescripId = "0"
    var isCustomTag = false
    var selectedTagTitle = ""
    var selectedTagId = "0"
    var arrTagTitle = [String]()
    var arrTagId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDropDownData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        designUI()
        isCustomTag = false
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionViewEditProspect(_ sender: UIButton) {
        if isEditable == true {
            updateProspectData()
        }else{
            pressedEditBtn()
            isEditable = true
        }
    }
    
    func getDataFromServer(){
        let dictParam = ["userId" : userID,
                         "platform" : "3",
                         "crmFlag" : "4",
                         "contactId" : contactID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCrmDetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as AnyObject
                if data.count > 0 {
                    self.assignedValuesToFields(dict: data)
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getDropDownData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4"]
        
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
                self.getDataFromServer()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    
    func assignedValuesToFields(dict:AnyObject){
        txtFname.text = dict["contact_fname"] as? String ?? ""
        //txtMname.text = dict["contact_middle"] as? String ?? ""
        txtLname.text = dict["contact_lname"] as? String ?? ""
        txtDOB.text = dict["contact_date_of_birth"] as? String ?? ""
//        txtDOAnni.text = dict["contact_date_of_anniversary"] as? String ?? ""
        txtEmailHome.text = dict["contact_email"] as? String ?? ""
        txtEmailWork.text = dict["contact_work_email"] as? String ?? ""
        txtEmailOther.text = dict["contact_other_email"] as? String ?? ""
        txtPhoneHome.text = dict["contact_phone"] as? String ?? ""
        txtPhoneWork.text = dict["contact_work_phone"] as? String ?? ""
        txtPhoneOther.text = dict["contact_other_phone"] as? String ?? ""
        txtIndustry.text = dict["contact_industry"] as? String ?? ""
//        txtAnnualIncome.text = dict["contact_customer_annual_income"] as? String ?? ""
        txtCompanyName.text = dict["contact_company_name"] as? String ?? ""
//        txtTwitter.text = dict["contact_twitter_name"] as? String ?? ""
//        txtFacebook.text = dict["contact_facebookurl"] as? String ?? ""
//        txtSkype.text = dict["contact_skype_id"] as? String ?? ""
//        txtLinkedIn.text = dict["contact_linkedinurl"] as? String ?? ""
        txtAddress.text = dict["contact_address"] as? String ?? ""
        txtCity.text = dict["contact_city"] as? String ?? ""
        txtState.text = dict["contact_state"] as? String ?? ""
        txtCountry.text = dict["contact_country"] as? String ?? ""
        txtZip.text = dict["contact_zip"] as? String ?? ""
        txtNotes.text = dict["contact_description"] as? String ?? ""
        
//        txtNLG.text = dict["contact_recruitsNLGAgentID"] as? String ?? ""
//        txtPFA.text = dict["contact_recruitsPFAAgentID"] as? String ?? ""
//        txtDOJoining.text = dict["contact_recruitsJoinDate"] as? String ?? ""
//
//        txtContractRenewDate.text = dict["contact_customer_contract_renewal_date"] as? String ?? ""
//        txtCurrentPolicyAmount.text = dict["contact_customer_policy_amt"] as? String ?? ""
//        txtPolicyCompany.text = dict["contact_customer_policy_comp"] as? String ?? ""
//        txtCustPolicyNumber.text = dict["contact_customer_policy_number"] as? String ?? ""
//        txtCurrentPolicy.text = dict["contact_customer_current_policy"] as? String ?? ""
        
        let tagId = "\(dict["contact_category"] as? String ?? "")"
        let tagTitle = dict["contact_category_title"] as? String ?? ""
        if tagTitle == "" {
            txtTag.text = ""
            txtTag.placeholder = "Select tag"
            self.selectedTagTitle = ""
            self.selectedTagId = "0"
        }else{
            txtTag.text = tagTitle
            self.selectedTagTitle = tagTitle
            self.selectedTagId = tagId
        }
        
        let prospectFor = dict["contact_lead_prospecting_for"] as? String ?? ""
        if prospectFor == "" {
            txtProspectFor.placeholder = "Please select"
            txtProspectFor.text = ""
        }else{
            txtProspectFor.text = prospectFor
        }
        let pStatus = dict["contact_lead_status_id"] as? String ?? ""
        if pStatus == "0" {
            txtProspectStatus.text = ""
            txtProspectStatus.placeholder = "Please select"
            prospectStatusID = "0"
        }else{
            txtProspectStatus.text = arrProspectStatus[Int(pStatus)! - 1]
            prospectStatusID = pStatus
        }
        let pSource = dict["contact_lead_source_id"] as? String ?? ""
        if pSource == "0" {
            txtProspectSource.text = ""
            txtProspectSource.placeholder = "Please select"
            prospectSourceID = "0"
        }else{
            txtProspectSource.text = arrProspectSource[Int(pSource)! - 1]
            prospectSourceID = pSource
        }
        arrAssignedCamp = dict["contact_campaignAssign"] as! [AnyObject]
        arrAssignedTextCamp = dict["contact_txtCampaignAssign"] as! [AnyObject]
        arrAssignedGroups = dict["contact_groupAssign"] as! [AnyObject]
        tblAssignedEmailCampaign.reloadData()
        tblAssignedTextCampaign.reloadData()
        tblAssignedGroupCampaign.reloadData()
        
        calDate = dict["caldate"] as? String ?? ""
        calTime = dict["calTime"] as? String ?? ""
        eventDescripId = "\(dict["eventDescripId"] as? String ?? "0")"
        btnCalReminderDate.setTitle(calDate, for: .normal)
        btnCalReminderTime.setTitle(calTime, for: .normal)
        if eventDescripId != "0" && eventDescripId != "" {
            btnAddToCalender.isSelected = true
            btnCalReminderDate.isHidden = false
            btnCalReminderTime.isHidden = false
            isAddToCal = "1"
        }else{
            btnAddToCalender.isSelected = false
            btnCalReminderDate.isHidden = true
            btnCalReminderTime.isHidden = true
            isAddToCal = "0"
        }
    }
    func tagsControl(_ tagsControl: TLTagsControl!, tappedAt index: Int) {
        print(index)
    }
    
    func tagsControl(_ tagsControl: TLTagsControl!, removedAt index: Int) {
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}

extension EditViewRecruitVCNew {
    
    @IBAction func actionBtnPersonalInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrPersonal,view:viewPersonalInfo, height:242, heightContraints:viewPersonalInfoHeight)
    }
    
    @IBAction func actionBtnOtherInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrOther,view:viewOtherInfo, height:365, heightContraints:viewOtherInfoHeight)
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
    
    @IBAction func actionBtnAssignedCampInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrAssignedCamp,view:viewAssignCampInfo, height:100, heightContraints:viewAssignCampInfoHeight)
    }
    
    @IBAction func actionBtnAssignedTextCampInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrAssignedTCamp,view:viewAssignTextCampInfo, height:100, heightContraints:viewAssignTextCampInfoHeight)
    }
    
    @IBAction func actionBtnAssignedGroupInfo(_ sender: UIButton) {
        showHideSelectedView (btnArr : btnArrAssignedGroup,view:viewAssignGroupInfo, height:100, heightContraints:viewAssignGroupInfoHeight)
    }
    
    func showHideSelectedView (btnArr : UIButton, view:UIView, height:CGFloat, heightContraints:NSLayoutConstraint){
        view.layoutIfNeeded()
        if heightContraints.constant == 0 {
            btnArr.isSelected = true
            heightContraints.constant = height
            UIView.animate(withDuration: 0.5, animations: {
                view.isHidden = false
            })
            self.view.layoutIfNeeded()
        }else{
            btnArr.isSelected = false
            heightContraints.constant = 0.0
            view.isHidden = true
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension EditViewRecruitVCNew {
    func designUI(){
        
        tblAssignedEmailCampaign.tableFooterView = UIView()
        tblAssignedTextCampaign.tableFooterView = UIView()
        tblAssignedGroupCampaign.tableFooterView = UIView()
        
        viewPersonalInfoHeight.constant = 242.0
        viewOtherInfoHeight.constant = 0.0
        viewProspectInfoHeight.constant = 0.0
        viewSocialInfoHeight.constant = 0.0
        viewAddressInfoHeight.constant = 0.0
        viewNotesInfoHeight.constant = 0.0
        viewAssignCampInfoHeight.constant = 0.0
        viewAssignTextCampInfoHeight.constant = 0.0
        viewAssignGroupInfoHeight.constant = 0.0
        
        viewPersonalInfo.isHidden = false
        viewOtherInfo.isHidden = true
        viewProspectInfo.isHidden = true
        viewSocialInfo.isHidden = true
        viewAddressInfo.isHidden = true
        viewNotesInfo.isHidden = true
        viewAssignCampInfo.isHidden = true
        viewAssignTextCampInfo.isHidden = true
        viewAssignGroupInfo.isHidden = true
        
        btnArrPersonal.isSelected = true
        btnArrOther.isSelected = false
        btnArrProspect.isSelected = false
        btnArrSocial.isSelected = false
        btnArrAddress.isSelected = false
        btnArrNotes.isSelected = false
        btnArrAssignedCamp.isSelected = false
        btnArrAssignedTCamp.isSelected = false
        btnArrAssignedGroup.isSelected = false
        
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.borderColor = APPGRAYCOLOR.cgColor
        txtNotes.layer.borderWidth = 1
        
        btnCalReminderDate.layer.cornerRadius = 5.0
        btnCalReminderDate.layer.borderColor = APPGRAYCOLOR.cgColor
        btnCalReminderDate.layer.borderWidth = 1
        btnCalReminderTime.layer.cornerRadius = 5.0
        btnCalReminderTime.layer.borderColor = APPGRAYCOLOR.cgColor
        btnCalReminderTime.layer.borderWidth = 1
        
        if isEditable == true {
            pressedEditBtn()
        }else{
            pressedSavedChangesBtn()
        }
    }
    
    func pressedEditBtn(){
        viewPersonalInfo.isUserInteractionEnabled = true
        viewOtherInfo.isUserInteractionEnabled = true
        viewProspectInfo.isUserInteractionEnabled = true
        viewSocialInfo.isUserInteractionEnabled = true
        viewAddressInfo.isUserInteractionEnabled = true
        viewNotesInfo.isUserInteractionEnabled = true
        btnViewAndEdit.setTitle(" Save Changes ", for: .normal)
        self.btnArrAssignedCamp.isHidden = true
        self.viewAssignCampInfo.isHidden = true
        self.tblAssignedEmailCampaign.isHidden = true
        self.btnAssignCampInfo.isHidden = true
        
        self.btnArrAssignedTCamp.isHidden = true
        self.viewAssignTextCampInfo.isHidden = true
        self.tblAssignedTextCampaign.isHidden = true
        self.btnAssignTextCampInfo.isHidden = true
        
        self.btnArrAssignedGroup.isHidden = true
        self.viewAssignGroupInfo.isHidden = true
        self.tblAssignedGroupCampaign.isHidden = true
        self.btnAssignGroupInfo.isHidden = true
    }
    
    func pressedSavedChangesBtn(){
        viewPersonalInfo.isUserInteractionEnabled = false
        viewOtherInfo.isUserInteractionEnabled = false
        viewProspectInfo.isUserInteractionEnabled = false
        viewSocialInfo.isUserInteractionEnabled = false
        viewAddressInfo.isUserInteractionEnabled = false
        viewNotesInfo.isUserInteractionEnabled = false
        btnViewAndEdit.setTitle(" Edit Recruit ", for: .normal)
        self.btnArrAssignedCamp.isHidden = false
        self.viewAssignCampInfo.isHidden = false
        self.tblAssignedEmailCampaign.isHidden = false
        self.btnAssignCampInfo.isHidden = false
        
        self.btnArrAssignedTCamp.isHidden = false
        self.viewAssignTextCampInfo.isHidden = false
        self.tblAssignedTextCampaign.isHidden = false
        self.btnAssignTextCampInfo.isHidden = false
        
        self.btnArrAssignedGroup.isHidden = false
        self.viewAssignGroupInfo.isHidden = false
        self.tblAssignedGroupCampaign.isHidden = false
        self.btnAssignGroupInfo.isHidden = false
    }
    
    func updateProspectData(){
        //        self.dismiss(animated: true, completion: nil)
        //updateCrm
        
        if isValidate() == true{
//            var tagTitle = ""
//            if txtTag.text != "Select tag" {
//                tagTitle = txtTag.text!
//            }
            var prospectForTitle = ""
            if txtProspectFor.text != "Please select" {
                prospectForTitle = txtProspectFor.text!
            }
            
            var dictParam : [String:AnyObject] = [:]
            dictParam["contact_users_id"] = userID as AnyObject
            dictParam["contact_id"] = contactID as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_flag"] = "4" as AnyObject
            dictParam["contact_fname"] = txtFname.text as AnyObject
            dictParam["contact_lname"] = txtLname.text as AnyObject
            dictParam["contact_email"] = txtEmailHome.text as AnyObject
            dictParam["contact_phone"] = txtPhoneHome.text as AnyObject
            dictParam["contact_other_email"] = txtEmailOther.text as AnyObject
            dictParam["contact_work_email"] = txtEmailWork.text as AnyObject
            dictParam["contact_work_phone"] = txtPhoneWork.text as AnyObject
            dictParam["contact_other_phone"] = txtPhoneOther.text as AnyObject
            dictParam["contact_company_name"] = txtCompanyName.text as AnyObject
            
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
            dictParam["caldate"] = calDate as AnyObject
            dictParam["calTime"] = calTime as AnyObject
            dictParam["addToCalendar"] = isAddToCal as AnyObject
            dictParam["eventDescripId"] = eventDescripId as AnyObject
//            dictParam["contact_recruitsJoinDate"] = txtDOJoining.text as AnyObject
//            dictParam["contact_recruitsNLGAgentID"] = txtNLG.text as AnyObject
//            dictParam["contact_recruitsPFAAgentID"] = txtPFA.text as AnyObject
            // dictParam["contact_group"] = "" as AnyObject
            
            OBJCOM.modalAPICall(Action: "updateCrm", param:dictParam as [String : AnyObject],  vcObject: self){
                json, staus in
                let success:String = json!["IsSuccess"] as! String
                if success == "true"{
                    let result = json!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    self.pressedSavedChangesBtn()
                    self.isEditable = false
                    OBJCOM.hideLoader()
                }else{
                    let result = json!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            }
        }
    }
    
    func performRequest(requestURL: String, params: [String: AnyObject], comletion: @escaping (_ json: AnyObject?) -> Void) {
        
        Alamofire.request(requestURL, method: .post, parameters: params).responseString{ response in
            // debugPrint(response)
            switch(response.result) {
            case .success(_):
                let  JSON : AnyObject
                if let json = response.result.value{
                    JSON = json as AnyObject
                    print(JSON)
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
    
    func isValidate() -> Bool {
        if txtFname.isEmpty && txtLname.isEmpty && txtEmailHome.isEmpty && txtEmailWork.isEmpty && txtEmailOther.isEmpty && txtPhoneHome.isEmpty && txtPhoneWork.isEmpty && txtPhoneOther.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter required fields i.e. first name or last name & email or mobile.")
            return false
        }else if txtFname.isEmpty && txtLname.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            return false
        }else if txtEmailHome.isEmpty && txtEmailWork.isEmpty && txtEmailOther.isEmpty && txtPhoneHome.isEmpty && txtPhoneWork.isEmpty && txtPhoneOther.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either email or mobile number.")
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
            OBJCOM.setAlert(_title: "", message: "Mobile number should be greater than 5 digits and less than 19 digits.")
            return false
        }else if !txtPhoneWork.isEmpty && txtPhoneWork.text!.length < 5 || txtPhoneWork.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be greater than 5 digits and less than 19 digits.")
            return false
        }else if !txtPhoneOther.isEmpty && txtPhoneOther.text!.length < 5 || txtPhoneOther.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be greater than 5 digits and less than 19 digits.")
            return false
        }
        return true
    }
}

extension EditViewRecruitVCNew : UITextFieldDelegate {
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
        
        for i in 0..<arrProspectFor.count {
            alert.addAction(UIAlertAction(title: arrProspectFor[i], style: .default , handler:{ (UIAlertAction)in
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
        
        for i in 0..<arrProspectSource.count{
            alert.addAction(UIAlertAction(title: arrProspectSource[i], style: .default , handler:{ (UIAlertAction)in
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

extension EditViewRecruitVCNew : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 1
        if tableView == tblAssignedEmailCampaign {
            if arrAssignedCamp.count > 0 {
                rowCount = arrAssignedCamp.count
            }else{
                rowCount = 1
            }
        }else if tableView == tblAssignedTextCampaign {
            if arrAssignedTextCamp.count > 0 {
                rowCount = arrAssignedTextCamp.count
            }else{
                rowCount = 1
            }
        }else if tableView == tblAssignedGroupCampaign {
            if arrAssignedGroups.count > 0 {
                rowCount = arrAssignedGroups.count
            }else{
                rowCount = 1
            }
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAssignedEmailCampaign.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignCampaignCrmCell
        if tableView == tblAssignedEmailCampaign {
            if arrAssignedCamp.count > 0 {
                cell.lblCampName?.text = self.arrAssignedCamp[indexPath.row] as? String ?? ""
                cell.imgView?.image = #imageLiteral(resourceName: "campain_black")
            }else{
                cell.lblCampName?.text = "No email campaigns assigned!"
                cell.imgView?.image = nil
            }
        }else if tableView == tblAssignedTextCampaign {
            if arrAssignedTextCamp.count > 0 {
                cell.lblCampName?.text = self.arrAssignedTextCamp[indexPath.row] as? String ?? ""
                cell.imgView?.image = #imageLiteral(resourceName: "campain_black")
            }else{
                cell.lblCampName?.text = "No text campaigns assigned!"
                cell.imgView?.image = nil
            }
        }else if tableView == tblAssignedGroupCampaign {
            if arrAssignedGroups.count > 0 {
                cell.lblCampName?.text = self.arrAssignedGroups[indexPath.row] as? String ?? ""
                cell.imgView?.image = #imageLiteral(resourceName: "assignGrp_black")
            }else{
                cell.lblCampName?.text = "No groups assigned!"
                cell.imgView?.image = nil
            }
        }
        
        return cell
    }
}

extension EditViewRecruitVCNew {
    @IBAction func actionAddToCalender(_ sender:UIButton) {
        
        if !sender.isSelected {
            if txtNotes.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please add notes to add reminder in calendar.")
                return
            }
            sender.isSelected = true
            
            let currentDate = self.dateToDateString(dt: Date())
            let currentTime = self.dateToTimeString(dt: Date())
            if calDate == "" && calTime == "" {
                btnCalReminderDate.setTitle(currentDate, for: .normal)
                btnCalReminderTime.setTitle(currentTime, for: .normal)
                calDate = currentDate
                calTime = currentTime
            }else{
                btnCalReminderDate.setTitle(calDate, for: .normal)
                btnCalReminderTime.setTitle(calTime, for: .normal)
            }
            btnCalReminderDate.isHidden = false
            btnCalReminderTime.isHidden = false
            isAddToCal = "1"
        }else{
            calDate = ""
            calTime = ""
            sender.isSelected = false
            btnCalReminderDate.isHidden = true
            btnCalReminderTime.isHidden = true
            isAddToCal = "0"
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
