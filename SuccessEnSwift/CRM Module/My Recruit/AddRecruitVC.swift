//
//  AddRecruitVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 27/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddRecruitVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtFname : SkyFloatingLabelTextField!
    @IBOutlet var txtLname : SkyFloatingLabelTextField!
    @IBOutlet var txtDOB : SkyFloatingLabelTextField!
    @IBOutlet var txtDOAnnie : SkyFloatingLabelTextField!
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPhone : SkyFloatingLabelTextField!
    @IBOutlet var txtNLG : SkyFloatingLabelTextField!
    @IBOutlet var txtPFA : SkyFloatingLabelTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddRecruit(_ sender: UIButton) {
        if isValidate() == true {
            
            var dictParam : [String:AnyObject] = [:]
            dictParam["userId"] = userID as AnyObject
            dictParam["contact_flag"] =  "4" as AnyObject
            dictParam["platform"] = "3" as AnyObject
            dictParam["contact_fname"] = txtFname.text as AnyObject
            dictParam["contact_lname"] = txtLname.text as AnyObject
            dictParam["contact_email"] = txtEmail.text as AnyObject
            dictParam["contact_phone"] = txtPhone.text as AnyObject
            dictParam["contact_date_of_birth"] = txtDOB.text as AnyObject
            dictParam["contact_recruitsJoinDate"] = txtDOAnnie.text as AnyObject
            dictParam["contact_recruitsNLGAgentID"] = txtNLG.text as AnyObject
            dictParam["contact_recruitsPFAAgentID"] = txtPFA.text as AnyObject
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "addCrm", param:dictParam as [String : AnyObject],  vcObject: self){
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
        }else if !txtPhone.isEmpty && txtPhone.text!.length < 5 || txtPhone.text!.length > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than 5 digits and less than 19 digits.")
            return false
        }
        return true
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
    
    func setTag() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let actionGreenApple = UIAlertAction(title: "Green Apple", style: .default)
        {
            UIAlertAction in
            
        }
        actionGreenApple.setValue(colorGreenApple, forKey: "titleTextColor")
        actionGreenApple.setValue(arrAppleImages[2], forKey: "image")
        
        let actionRedApple = UIAlertAction(title: "Red Apple", style: .default)
        {
            UIAlertAction in
            
        }
        actionRedApple.setValue(colorRedApple, forKey: "titleTextColor")
        actionRedApple.setValue(arrAppleImages[1], forKey: "image")
        
        let actionBrownApple = UIAlertAction(title: "Brown Apple", style: .default)
        {
            UIAlertAction in
            
        }
        actionBrownApple.setValue(colorBrownApple, forKey: "titleTextColor")
        actionBrownApple.setValue(arrAppleImages[3], forKey: "image")
        
        let actionRottenApple = UIAlertAction(title: "Rotten Apple", style: .default)
        {
            UIAlertAction in
            
        }
        actionRottenApple.setValue(colorRottenApple, forKey: "titleTextColor")
        actionRottenApple.setValue(arrAppleImages[4], forKey: "image")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(actionGreenApple)
        alert.addAction(actionRedApple)
        alert.addAction(actionBrownApple)
        alert.addAction(actionRottenApple)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
        
        
    }

}
