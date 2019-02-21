//
//  AddToGroupMultipleVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 05/01/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class AddToGroupMultipleVC: UIViewController {
    
    @IBOutlet var rbExistingGrp : UIButton!
    @IBOutlet var rbNewGrp : UIButton!
    @IBOutlet var btnAddGroup : UIButton!
    @IBOutlet var viewEG : UIView!
    @IBOutlet var viewNG : UIView!
    //@IBOutlet var txtSelectGroup : UITextField!
    @IBOutlet var txtGroupName : UITextField!
    @IBOutlet var txtGroupDesc : UITextField!
    @IBOutlet var viewEGHeight : NSLayoutConstraint!
    @IBOutlet var viewNGHeight : NSLayoutConstraint!
    @IBOutlet weak var ddSelectGroup : UIDropDown!
    
    var arrGroupTitle = [String]()
    var arrGroupId = [String]()
    
    var groupName = ""
    var groupId = ""
    var selectedIDs = ""
    var isExistingGrp = "YES"
    
    var className = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 10.0
        
        btnAddGroup.layer.cornerRadius = 5.0
        btnAddGroup.clipsToBounds = true
        
//        txtSelectGroup.layer.cornerRadius = 5.0
//        txtSelectGroup.layer.borderColor = APPGRAYCOLOR.cgColor
//        txtSelectGroup.layer.borderWidth = 1
//        txtSelectGroup.clipsToBounds = true
        
        txtGroupName.layer.cornerRadius = 5.0
        txtGroupName.layer.borderColor = APPGRAYCOLOR.cgColor
        txtGroupName.layer.borderWidth = 1
        txtGroupName.clipsToBounds = true
        
        txtGroupDesc.layer.cornerRadius = 5.0
        txtGroupDesc.layer.borderColor = APPGRAYCOLOR.cgColor
        txtGroupDesc.layer.borderWidth = 1
        txtGroupDesc.clipsToBounds = true
        
        self.ddSelectGroup.borderColor = APPGRAYCOLOR
        self.ddSelectGroup.cornerRadius = 5.0
        self.ddSelectGroup.borderWidth = 1
        self.ddSelectGroup.textColor = .black
        self.ddSelectGroup.placeholder = "  Please select group"
        self.ddSelectGroup.optionsTextAlignment = NSTextAlignment.left
        self.ddSelectGroup.textAlignment = NSTextAlignment.left
        self.ddSelectGroup.uiView.backgroundColor = .white
        self.ddSelectGroup.optionsSize = 15.0
        self.ddSelectGroup.rowHeight = 30.0
        self.ddSelectGroup.tableHeight = 150.0
        
        groupName = ""
        groupId = ""
        isExistingGrp = "YES"
       // txtSelectGroup.text = groupName
        self.rbExistingGrp.isSelected = true
        self.rbNewGrp.isSelected = false
        self.viewEG.isHidden = false
        self.viewNG.isHidden = true
        viewEGHeight.constant = 40.0
        self.ddSelectGroup.isHidden = false
        viewNGHeight.constant = 0.0
        
//        txtSelectGroup.rightViewMode = UITextFieldViewMode.always
//        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
//        let imageView = UIImageView(frame: CGRect(x: 5, y: 10, width: 20, height: 20))
//        let image = #imageLiteral(resourceName: "arrow-down")
//
//        imageView.image = image
//        imageView.contentMode = .center
//        uiView.addSubview(imageView)
//        txtSelectGroup.rightView = uiView
//        txtSelectGroup.delegate = self
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionCancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSelectExistingGroup(_ sender:UIButton){
        isExistingGrp = "YES"
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.viewEGHeight.constant = 40.0
            self.viewNGHeight.constant = 0.0
            self.ddSelectGroup.isHidden = false
        }
        rbExistingGrp.isSelected = true
        self.rbNewGrp.isSelected = false
        self.viewEG.isHidden = false
        self.viewNG.isHidden = true
    }
    
    @IBAction func actionSelectNewGroup(_ sender:UIButton){
        isExistingGrp = "NO"
        self.ddSelectGroup.resignFirstResponder()
        rbExistingGrp.isSelected = false
        self.rbNewGrp.isSelected = true
        self.viewEG.isHidden = true
        self.viewNG.isHidden = false
        self.ddSelectGroup.isHidden = true
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.viewEGHeight.constant = 0.0
            self.viewNGHeight.constant = 140.0
        }
    }
    
    @IBAction func actionAddToGroup(_ sender:UIButton){
        
        if isExistingGrp == "YES" {
            updateExistingGroup()
        }else{
            createNewGroup()
        }
    }
}

extension AddToGroupMultipleVC {
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
                self.arrGroupTitle = []
                self.arrGroupId = []
                for obj in result {
                    self.arrGroupTitle.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupId.append(obj.value(forKey: "group_id")  as! String)
                }
                self.loadDD()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func loadDD() {
//        self.ddSelectGroup.borderColor = APPGRAYCOLOR
//        self.ddSelectGroup.cornerRadius = 5.0
//        self.ddSelectGroup.borderWidth = 1
//        self.ddSelectGroup.textColor = .black
//        self.ddSelectGroup.placeholder = "  Please select group"
        self.ddSelectGroup.options = self.arrGroupTitle
        
        
        self.ddSelectGroup.didSelect { (option, index) in
            print("You just select: \(option) at index: \(index)")
            self.groupName = self.arrGroupTitle[index]
            self.groupId = self.arrGroupId[index]
        }
    }
    
//    func selectGroup(){
//        let alert = UIAlertController(title: "Select Group", message: nil, preferredStyle: .actionSheet)
//        if self.arrGroupTitle.count == 0 {
//            OBJCOM.setAlert(_title: "", message: "No group assigned yet.")
//            return
//        }
//        for i in self.arrGroupTitle {
//            alert.addAction(UIAlertAction(title: i, style: .default, handler: doSomething))
//        }
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
//        self.present(alert, animated: true, completion: nil)
//    }
    
//    func doSomething(action: UIAlertAction) {
//        //Use action.title
//        print(action.title ?? "")
//        groupName = action.title ?? ""
//        self.txtSelectGroup.text = groupName
//        for i in 0..<self.arrGroupTitle.count {
//            if action.title == self.arrGroupTitle[i] {
//                groupId = self.arrGroupId[i]
//            }
//        }
//    }
    
    func createNewGroup(){
        if txtGroupName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter group name.")
            return
        } else if self.selectedIDs == "" {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one group member.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.addToNewGroup(strSelect: selectedIDs)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }

    func updateExistingGroup(){
        if self.groupName == "" {
            OBJCOM.setAlert(_title: "", message: "Please select group.")
            return
        }else if groupId == "" {
            OBJCOM.setAlert(_title: "", message: "Something went wrong.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.addToExistingGroup(strSelect: selectedIDs)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func addToNewGroup(strSelect:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":txtGroupName.text!,
                         "group_description":txtGroupDesc.text!,
                         "group_id": "0",
                         "groupExistingFlag": "0",
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCrmMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
               
                let result = JsonDict!["result"] as? String ?? ""
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if self.className == "Prospect"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.className == "Contact"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if self.className == "Customer"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if self.className == "Recruit"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }

    func addToExistingGroup(strSelect:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":"",
                         "group_description":"",
                         "group_id": self.groupId,
                         "groupExistingFlag": "1",
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCrmMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let result = JsonDict!["result"] as? String ?? ""
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if self.className == "Prospect"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if self.className == "Contact"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if self.className == "Customer"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if self.className == "Recruit"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}

//extension AddToGroupMultipleVC : UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == txtSelectGroup {
//            selectGroup()
//            return false
//        }else{
//            return true
//        }
//    }
//}
