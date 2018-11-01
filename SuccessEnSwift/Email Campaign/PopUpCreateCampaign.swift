//
//  PopUpCreateCampaign.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PopUpCreateCampaign: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtCampaignName : UITextField!
    @IBOutlet var DDSelectCampaign : UIDropDown!
    @IBOutlet var campaignAndTemplateView : UIView!
    @IBOutlet var templateList : UITableView!
    @IBOutlet var btnCompanyCampaign : UIButton!
    @IBOutlet var btnCustomCampaign : UIButton!
    @IBOutlet var btnBothCampaign : UIButton!
    @IBOutlet var btnNoneOfThem : UIButton!
    @IBOutlet var noTemplateView : UIView!
    
    var arrCampaignTitle = [String]()
    var arrCampaignID = [String]()
    var arrTemplateTitle = [String]()
    var arrTemplateID = [String]()
    var arrSelectedTemplate = [String]()
    
    var isCompanyCampaign = true
    
    var campaignTitle = " "
    var campaignId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        noTemplateView.isHidden = true
        templateList.tableFooterView = UIView()
        btnNoneOfThem.isSelected = true
        campaignAndTemplateView.isHidden = true
        self.isCompanyCampaign = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionBtnSave(_ sender: Any) {
        if isValidation() == true {
            let campStepId = self.arrSelectedTemplate.joined(separator: ",")
            print(campStepId)
            addCampaignAPI(campStepId: campStepId)
        }
    }
}

extension PopUpCreateCampaign {
    func getCampaignData(dictParam : [String:String], action:String) {
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignID.append(obj.value(forKey: "campaignId") as! String)
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
        self.DDSelectCampaign.textColor = .black
        self.DDSelectCampaign.tint = .black
        self.DDSelectCampaign.optionsSize = 15.0
        self.DDSelectCampaign.placeholder = " Select Campaign"
        self.DDSelectCampaign.optionsTextAlignment = NSTextAlignment.left
        self.DDSelectCampaign.textAlignment = NSTextAlignment.left
        self.DDSelectCampaign.options = self.arrCampaignTitle
        campaignTitle = " Select Campaign"
        self.DDSelectCampaign.didSelect { (item, index) in
            self.campaignTitle = self.arrCampaignTitle[index]
            self.campaignId = self.arrCampaignID[index]
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    if self.isCompanyCampaign == true {
                        self.getTemplateData(campaignId:self.campaignId, action: "getCampaignEmailTemplate")
                    }else{
                        self.getTemplateData(campaignId:self.campaignId, action: "getCampaignEmailWithoutSelfTemplate")
                    }
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        
        self.arrTemplateTitle = []
        self.arrTemplateID = []
        self.templateList.reloadData()
    }
    
    func getTemplateData(campaignId : String, action:String) {
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]//
        OBJCOM.modalAPICall(Action: action, param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrTemplateTitle = []
                self.arrTemplateID = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                self.noTemplateView.isHidden = true
                for obj in dictJsonData {
                    self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                    self.arrTemplateID.append(obj.value(forKey: "campaignStepId") as! String)
                }
                OBJCOM.hideLoader()
            }else{
                self.noTemplateView.isHidden = false
                self.arrTemplateTitle = []
                self.arrTemplateID = []
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.templateList.reloadData()
            
        };
    }
    
    func addCampaignAPI(campStepId:String) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignTitle":self.txtCampaignName.text!,
                         "campaignSteps":campStepId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
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
    }
    
    func isValidation() -> Bool{
        var isValid = true
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name.")
            isValid = false
        }else{
            isValid = true
        }
        
        return isValid
    }
}

extension PopUpCreateCampaign : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = templateList.dequeueReusableCell(withIdentifier: "TemplateCell")
        cell?.textLabel?.text = self.arrTemplateTitle[indexPath.row]
        if arrSelectedTemplate.contains(arrTemplateID[indexPath.row]){
            cell?.imageView?.image = #imageLiteral(resourceName: "checkbox_ic")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "uncheck")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrSelectedTemplate.contains(arrTemplateID[indexPath.row]){
            if let index = arrSelectedTemplate.index(of: arrTemplateID[indexPath.row]) {
                arrSelectedTemplate.remove(at: index)
            }
        }else{
            arrSelectedTemplate.append(arrTemplateID[indexPath.row])
        }
        self.templateList.reloadData()
    }
}

extension PopUpCreateCampaign {
    @IBAction func actionBtnCompanyCampaign(sender: UIButton) {
        txtCampaignName.resignFirstResponder()
        btnCompanyCampaign.isSelected = true
        btnCustomCampaign.isSelected = false
        btnBothCampaign.isSelected = false
        btnNoneOfThem.isSelected = false
        campaignAndTemplateView.isHidden = false
        self.isCompanyCampaign = true
        self.DDSelectCampaign.resignFirstResponder()
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "companyCampaign":"1"]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam: dictParam, action:"getCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnCustomCampaign(sender: UIButton) {
        txtCampaignName.resignFirstResponder()
        btnCompanyCampaign.isSelected = false
        btnCustomCampaign.isSelected = true
        btnBothCampaign.isSelected = false
        btnNoneOfThem.isSelected = false
        campaignAndTemplateView.isHidden = false
        self.isCompanyCampaign = false
        self.DDSelectCampaign.resignFirstResponder()
        
        let dictParam = ["userId": userID,
                          "platform":"3"]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam : dictParam, action:"getCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnBothCampaign(sender: UIButton) {
        txtCampaignName.resignFirstResponder()
        btnCompanyCampaign.isSelected = false
        btnCustomCampaign.isSelected = false
        btnBothCampaign.isSelected = true
        btnNoneOfThem.isSelected = false
        campaignAndTemplateView.isHidden = false
        self.isCompanyCampaign = false
        self.DDSelectCampaign.resign()
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getCampaignData(dictParam : dictParam, action:"getAllCampaign")
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnNoneOfThem(sender: UIButton) {
        txtCampaignName.resignFirstResponder()
        btnCompanyCampaign.isSelected = false
        btnCustomCampaign.isSelected = false
        btnBothCampaign.isSelected = false
        btnNoneOfThem.isSelected = true
        campaignAndTemplateView.isHidden = true
        self.isCompanyCampaign = false
        self.DDSelectCampaign.resign()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        txtCampaignName.resignFirstResponder()
    }
    
}
