//
//  ImportTemplateVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ImportTemplateVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet weak var templateView: UIView!
    @IBOutlet weak var tblTemplateList: UITableView!
    @IBOutlet weak var heightTbl: NSLayoutConstraint!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnImport: UIButton!
    
    var arrCampaignTitle = [String]()
    var arrCampaignId = [AnyObject]()
    var arrUnAssignedCampaignId = [AnyObject]()
    var arrTemplateTitle = [String]()
    var arrTemplateId = [AnyObject]()
    
    var arrSelectedTemplates = [String]()
    
    var campaignId = ""
    var selectedCampaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // heightTbl.constant = 100
        templateView.isHidden = true
        btnClose.layer.cornerRadius = 5
        btnImport.layer.cornerRadius = 5
        btnImport.clipsToBounds = true
        btnClose.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getUnImportedCampaignsData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnImport(sender: UIButton) {
        if arrSelectedTemplates.count > 0 {
            let selTemplates = self.arrSelectedTemplates.joined(separator: ",")
            self.importTemplateAPI(selTemplates:selTemplates)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one template to import campaign.")
        }
    }
    
    func loadDropDown() {
        self.dropDown.textColor = .black
        self.dropDown.tint = .black
        self.dropDown.optionsSize = 15.0
        self.dropDown.placeholder = " Select Campaign"
        self.dropDown.optionsTextAlignment = NSTextAlignment.left
        self.dropDown.textAlignment = NSTextAlignment.left
        self.dropDown.options = self.arrCampaignTitle
        self.dropDown.didSelect { (item, index) in
            self.templateView.isHidden = false
            var strCampId = ""
            let campId = self.arrUnAssignedCampaignId[index]
            if campId.count > 0 {
                strCampId = campId.componentsJoined(by: ",")
            }
            self.selectedCampaignId = "\(self.arrCampaignId[index])"
            self.getTemplateListData(campId : strCampId)
        }
    }
    
    func getUnImportedCampaignsData(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "parentCampainId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getUnImportCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                self.arrCampaignId = []
                self.arrCampaignTitle = []
                self.arrUnAssignedCampaignId = []
                
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                       self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                        self.arrCampaignId.append(obj.value(forKey: "campaignId") as AnyObject)
                       self.arrUnAssignedCampaignId.append(obj.value(forKey: "unassingStepID") as AnyObject)
                    }
                }
                self.loadDropDown()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getTemplateListData(campId : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "unassingStepID":campId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getSelectedTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                self.arrTemplateId = []
                self.arrTemplateTitle = []
                if dictJsonData.count > 0 {
                    self.templateView.isHidden = false
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignStepId") as AnyObject)
                    }
                }
                self.tblTemplateList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.templateView.isHidden = true
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func importTemplateAPI(selTemplates:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "parentCampaignId":campaignId,
                         "listCampaignId":self.selectedCampaignId,
                         "listTemplateIds":selTemplates]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "importCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension ImportTemplateVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblTemplateList.dequeueReusableCell(withIdentifier: "Cell")
        
        cell?.textLabel?.text = self.arrTemplateTitle[indexPath.row]
        if arrSelectedTemplates.contains(self.arrTemplateId[indexPath.row] as! String){
            cell?.imageView?.image = #imageLiteral(resourceName: "checkbox_ic")
        }else{
            cell?.imageView?.image = #imageLiteral(resourceName: "uncheck")
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrSelectedTemplates.contains(self.arrTemplateId[indexPath.row] as! String){
            if let index = self.arrSelectedTemplates.index(of: self.arrTemplateId[indexPath.row] as! String) {
                self.arrSelectedTemplates.remove(at: index)
            }
        }else{
            self.arrSelectedTemplates.append(self.arrTemplateId[indexPath.row] as! String)
        }
        self.tblTemplateList.reloadData()
    }
}
