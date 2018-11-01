//
//  FeedbackVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 14/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedbackVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtName : SkyFloatingLabelTextField!
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPhone : SkyFloatingLabelTextField!
    @IBOutlet var txtMailType : SkyFloatingLabelTextField!
    @IBOutlet var txtDesc : UITextView!
    @IBOutlet var btnSend : UIButton!
    
    var emailType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDesc.layer.cornerRadius = 5.0
        txtDesc.layer.borderColor = APPGRAYCOLOR.cgColor
        txtDesc.layer.borderWidth = 0.3
        txtDesc.clipsToBounds = true
        
        btnSend.layer.cornerRadius = 5.0
        btnSend.clipsToBounds = true
    }
    
    @IBAction func actionSendFeedback(_ sender:UIButton) {
        if validate() == true {
            apiCallForSendFeedback()
        }
    }
    
    func apiCallForSendFeedback(){
        
        if validate() == true {
            let dictParam = ["user_id": userID,
                             "name":txtName.text!,
                             "email": txtEmail.text!,
                             "message":txtDesc.text!,
                             "mail_type": emailType,
                             "phone": txtPhone.text!] as [String : String]
            
//            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//            let jsonString = String(data: jsonData!, encoding: .utf8)
//            let dictParamTemp = ["param":jsonString];
          
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "sendFeedback", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    self.txtName.text = ""
                    self.txtEmail.text = ""
                    self.txtPhone.text = ""
                    self.txtMailType.text = ""
                    self.txtDesc.text = ""
                    self.emailType = ""
                    OBJCOM.hideLoader()
                }else{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            };
        }
    }
    
    func validate() -> Bool {
        
        if txtName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter name.")
            return false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email address.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address.")
            return false
        }else if txtPhone.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter phone number.")
            return false
        }else if (txtPhone.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits.")
            return false
        }else if (txtPhone.text?.length)! > 19 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be less than or equal to 19 digits.")
            return false
        }else if emailType == "" {
            OBJCOM.setAlert(_title: "", message: "Please select mail type.")
            return false
        }else if txtDesc.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your message.")
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtMailType {
            txtMailType.resignFirstResponder()
            self.selectMailType()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtMailType.resignFirstResponder()
        return true;
    }
    
    func selectMailType(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let actionSupport = UIAlertAction(title: "Support", style: .default)
        {
            UIAlertAction in
            self.txtMailType.text = "Support"
            self.emailType = "support"
        }
        actionSupport.setValue(UIColor.black, forKey: "titleTextColor")
    
        let actionFeedback = UIAlertAction(title: "Feedback", style: .default)
        {
            UIAlertAction in
            self.txtMailType.text = "feedback"
            self.emailType = "Feedback"
        }
        actionFeedback.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(actionSupport)
        alert.addAction(actionFeedback)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }

}
