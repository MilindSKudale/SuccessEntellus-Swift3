//
//  AddEmailTVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddEmailTVC: UIViewController {
    
    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var txtFirstName : SkyFloatingLabelTextField!
    @IBOutlet var txtLastName : SkyFloatingLabelTextField!
    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
   // @IBOutlet var txtPhone : SkyFloatingLabelTextField!
    @IBOutlet var btnClose : UIButton!
    @IBOutlet var btnAddEmail : UIButton!
    @IBOutlet var btnAddAndStartCamp : UIButton!
 //   @IBOutlet var btnAddAndStartCampHeight : NSLayoutConstraint!
    
    var arrGroupTitle = [String]()
    var arrGroupID = [String]()
    
    var campaignTitle = ""
    var campaignId = ""
    var groupTitle = ""
    var groupId = ""
    var callFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        callFirst = true
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.dropDown.textColor = .black
            self.dropDown.tint = .black
            self.dropDown.optionsSize = 15.0
            self.dropDown.placeholder = " Select Group "
            self.dropDown.optionsTextAlignment = NSTextAlignment.left
            self.dropDown.textAlignment = NSTextAlignment.left
            DispatchQueue.main.async {
                self.getGroupData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
        btnClose.layer.cornerRadius = 5.0
        btnAddEmail.layer.cornerRadius = 5.0
        btnAddAndStartCamp.layer.cornerRadius = 5.0
        lblCampaignTitle.text = campaignTitle
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnAddEmail(_ sender: Any) {
        if isValidation() == true {
            checkEmailIsExists(isAdd:"0")
        }
    }
    @IBAction func actionBtnAddAndStartCampaign(_ sender: Any) {
        if isValidation() == true {
            checkEmailIsExists(isAdd:"1")
        }
    }
}

extension AddEmailTVC {
    func getGroupData() {
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
                self.arrGroupTitle = []
                self.arrGroupID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrGroupTitle.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupID.append(obj.value(forKey: "group_id") as! String)
                }
                
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func loadDropDown() {
        self.dropDown.textColor = .black
        self.dropDown.tint = .black
        self.dropDown.optionsSize = 15.0
        self.dropDown.placeholder = " Select Group"
        self.dropDown.optionsTextAlignment = NSTextAlignment.left
        self.dropDown.textAlignment = NSTextAlignment.left
        self.dropDown.options = self.arrGroupTitle
        self.dropDown.didSelect { (item, index) in
            if self.arrGroupTitle.count == 0 {
                OBJCOM.setAlert(_title: "", message: "No group assigned yet.")
                return
            }
            self.groupTitle = self.arrGroupTitle[index]
            self.groupId = self.arrGroupID[index]
            
        }
    }
    
    func checkEmailIsExists(isAdd:String) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "email":txtEmail.text!,
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "checkCampaignAlreadyAssign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                if isAdd == "1" {
                    self.addEmailAPI(addAndAssinged: "1")
                }else{
                    self.addEmailAPI(addAndAssinged: "0")
                }
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func addEmailAPI(addAndAssinged:String) {
        if callFirst == true {
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "fname":txtFirstName.text!,
                             "lname":txtLastName.text!,
                             "email":txtEmail.text!,
                             "phone":"",
                             "groupId":groupId,
                             "campaignId":campaignId,
                             "addAndAssinged":addAndAssinged]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "assignEmailCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
                JsonDict, staus in
                
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    OBJCOM.hideLoader()
                    let result = JsonDict!["result"] as! String
                    print(result)
                    let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                         NotificationCenter.default.post(name: Notification.Name("AddTemplate"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                }
            };
            callFirst = false
        }
    }
    
    func isValidation() -> Bool{
        var isValid = true
        if txtFirstName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter first name.")
            isValid = false
        }else if txtLastName.text == ""{
            OBJCOM.setAlert(_title: "", message: "Please enter last name.")
            isValid = false
        }else if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email address.")
            isValid = false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Please enter valid email address.")
            isValid = false
        }else{
            isValid = true
        }
        
        return isValid
    }
}
