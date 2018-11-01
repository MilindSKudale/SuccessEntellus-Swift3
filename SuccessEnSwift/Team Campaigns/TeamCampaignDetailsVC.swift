//
//  TeamCampaignDetailsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TeamCampaignDetailsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var customCollectView : UICollectionView!
    @IBOutlet var campaignTitle : UILabel!
    @IBOutlet var noDataView : UIView!
    
    var campaignId = ""
    var campaignName = ""
    
    var bgColor = UIColor()
    var arrTemplateTitle = [String]()
    var arrTemplateId = [String]()
    var arrCampaignId = [String]()
    var arrInterval = [String]()
    var arrIntervalType = [String]()
    var arrCampaignStepSubject = [String]()
    var arrCampaignHTMLContent = [String]()
    var arrCampiagnEmailReminder = [String]()
//    var arrStepImages = [String]()
//    var arrAttachments = [AnyObject]()
    var arrTemplates = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.isHidden = true
        self.campaignTitle.text = self.campaignName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTeamCampaignTemplate(campaignID:self.campaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customCollectView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamCampaignDetailCell
        cell.labelCampaignName.text = arrTemplateTitle[indexPath.row]
        let strInterval = "\(self.arrInterval[indexPath.row]) \(self.arrIntervalType[indexPath.row])"
        cell.btnInterval.setTitle(strInterval, for: .normal)
        //cell.view.backgroundColor = bgColor.withAlphaComponent(0.5)
//        let imgUrl = self.arrStepImages[indexPath.row]
//        if imgUrl != "" {
//            cell.imgTemplate.imageFromServerURL(urlString: imgUrl)
//        }
        

        cell.btnInterval.tag = indexPath.row
        cell.btnCampPreview.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        
        
        cell.btnInterval.addTarget(self, action: #selector(actionUpdateTimeInterval(_:)), for: .touchUpInside)
        cell.btnCampPreview.addTarget(self, action: #selector(actionTemplatePreview(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(actionEditTemplate(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteTemplate(_:)), for: .touchUpInside)
        return cell
    }
    
    
    
    func getTeamCampaignTemplate(campaignID:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "teamCampaignId":campaignID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllTeamTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                if dictJsonData.count > 0 {
                    self.arrTemplateTitle = []
                    self.arrTemplateId = []
                    self.arrCampaignId = []
                    self.arrInterval = []
                    self.arrIntervalType = []
                    self.arrCampaignStepSubject = []
                    self.arrCampaignHTMLContent = []
                    self.arrCampiagnEmailReminder = []
                    self.arrTemplates = []
                    
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "teamCampaignStepTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "teamCampaignStepId") as! String)
                        self.arrCampaignId.append(obj.value(forKey: "teamCampaignStepCamId") as! String)
                        self.arrInterval.append(obj.value(forKey: "teamCampaignStepSendInterval") as! String)
                        self.arrIntervalType.append(obj.value(forKey: "teamCampaignStepSendIntervalType") as! String)
                        self.arrCampaignStepSubject.append(obj.value(forKey: "teamCampaignStepSubject") as! String)
                        self.arrCampaignHTMLContent.append(obj.value(forKey: "teamCampaignStepContent") as! String)
                        self.arrCampiagnEmailReminder.append(obj.value(forKey: "teamCampiagnEndStepEmailReminder") as! String)
                        self.arrTemplates.append(obj)
                    }
                }
                self.noDataView.isHidden = true
                self.customCollectView.delegate = self;
                self.customCollectView.dataSource = self
                self.customCollectView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noDataView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension TeamCampaignDetailsVC {
    @IBAction func actionTemplatePreview(_ sender : UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.ReloadTempData),
            name: NSNotification.Name(rawValue: "ReloadTempData"),
            object: nil)
        
        let dict = ["timeIntervalValue":self.arrInterval[sender.tag],
                    "timeIntervalType":self.arrIntervalType[sender.tag],
                    "emailSubject":self.arrTemplateTitle[sender.tag],
                    "emailHeading":self.arrCampaignStepSubject[sender.tag],
                    "templateId":self.arrTemplateId[sender.tag],
                    "campaignId":self.arrCampaignId[sender.tag],
                    "htmlString":self.arrCampaignHTMLContent[sender.tag],
                    "attachments":""] as [String : Any]
        
        
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTeamTemplatePreviewVC") as! TeamTemplatePreviewVC
        vc.htmlString = self.arrCampaignHTMLContent[sender.tag]
        vc.templateName = self.arrTemplateTitle[sender.tag]
        vc.isCustomCampaign = true
        vc.bgColor = bgColor
        vc.dictData = dict
        
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }

    
    @IBAction func actionUpdateTimeInterval(_ sender : UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.ReloadTempData),
            name: NSNotification.Name(rawValue: "ReloadTempData"),
            object: nil)
        
        let isSelfReminder = self.arrCampiagnEmailReminder[sender.tag]
        if isSelfReminder == "1" {
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSetTimeIntervalVC") as! SetTimeIntervalVC
            vc.isEditInterval = true
            vc.timeIntervalValue = self.arrInterval[sender.tag]
            vc.timeIntervalType = self.arrIntervalType[sender.tag]
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idNewEmailSetTimeIntervalVC") as! NewEmailSetTimeIntervalVC
            //vc.templateData = self.arrTemplateDats[sender.tag] as! [String : Any]
            vc.templateId = self.arrTemplateId[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func actionEditTemplate(_ sender : UIButton){
        
        
        
        let isSelfReminder = self.arrCampiagnEmailReminder[sender.tag]
        if isSelfReminder == "1" {
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateSelfReminder),
                name: NSNotification.Name(rawValue: "UpdateSelfReminder"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSetSelfReminderVC") as! SetSelfReminderVC
            vc.isUpdate = true
            vc.timeIntervalValue = self.arrInterval[sender.tag]
            vc.timeIntervalType = self.arrIntervalType[sender.tag]
            vc.campaignId = self.arrTemplateId[sender.tag]
            vc.reminderType = self.arrCampiagnEmailReminder[sender.tag]
            //   vc.txtNotes.text = self.arrCampaignHTMLContent[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        }else{
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.ReloadTempData),
                name: NSNotification.Name(rawValue: "ReloadTempData"),
                object: nil)
            let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEditTemplateVC") as! EditTemplateVC
           // vc.arrAttachments         = self.arrAttachments[sender.tag] as! [AnyObject]
            vc.timeIntervalValue      = self.arrInterval[sender.tag]
            vc.timeIntervalType       = self.arrIntervalType[sender.tag]
            vc.emailSubject           = self.arrCampaignStepSubject[sender.tag]
            vc.emailHeading           = self.arrTemplateTitle[sender.tag]
            vc.templateId             = self.arrTemplateId[sender.tag]
            vc.campaignId             = self.arrCampaignId[sender.tag]
            vc.htmlString             = self.arrCampaignHTMLContent[sender.tag]
            vc.isTempPrev = false
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle   = .crossDissolve
            vc.view.backgroundColor   = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
            
        }
    }
    
    @objc func ReloadTempData(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTeamCampaignTemplate(campaignID:self.campaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateSelfReminder(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTeamCampaignTemplate(campaignID:self.campaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionDeleteTemplate(_ sender : UIButton){
        
        let campId = self.arrCampaignId[sender.tag]
        let tempId = self.arrTemplateId[sender.tag]
        
        let alertController = UIAlertController(title: "", message: "https://successentellus.com says\nAre you sure you want to delete this email template?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deleteSelectedTemplate(strCampaignId: campId, strTemplateId: tempId)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteSelectedTemplate(strCampaignId : String, strTemplateId : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepCamId":strCampaignId,
                         "campaignStepId":strTemplateId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
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
                            self.getTeamCampaignTemplate(campaignID:self.campaignId)
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
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
