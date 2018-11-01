//
//  CustomCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 23/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CustomCampaignVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblCustomCampaign : UITableView!
    var bgColor = UIColor()
    var arrCampaignTitle = [String]()
    var arrCampaignId = [String]()
    var arrCampaignDays = [String]()
    var arrCampaignColor = [AnyObject]()
    var arrCampaignImage = [String]()
    var arrCampaignStepContent = [String]()
    let actionButton = JJFloatingActionButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblCustomCampaign.tableFooterView = UIView()
        
        
        actionButton.buttonColor = APPORANGECOLOR
        actionButton.addItem(title: "Create Campaign", image: #imageLiteral(resourceName: "ic_add_white")) { item in
            print("Action Float button")
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.addTemplate),
                name: NSNotification.Name(rawValue: "AddTemplate"),
                object: nil)
            self.createCampaign()
        }
        actionButton.display(inViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCampaignTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblCustomCampaign.dequeueReusableCell(withIdentifier: "CustomCampCell") as! CustomCampCell
        
        cell.lblCustomCampaign.text = arrCampaignTitle[indexPath.row]
        
        let imgUrl = self.arrCampaignImage[indexPath.row]
        if imgUrl != "" {
            cell.CustomCampaignIcon.imageFromServerURL(urlString: imgUrl)
        }
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let redColor = colorObj.object(at: 0)
            let blueColor = colorObj.object(at: 2)
            let greenColor = colorObj.object(at: 1)
            
            cell.viewBg.backgroundColor = UIColor.init(red: redColor as! Int, green: greenColor as! Int, blue: blueColor as! Int)
            cell.viewBg.layer.cornerRadius = 5.0;
        }
        cell.btnMoreOptions.tag = indexPath.row
        cell.btnAddEmail.tag = indexPath.row
        cell.btnMoreOptions.addTarget(self, action: #selector(actionMoreOptions(_:)), for: .touchUpInside)
        cell.btnAddEmail.addTarget(self, action: #selector(actionAddEmail(_:)), for: .touchUpInside)
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let redColor = colorObj.object(at: 0)
            let blueColor = colorObj.object(at: 2)
            let greenColor = colorObj.object(at: 1)
            
            bgColor = UIColor.init(red: redColor as! Int, green: greenColor as! Int, blue: blueColor as! Int)
        }
        
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCustomCampDetailVC") as! CustomCampDetailVC
        vc.companyCampaign = self.arrCampaignId[indexPath.row]
        vc.bgColor = bgColor
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func getEmailCampaignData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                self.arrCampaignImage = []
                self.arrCampaignColor = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as! String)
                    self.arrCampaignImage.append(obj.value(forKey: "campaignImage") as! String)
                    self.arrCampaignColor.append(obj.value(forKey: "campaignColor") as AnyObject)
                    
                }
                
//                if self.arrCampaignId.count > 0 {
//                    self.createSpotlight()
//                }
                
                self.tblCustomCampaign.delegate = self;
                self.tblCustomCampaign.dataSource = self
                self.tblCustomCampaign.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}



extension CustomCampaignVC {
    
    @IBAction func actionAddEmail(_ sender : UIButton){
        self.addMembersOptions(sender.tag)
    }
    
    func addMembersOptions(_ index:Int){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionSystemContacts = UIAlertAction(title: "From system contact(s)", style: .default)
        {
            UIAlertAction in
            //AddMembersSystemVC
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.addTemplate),
                name: NSNotification.Name(rawValue: "AddTemplate"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddMembersSystemVC") as! AddMembersSystemVC
            vc.CampaignType = "EmailCampaign"
            vc.CampaignId = self.arrCampaignId[index]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
//              vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
            
        }
        actionSystemContacts.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionManuallyContacts = UIAlertAction(title: "Add Member Manually", style: .default)
        {
            UIAlertAction in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.addTemplate),
                name: NSNotification.Name(rawValue: "AddTemplate"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddEmailTVC") as! AddEmailTVC
            vc.campaignTitle = self.arrCampaignTitle[index]
            vc.campaignId = self.arrCampaignId[index]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
             vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)

        }
        actionManuallyContacts.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionSystemContacts)
        alert.addAction(actionManuallyContacts)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTemplate(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getEmailCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionMoreOptions(_ sender : UIButton){
        selectMoreOptions(index: sender.tag)
    }
    
    func selectMoreOptions(index : Int) {
        let campTitle = self.arrCampaignTitle[index]
        let alert = UIAlertController(title: campTitle, message: nil, preferredStyle: .actionSheet)
        
        let actionCreateTemplate = UIAlertAction(title: "Create Template", style: .default)
        {
            UIAlertAction in
            self.createTemplate (index: index)
        }
        actionCreateTemplate.setValue(UIColor.black, forKey: "titleTextColor")
       // actionCreateTemplate.setValue(#imageLiteral(resourceName: "popup_createtemp") , forKey: "image")
        
        let actionImportTemplates = UIAlertAction(title: "Import Templates", style: .default)
        {
            UIAlertAction in
            self.importTemplate(index:index)
        }
        actionImportTemplates.setValue(UIColor.black, forKey: "titleTextColor")
        //actionImportTemplates.setValue(#imageLiteral(resourceName: "popup_import") , forKey: "image")
        
        let actionSetaSelfReminder = UIAlertAction(title: "Set a Self Reminder", style: .default)
        {
            UIAlertAction in
            self.setSelfReminder(index: index)
        }
        actionSetaSelfReminder.setValue(UIColor.black, forKey: "titleTextColor")
       // actionSetaSelfReminder.setValue(#imageLiteral(resourceName: "popup_reminder") , forKey: "image")
        
        let actionEditCampaign = UIAlertAction(title: "Edit Campaign", style: .default)
        {
            UIAlertAction in
            self.editCampaign(index: index)
        }
        actionEditCampaign.setValue(UIColor.black, forKey: "titleTextColor")
      //  actionEditCampaign.setValue(#imageLiteral(resourceName: "popup_edit") , forKey: "image")
        
        let actionDeleteCampaign = UIAlertAction(title: "Delete Campaign", style: .default)
        {
            UIAlertAction in
            self.deleteCampaign(index: index)
        }
        actionDeleteCampaign.setValue(UIColor.black, forKey: "titleTextColor")
       // actionDeleteCampaign.setValue(#imageLiteral(resourceName: "popup_delete") , forKey: "image")
        
        let actionRemoveMembers = UIAlertAction(title: "Remove Member(s)", style: .default)
        {
            UIAlertAction in
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idRemoveEmailVC") as! RemoveEmailVC
            vc.textCampaignId = self.arrCampaignId[index]
            vc.textCampaignName = self.arrCampaignTitle[index]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        }
        actionRemoveMembers.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Dismiss", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionCreateTemplate)
        alert.addAction(actionImportTemplates)
        alert.addAction(actionSetaSelfReminder)
        alert.addAction(actionEditCampaign)
        alert.addAction(actionDeleteCampaign)
        alert.addAction(actionRemoveMembers)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createCampaign () {
        
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpCreateCampaign") as! PopUpCreateCampaign
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}

extension CustomCampaignVC {
    func createTemplate (index:Int) {
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTemplateTypeSelectionVC") as! TemplateTypeSelectionVC
        vc.modalPresentationStyle = .custom
        vc.campaignId = self.arrCampaignId[index]
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func importTemplate(index:Int) {
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idImportTemplateVC") as! ImportTemplateVC
        vc.campaignId = self.arrCampaignId[index]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func setSelfReminder(index:Int) {
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idSetSelfReminderVC") as! SetSelfReminderVC
        vc.isUpdate = false
        vc.campaignId = self.arrCampaignId[index]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func editCampaign(index:Int) {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addTemplate),
            name: NSNotification.Name(rawValue: "AddTemplate"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditCampaignVC") as! EditCampaignVC
        vc.campaignName = self.arrCampaignTitle[index]
        vc.campaignId = self.arrCampaignId[index]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteCampaign(index:Int) {
        let campName = self.arrCampaignTitle[index]
        let campId = self.arrCampaignId[index]
        let alertController = UIAlertController(title: "", message: "Are you sure, you want to delete '\(campName)' campaign?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteCampaignAPICall(campId:campId)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteCampaignAPICall(campId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campIdToDelete":campId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getEmailCampaignData()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
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
}
