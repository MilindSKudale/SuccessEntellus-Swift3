//
//  ForgotPasswordVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var btnSubmit : UIButton!
    @IBOutlet var btnCancel : UIButton!
    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flag = true
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2;
        btnSubmit.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.size.height/2;
        btnCancel.layer.borderWidth = 1.5
        btnCancel.layer.borderColor = UIColor.white.cgColor
        btnCancel.clipsToBounds = true
    }
    
    @IBAction func actionSubmit(_ sender:UIButton) {
        
        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.callForgotPasswordAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionCancel(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email to reset password.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email to reset password.")
            return false
        }
        
        return true
    }
}

extension ForgotPasswordVC {
    func callForgotPasswordAPI(){
        
        let dictParam = ["email": txtEmail.text!]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "forgot_password", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let ResponseMessage = JsonDict!["ResponseMessage"] as? String ??
                "We could not find an account with this email address"
                UserDefaults.standard.removeObject(forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: ResponseMessage)
                
                if self.flag == true {
                    self.flag = false
                    let appDelegate = AppDelegate.shared
                    appDelegate.setRootVC()
                }
            }else{
                if self.flag == true {
                    self.flag = false
                    let result = JsonDict!["ResponseMessage"] as? String ?? "We could not find an account with this email address"
                    OBJCOM.setAlert(_title: "", message: result)
                }
                OBJCOM.hideLoader()
            }
        };
    }
}

