//
//  ViewAndEditRecruitVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 27/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewAndEditRecruitVC: UIViewController {

    @IBOutlet var viewPersonalInfo : UIView!
//    @IBOutlet var viewContactInfo : UIView!
    @IBOutlet var viewRecruitsInfo : UIView!
    
    @IBOutlet var txtFname : SkyFloatingLabelTextField!
    @IBOutlet var txtLname : SkyFloatingLabelTextField!
    @IBOutlet var txtDOB : SkyFloatingLabelTextField!
    @IBOutlet var txtDOAnnie : SkyFloatingLabelTextField!
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPhone : SkyFloatingLabelTextField!
    @IBOutlet var txtNLG : SkyFloatingLabelTextField!
    @IBOutlet var txtPFA : SkyFloatingLabelTextField!
    
    @IBOutlet var btnViewAndEdit : UIButton!
    
    var isEditable : Bool!
    var contactID = ""
    var arrRecruitData = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        if isEditable == true {
            pressedEditBtn()
        }else{
            pressedSavedChangesBtn()
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
    
    func assignedValuesToFields(dict:AnyObject){
        txtFname.text = dict["contact_fname"] as? String ?? ""
        txtLname.text = dict["contact_lname"] as? String ?? ""
        txtDOB.text = dict["contact_date_of_birth"] as? String ?? ""
        txtDOAnnie.text = dict["recruitsJoinDate"] as? String ?? ""
        txtEmail.text = dict["contact_email"] as? String ?? ""
        txtPhone.text = dict["contact_phone"] as? String ?? ""
        txtNLG.text = dict["recruitsNLGAgentID"] as? String ?? ""
        txtPFA.text = dict["recruitsPFAAgentID"] as? String ?? ""
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionEditRecruit(_ sender: UIButton) {
        if btnViewAndEdit.titleLabel?.text == " Edit Recruits " {
            pressedEditBtn()
        }else if btnViewAndEdit.titleLabel?.text == " Save Changes "{
            pressedSavedChangesBtn()
            actionUpdateRecruit()
        }
    }
    
   func actionUpdateRecruit() {
        if isValidate() == true {
            
            var dictParam : [String:AnyObject] = [:]
            dictParam["userId"] = userID as AnyObject
            dictParam["contact_flag"] =  "4" as AnyObject
            dictParam["contact_id"] = contactID as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_fname"] = txtFname.text as AnyObject
            dictParam["contact_lname"] = txtLname.text as AnyObject
            dictParam["contact_email"] = txtEmail.text as AnyObject
            dictParam["contact_phone"] = txtPhone.text as AnyObject
            dictParam["contact_date_of_birth"] = txtDOB.text as AnyObject
            dictParam["recruitsJoinDate"] = txtDOAnnie.text as AnyObject
            dictParam["recruitsNLGAgentID"] = txtNLG.text as AnyObject
            dictParam["recruitsPFAAgentID"] = txtPFA.text as AnyObject
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "updateCrm", param:dictParam as [String : AnyObject],  vcObject: self){
                json, staus in
                let success:String = json!["IsSuccess"] as! String
                if success == "true"{
                    let result = json!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    let result = json!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
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
    
    func isValidate() -> Bool {
        if txtFname.isEmpty && txtLname.isEmpty && txtEmail.isEmpty && txtPhone.isEmpty && txtNLG.isEmpty && txtPFA.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter required fields i.e. first name or last name & email or phone number.")
            return false
        }else if txtFname.isEmpty && txtLname.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either first name or last name.")
            return false
        }else if txtEmail.isEmpty && txtPhone.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Please enter either email or phone number.")
            return false
        }else if !txtEmail.isEmpty && txtEmail.text?.containsWhitespace == true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtEmail.isEmpty && OBJCOM.validateEmail(uiObj: txtEmail.text!) != true {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address")
            return false
        }else if !txtPhone.isEmpty && txtPhone.text!.length < 5 || txtPhone.text!.length > 13 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 6 digits and less than 12 digits.")
            return false
        }
        return true
    }
    
    func pressedEditBtn(){
        viewPersonalInfo.isUserInteractionEnabled = true
//        viewContactInfo.isUserInteractionEnabled = true
        viewRecruitsInfo.isUserInteractionEnabled = true
        btnViewAndEdit.setTitle(" Save Changes ", for: .normal)
    }
    
    func pressedSavedChangesBtn(){
        viewPersonalInfo.isUserInteractionEnabled = false
       // viewContactInfo.isUserInteractionEnabled = false
        viewRecruitsInfo.isUserInteractionEnabled = false
        btnViewAndEdit.setTitle(" Edit Recruits ", for: .normal)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtDOB {
            self.datePickerTapped(txtFld: txtDOB)
            return false
        }else if textField == txtDOAnnie {
            self.datePickerTapped(txtFld: txtDOAnnie)
            return false
        }
        return true
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
}
