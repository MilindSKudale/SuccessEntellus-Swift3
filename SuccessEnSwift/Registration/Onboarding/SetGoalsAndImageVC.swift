//
//  SetGoalsAndImageVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import ALCameraViewController

class SetGoalsAndImageVC: UIViewController {

    let alert: UIAlertView = UIAlertView()
    @IBOutlet var uiView : UIView!
    @IBOutlet var btnLetGo : UIButton!
    @IBOutlet var btnChooseImage : UIButton!
    @IBOutlet var txtBusiReason : UITextField!
    @IBOutlet var txtMobile : UITextField!
    @IBOutlet var imgView : UIImageView!
    
    var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flag = true
        btnLetGo.layer.cornerRadius = btnLetGo.frame.height/2
        btnLetGo.clipsToBounds = true
        uiView.layer.cornerRadius = 8.0
        uiView.clipsToBounds = true
        btnChooseImage.layer.cornerRadius = 5.0
        btnChooseImage.clipsToBounds = true
        
        imgView.layer.cornerRadius = 5.0
        imgView.layer.borderColor = APPGRAYCOLOR.cgColor
        imgView.layer.borderWidth = 0.3
        imgView.clipsToBounds = true
        
        imgView.image = #imageLiteral(resourceName: "noImg")
    }
    
    @IBAction func actionLetsGo(_ sender:UIButton){
    
        var imgStr = ""
        if imgView.image ==  #imageLiteral(resourceName: "noImg") {
            imgStr = ""
        }else if imgView.image == nil{
            imgStr = ""
        }else{
            imgStr = (imgView.image?.base64(format: .png))!
        }

        if validate() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSubmit(imgStr: imgStr)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        
    }
    
    func apiCallForSubmit(imgStr:String){
        var dictParam = [String:String]()
        dictParam["user_id"] = userID
        dictParam["Imagebuisness"] = imgStr
        dictParam["platform"] = "3"
        dictParam["reason"] = txtBusiReason.text ?? ""
        dictParam["phone"] = txtMobile.text ?? ""
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "motivational", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["loginResult"] as AnyObject
                let resultMsg = JsonDict!["result"] as! String
                
                UserDefaults.standard.set(result[0], forKey: "USERINFO")
                UserDefaults.standard.synchronize()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                userID = userData["zo_user_id"] as! String
                print(UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any])
//                let alertController = UIAlertController(title: "", message: resultMsg, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                    UIAlertAction in
                
                OBJCOM.hideLoader()
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idUploadContactsVC") as! UploadContactsVC
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: false, completion: nil)
//                    if self.flag == true {
//                        self.flag = false
//                        isOnboarding = false
//                        isOnboard = "true"
//                        let appDelegate = AppDelegate.shared
//                        appDelegate.setRootVC()
//                    }
//                }
//                alertController.addAction(okAction)
//                self.present(alertController, animated: true, completion: nil)
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionChooseImage(_ sender:UIButton){
        let cameraViewController = CameraViewController { [weak self] image, asset in
            DispatchQueue.main.async(execute: {
                if let image = image {
                    self?.imgView.image = image
                }
            })
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }

    func convertImageToBase64(image: UIImage) -> String {
        let imageData = UIImagePNGRepresentation(image)!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func validate() -> Bool{
        if txtBusiReason.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your valuable business reason.")
            return false
        }else if (txtBusiReason.text?.length)! > 139 {
            OBJCOM.setAlert(_title: "", message: "Your business reason be less than or equal to 138 characters.")
            return false
        }else if txtMobile.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter your mobile number.")
            return false
        }else if (txtMobile.text?.length)! < 5 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be greater than or equal to 5 digits.")
            return false
        }else if (txtMobile.text?.length)! > 19 {
            OBJCOM.setAlert(_title: "", message: "Mobile number should be less than or equal to 19 digits.")
            return false
        }
        return true
    }
}

public enum ImageFormat {
    case png
    case jpeg(CGFloat)
}

extension UIImage {
    
    public func base64(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = UIImagePNGRepresentation(self)
        case .jpeg(let compression): imageData = UIImageJPEGRepresentation(self, compression)
        }
        return imageData?.base64EncodedString()
    }
}
