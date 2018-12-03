//
//  TextCampDetailVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import McPicker

class TextCampDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var textCollectView : UICollectionView!
    @IBOutlet var campaignTitle : UILabel!
    @IBOutlet var noDataView : UIView!
    
    var arrIntervalTypeSet = [String]()
    var arrIntervalValue = [String]()
    
    var arrTemplateDats = [AnyObject]()
    var arrTemplateTitle = [String]()
    var arrTemplateId = [String]()
    var arrCampaignId = [String]()
    var arrInterval = [String]()
    var arrIntervalType = [String]()
    var arrTxtTemplateMsg = [String]()
    var arrTemplates = [AnyObject]()
    var arrIsPredefine = [String]()
    
    var textCampaignId = ""
    var textCampaignTitle = ""
    var isPredefined = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.campaignTitle.text = textCampaignTitle
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignTemplate(campaignID:self.textCampaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateTextTemplateVC(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignTemplate(campaignID:self.textCampaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = textCollectView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCampDetailCell
        
        cell.labelCampaignName.text = arrTemplateTitle[indexPath.row]
        let strInterval = "\(self.arrInterval[indexPath.row]) \(self.arrIntervalType[indexPath.row])"
        cell.btnInterval.setTitle(strInterval, for: .normal)
        
        cell.btnMemberDetails.tag = indexPath.row
        cell.btnInterval.tag = indexPath.row
        cell.btnCampPreview.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row

        cell.btnMemberDetails.addTarget(self, action: #selector(actionMemberDetails(_:)), for: .touchUpInside)
        cell.btnInterval.addTarget(self, action: #selector(actionUpdateTimeInterval(_:)), for: .touchUpInside)
        cell.btnCampPreview.addTarget(self, action: #selector(actionTextTemplatePreview(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(actionEditTextTemplate(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteCampaign(_:)), for: .touchUpInside)
        
        let isPredefine = arrIsPredefine[indexPath.row]
        if isPredefine == "1" {
            cell.btnInterval.isUserInteractionEnabled = false
            cell.btnEdit.isHidden = true
            cell.btnDelete.isHidden = true
        }else{
            cell.btnInterval.isUserInteractionEnabled = true
            cell.btnEdit.isHidden = false
            cell.btnDelete.isHidden = false
        }
        
        return cell
    }

    func getTextCampaignTemplate(campaignID:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":campaignID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrTemplateTitle = []
            self.arrTemplateId = []
            self.arrCampaignId = []
            self.arrInterval = []
            self.arrIntervalType = []
            self.arrTxtTemplateMsg = []
            self.arrTemplates = []
            self.arrIsPredefine = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                if dictJsonData.count > 0 {
                    for obj in dictJsonData {
                        self.arrTemplateDats.append(obj)
                        self.arrTemplateTitle.append(obj.value(forKey: "txtTemplateTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "txtTemplateId") as! String)
                        self.arrCampaignId.append(obj.value(forKey: "txtTemplateCampId") as! String)
                        self.arrInterval.append(obj.value(forKey: "txtTemplateInterval") as! String)
                        self.arrIntervalType.append(obj.value(forKey: "txtTemplateIntervalType") as! String)
                        self.arrTxtTemplateMsg.append(obj.value(forKey: "txtTemplateMsg") as! String)
                        self.arrIsPredefine.append(obj.value(forKey: "txtTemplateFeature") as! String)
                        self.arrTemplates.append(obj)
                    }
                    self.noDataView.isHidden = true
                }
                self.textCollectView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.textCollectView.reloadData()
                self.noDataView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
//            self.textCollectView.delegate = self;
//            self.textCollectView.dataSource = self
           
        };
    }
    
}

extension TextCampDetailVC {
    
    @objc func ReloadTempData(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTextCampaignTemplate(campaignID:self.textCampaignId)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionTextTemplatePreview(_ sender : UIButton){
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTextTemplatePreviewVC") as! TextTemplatePreviewVC
        vc.templateData = self.arrTemplateDats[sender.tag] as! [String : Any]
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.campaignName = textCampaignTitle
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
//        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionUpdateTimeInterval(_ sender : UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTextTemplateVC),
            name: NSNotification.Name(rawValue: "UpdateTextTemplateVC"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idNewSetTimeIntervalVC") as! NewSetTimeIntervalVC
        vc.templateData = self.arrTemplateDats[sender.tag] as! [String : Any]
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
   
    }
    
     @objc func actionEditTextTemplate(_ sender : UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTextTemplateVC),
            name: NSNotification.Name(rawValue: "UpdateTextTemplateVC"),
            object: nil)
        
        
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditTextCampTemplate") as! EditTextCampTemplate
        vc.templateData = self.arrTemplateDats[sender.tag] as! [String : Any]
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func actionDeleteCampaign (_ sender : UIButton) {
        
        let alertController = UIAlertController(title: "", message: "Do you really want to delete '\(self.arrTemplateTitle[sender.tag])' template?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteCampaign (sender.tag)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(actionCancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func deleteCampaign (_ index:Int) {
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":self.arrTemplateId[index]] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("UpdateTextTemplateVC"), object: nil)
                
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                    self.getTextCampaignTemplate(campaignID:self.textCampaignId)
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionMemberDetails(_ sender : UIButton){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTextTemplateVC),
            name: NSNotification.Name(rawValue: "UpdateTextTemplateVC"),
            object: nil)
    
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idMemberDetailsVC") as! MemberDetailsVC
        let temp = self.arrTemplates[sender.tag]
        let repeate = temp.value(forKey: "txtTemplateRepeat") as? String ?? "0"
        if repeate == "1"{
            vc.isRepeate = true
        }else{
            vc.isRepeate = false
        }
        vc.templateId = self.arrTemplateId[sender.tag]
        vc.campaignId = self.arrCampaignId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}



