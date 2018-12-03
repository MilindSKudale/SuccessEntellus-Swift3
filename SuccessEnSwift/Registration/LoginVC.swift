//
//  SignUpVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var motivationalFlag = ""
var arrModuleList =  [String]()
var arrModuleId =  [String]()

class LoginVC: SliderVC {
    
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPassword : SkyFloatingLabelTextField!
    @IBOutlet var btnLogin : UIButton!
    @IBOutlet var btnClose : UIButton!
    var flags = true
    var window : UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flags = true
        btnLogin.layer.cornerRadius = btnLogin.frame.size.height/2;
        btnLogin.clipsToBounds = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func actionLogin(_ sender:UIButton) {
        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.callLoginAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionForgotPassword(_ sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idForgotPasswordVC") as! ForgotPasswordVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionCloseVC(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email to login.")
            return false
        } else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email to login.")
            return false
        } else if txtPassword.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter password to login.")
            return false
        }
        return true
    }
}

extension LoginVC {
    func callLoginAPI(){
        
        let dictParam = ["email": txtEmail.text!,
                         "password":txtPassword.text!]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "login", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                let motiFlag = JsonDict!["motivationalFlag"] as! String
                
                if motiFlag == "yes" {
                    UserDefaults.standard.set("true", forKey: "MOTIVATIONAL")
                }else{
                    UserDefaults.standard.set("false", forKey: "MOTIVATIONAL")
                }
                
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
                isOnboard = JsonDict!["IsGoalSetSuccess"] as! String
                
                if deviceTokenId != "" {
                    OBJCOM.sendUDIDToServer(deviceTokenId)
                }
                
                isFirstTimeChecklist = true
                isFirstTimeEmailCampaign = true
                isFirstTimeCftLocator = true
                isFirstTimeTextCampaign = true
                
                selectedCellIndex = 2
                UITextField().resignFirstResponder()
                DispatchQueue.main.async(execute: {
                    OBJCOM.getPackagesInfo()
                    let appDelegate = AppDelegate.shared
                    appDelegate.setRootVC()
                    OBJCOM.hideLoader()
                })
                
                
                
            // OBJLOC.StartupdateLocation()
            }else{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}

extension UIApplicationDelegate {
    static var shared: Self {
        return UIApplication.shared.delegate! as! Self
    }
}

