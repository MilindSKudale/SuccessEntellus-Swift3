//
//  ChangeProfileVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 12/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import ALCameraViewController
import Alamofire
import SwiftyJSON

class ChangeProfileVC: SliderVC {
    @IBOutlet var txtFirstName : SkyFloatingLabelTextField!
    @IBOutlet var txtLastName : SkyFloatingLabelTextField!
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var txtPhone : SkyFloatingLabelTextField!
    @IBOutlet var txtAddress : SkyFloatingLabelTextField!
    @IBOutlet var txtCity : SkyFloatingLabelTextField!
    @IBOutlet var txtState : SkyFloatingLabelTextField!
    @IBOutlet var txtCountry : SkyFloatingLabelTextField!
    @IBOutlet var txtPinCode : SkyFloatingLabelTextField!
    @IBOutlet var txtBusiReason : SkyFloatingLabelTextField!
    @IBOutlet var profileImg : UIImageView!
    @IBOutlet var busiImg : UIImageView!
    @IBOutlet var profileImgPath : UILabel!
    @IBOutlet var busiImgPath : UILabel!
    @IBOutlet var swtchCft : UISwitch!
    @IBOutlet var btnChooseProfileImg : UIButton!
    @IBOutlet var btnChooseBusiImg : UIButton!
    @IBOutlet var btnSubmit : UIButton!
    
    @IBOutlet var lblTermsandCondi : UILabel!
    @IBOutlet var btnTermsandCondi : UIButton!
    
    @IBOutlet var txtCurrentPass : SkyFloatingLabelTextField!
    @IBOutlet var txtNewPass : SkyFloatingLabelTextField!
    @IBOutlet var txtConfirmPass : SkyFloatingLabelTextField!
    @IBOutlet var btnResetPass : UIButton!
    
    var img_profile_pic : UIImage!
    var img_busi_pic : UIImage!
    var isCftUser = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            designUI()
            getUserData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        swtchCft.addTarget(self, action: #selector(actionCftYN(_:)), for: .valueChanged)
//        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
//            getUserData()
//        }
    }

    func designUI(){
        setCorner(btnChooseBusiImg)
        setCorner(btnChooseProfileImg)
        setCorner(btnSubmit)
        setCorner(profileImg)
        setCorner(busiImg)
        setCorner(btnResetPass)
    }
    
    func setCorner(_ uiView : UIView){
        uiView.layer.cornerRadius = 5.0
        uiView.layer.borderColor = APPGRAYCOLOR.cgColor
        uiView.layer.borderWidth = 0.3
        uiView.clipsToBounds = true
    }
    
    func getUserData() {
        
        let dictParam = ["user_id":userID,
                         "platform":"3"]
        
//        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//        let jsonString = String(data: jsonData!, encoding: .utf8)
//        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "userProfile", param:dictParam as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
            
                let userData = JsonDict!["result"] as! [AnyObject]
                print(userData)
                UserDefaults.standard.set(userData[0], forKey: "USERINFO")
                self.assignUserData(userData[0])
                
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
    
    func assignUserData(_ userInfo  : AnyObject){
        
//        userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
//        print(userInfo)
        
        txtFirstName.text = userInfo["first_name"] as? String ?? ""
        txtLastName.text = userInfo["last_name"] as? String ?? ""
        txtEmail.text = userInfo["email"] as? String ?? ""
        txtPhone.text = userInfo["phone"] as? String ?? ""
        txtAddress.text = userInfo["userAddress"] as? String ?? ""
        txtCity.text = userInfo["userCity"] as? String ?? ""
        txtState.text = userInfo["userState"] as? String ?? ""
        txtCountry.text = userInfo["userCountry"] as? String ?? ""
        txtPinCode.text = userInfo["userZipcode"] as? String ?? ""
        txtBusiReason.text = userInfo["reason"] as? String ?? ""
        isCftUser = userInfo["userCft"] as? String ?? "0"
        if isCftUser == "1"{
            swtchCft.isOn = true
           // OBJLOC.StartupdateLocation()
            lblTermsandCondi.isHidden = false
            btnTermsandCondi.isHidden = false
            btnTermsandCondi.isSelected = true
        }else{
            swtchCft.isOn = false
           // OBJLOC.StopUpdateLocation()
            lblTermsandCondi.isHidden = true
            btnTermsandCondi.isHidden = true
            btnTermsandCondi.isSelected = false
        }
        
        let profile_pic = userInfo["profile_pic"] as? String ?? ""
        if profile_pic != "" {
            profileImg.imageFromServerURL(urlString: profile_pic)
            let path = profile_pic.replacingOccurrences(of: "https://successentellus.com/assets/uploads/", with: "")
            profileImgPath.text = path
        }else{
            profileImg.image = #imageLiteral(resourceName: "noImg")
            profileImgPath.text = "No file choosen"
        }
        
        let dreamImage = userInfo["dreamImage"] as? String ?? ""
        if dreamImage != "" {
            busiImg.imageFromServerURL(urlString: dreamImage)
            let path = dreamImage.replacingOccurrences(of: "https://successentellus.com/assets/uploads/", with: "")
            busiImgPath.text = path
        }else{
            busiImg.image = #imageLiteral(resourceName: "noImg")
            busiImgPath.text = "No file choosen"
        }
        
    }
    
    @IBAction func setProfileImage(_ sender:UIButton){
        
        let cameraViewController = CameraViewController { [weak self] image, asset in
            DispatchQueue.main.async(execute: {
                if let image = image {
                    self?.profileImg.image = image
                }
            })
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func setBusinessImage(_ sender:UIButton){
        
        let cameraViewController = CameraViewController { [weak self] image, asset in
            DispatchQueue.main.async(execute: {
                if let image = image {
                    self?.busiImg.image = image
                }
            })
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func updateProfile(_ sender:UIButton){
        
//        if isCftUser == "1"{
//            OBJLOC.StartupdateLocation()
//        }else{
//            OBJLOC.StopUpdateLocation()
//        }
        
        if self.validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForUpdateProfile()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }

//    @IBAction func actionAgreeCheck(_ sender : UIButton) {
//        sender.isSelected = !sender.isSelected
//    }
    
    @objc func actionCftYN(_ sender : UISwitch!) {
    
        if !sender.isOn {
            isCftUser = "0"
            sender.isOn = false
            self.btnTermsandCondi.isSelected = false
            OBJLOC.StopUpdateLocation()
            lblTermsandCondi.isHidden = true
            btnTermsandCondi.isHidden = true
            //btnTermsandCondi.isSelected = false
        }else{
            lblTermsandCondi.isHidden = false
            btnTermsandCondi.isHidden = false
            self.isCftUser = "1"
            sender.isOn = true
            OBJLOC.StartupdateLocation()
   
        }
    }
}

extension ChangeProfileVC {
    
    func apiCallForUpdateProfile(){
        
        var dictParam = [String:String]()
        dictParam["zo_user_id"] = userID
        dictParam["platform"] = "3"
        dictParam["first_name"] = txtFirstName.text!
        dictParam["last_name"] = txtLastName.text!
        dictParam["email"] = txtEmail.text!
        dictParam["phone"] = txtPhone.text!
        dictParam["userCity"] = txtCity.text!
        dictParam["userState"] = txtState.text!
        dictParam["userAddress"] = txtAddress.text!
        dictParam["userZipcode"] = txtPinCode.text!
        dictParam["userCountry"] = txtCountry.text!
        dictParam["reason"] = txtBusiReason.text!
        dictParam["user_category"] = ""
        dictParam["userCft"] = isCftUser
       
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "changeProfileIos", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
               // self.getUserData()
                
                DispatchQueue.main.async {
                    if self.profileImg.image != #imageLiteral(resourceName: "noImg")  || self.profileImg.image != nil{
                        self.uploadProfileImage(image: self.profileImg.image ?? #imageLiteral(resourceName: "noImg"))
                    }
                    if self.busiImg.image != #imageLiteral(resourceName: "noImg")  || self.busiImg.image != nil{
                        self.uploadBusinessImage(image: self.busiImg.image ?? #imageLiteral(resourceName: "noImg"))
                    }
                    self.getUserData()
                }
                
                OBJCOM.setAlert(_title: "", message: "Your profile updated successfully.")
                
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func uploadProfileImage(image:UIImage){
        
        if image == nil {
            OBJCOM.setAlert(_title: "", message: "Profile image is currupted, please upload image again.")
            return
        }
        
        let imgData = UIImageJPEGRepresentation(image, 0.2) ?? nil
        if imgData == nil {
            return
        }
    
        let parameters = ["zo_user_id": userID,
                          "folder_name": "profile",
                          "platform":"3"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "profile_pic",fileName: "profile_pic_\(userID).jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"uploadImage")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let  JSON : [String:Any]
                    if let json = response.result.value {
                        JSON = json as! [String : Any]
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            let result = JSON["result"] as AnyObject
                            UserDefaults.standard.set(result[0], forKey: "USERINFO")
                            UserDefaults.standard.synchronize()
                            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                            userID = userData["zo_user_id"] as! String
                            //print(UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any])
                            self.getUserData()
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func uploadBusinessImage(image:UIImage){
        
        if image == nil {
            OBJCOM.setAlert(_title: "", message: "Business image is currupted, please upload image again.")
            return
        }
        
        let imgData = UIImageJPEGRepresentation(image, 0.2) ?? nil
        if imgData == nil {
            return
        }
        
        let parameters = ["zo_user_id": userID,
                          "folder_name": "business",
                          "platform":"3"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData!, withName: "image_why_busuiness",fileName: "business_\(userID).jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"uploadImage")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let  JSON : [String:Any]
                    if let json = response.result.value {
                        JSON = json as! [String : Any]
                       // print(JSON)
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            let result = JSON["result"] as AnyObject
                            UserDefaults.standard.set(result[0], forKey: "USERINFO")
                            UserDefaults.standard.synchronize()
                            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                            userID = userData["zo_user_id"] as! String
                            print(UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any])
                            self.getUserData()
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func validate() -> Bool {
        
        if txtFirstName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter first name.")
            return false
        }else if txtLastName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter last name.")
            return false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter email address.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Enter valid email address.")
            return false
        }else if txtPhone.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter phone number.")
            return false
        }else if (txtPhone.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be greater than or equal to 5 digits.")
            return false
        }else if (txtPhone.text?.length)! > 20 {
            OBJCOM.setAlert(_title: "", message: "Phone number should be less than or equal to 19 digits.")
            return false
        }
//        else if btnTermsandCondi.isSelected == false {
//            OBJCOM.setAlert(_title: "", message: "If you want to become a CFT user, Please allow to access your current location in background.")
//            return false
//        }
        return true
    }
    
    @IBAction func resetPassword(_ sender:UIButton){
    
        if validatePassword() == true{
            var dictParam = [String:String]()
            dictParam["user_id"] = userID
            dictParam["oldpassword"] = txtCurrentPass.text ?? ""
            dictParam["newpassword"] = txtNewPass.text ?? ""
    
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "updatePassword", param:dictParam as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    //
                    OBJCOM.hideLoader()
                    let alertController = UIAlertController(title: "", message: "Your current session will be get logged out. Make sure your new Log In credentials are correct. Please Log In again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        let result = JsonDict!["result"] as! String
                        OBJCOM.setAlert(_title: "", message: result)
                        UserDefaults.standard.removeObject(forKey: "USERINFO")
                        UserDefaults.standard.synchronize()
                        let appDelegate = AppDelegate.shared
                        appDelegate.setRootVC()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                
                }else{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            };
        }
    }
    
    func validatePassword() -> Bool {
        if txtCurrentPass.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter current password.")
            return false
        }else if (txtCurrentPass.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Current password should be greater than or equal to 5 characters.")
            return false
        }
//        else if (txtCurrentPass.text?.length)! > 15 {
//            OBJCOM.setAlert(_title: "", message: "Current password should be greater than or equal to 15 characters.")
//            return false
//        }
        else if txtNewPass.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter new password.")
            return false
        }else if (txtNewPass.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "New password should be greater than or equal to 5 characters.")
            return false
        }
//        else if (txtNewPass.text?.length)! > 15 {
//            OBJCOM.setAlert(_title: "", message: "New password should be greater than or equal to 15 characters.")
//            return false
//        }
        else if txtConfirmPass.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter confirm password.")
            return false
        } else if txtConfirmPass.text != txtNewPass.text {
            OBJCOM.setAlert(_title: "", message: "New password and confirm password does not match. New password and confirm password fields must be same.")
            return false
        }
        return true
    }
}
