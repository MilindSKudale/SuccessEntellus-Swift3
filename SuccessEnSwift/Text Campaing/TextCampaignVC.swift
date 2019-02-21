//
//  TextCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import EAIntroView

class TextCampaignVC : SliderVC, EAIntroDelegate {

    @IBOutlet var tblTextCampaign : UITableView!
    @IBOutlet var lblAvailTextMsg : UILabel!
    @IBOutlet var lblAvailTextMsgNoti : UILabel!
    @IBOutlet var heightLblAvailTextMsgNoti : NSLayoutConstraint!
    @IBOutlet var heightLblAvailTextMsg : NSLayoutConstraint!
    @IBOutlet var noRecView : UIView!
    let actionButton = JJFloatingActionButton()
    
    var arrCampaignData = [AnyObject]()
    var arrCampaignName = [String]()
    var arrCampaignId = [String]()
    var arrTemplateCount = [String]()
    var arrCampaignImage = [String]()
    var arrCampaignColor = [AnyObject]()
    var txtMsgCount = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Text Campaigns"
        self.tblTextCampaign.tableFooterView = UIView()
        noRecView.isHidden = true
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.heightLblAvailTextMsg.constant = 0
            self.heightLblAvailTextMsgNoti.constant = 0
            self.lblAvailTextMsg.isHidden = true
            self.lblAvailTextMsgNoti.isHidden = true
            self.view.layoutIfNeeded()
        })
        self.view.isUserInteractionEnabled = true
        
        actionButton.buttonColor = APPORANGECOLOR
        actionButton.addItem(title: "Create Campaign", image: #imageLiteral(resourceName: "ic_add_white")) { item in
            print("Action Float button")
            self.addCampaign()
        }
        actionButton.display(inViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTextCampaignFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
    }
    
    func getTextCampaignFromServer(){
        
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            self.arrCampaignName = []
            self.arrCampaignId = []
            self.arrTemplateCount = []
            self.arrCampaignImage = []
            self.arrCampaignColor = []
            self.txtMsgCount = "\(JsonDict!["txtMsgCount"] as AnyObject)"
            self.lblAvailTextMsg.text = "Available Text Message : \(self.txtMsgCount)"
            
            if self.txtMsgCount == "0" {
                
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightLblAvailTextMsg.constant = 0
                    self.heightLblAvailTextMsgNoti.constant = 70
                    self.lblAvailTextMsg.isHidden = true
                    self.lblAvailTextMsgNoti.isHidden = false
                    self.view.layoutIfNeeded()
                })
                
                self.view.isUserInteractionEnabled = false
        
                
            }else if self.txtMsgCount > "0" && self.txtMsgCount < "11" {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightLblAvailTextMsg.constant = 30
                    self.heightLblAvailTextMsgNoti.constant = 70
                    self.lblAvailTextMsg.isHidden = false
                    self.lblAvailTextMsgNoti.isHidden = false
                    self.view.layoutIfNeeded()
                })
                self.view.isUserInteractionEnabled = true
            }else{
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightLblAvailTextMsg.constant = 30
                    self.heightLblAvailTextMsgNoti.constant = 0
                    self.lblAvailTextMsg.isHidden = false
                    self.lblAvailTextMsgNoti.isHidden = true
                    self.view.layoutIfNeeded()
                })
                self.view.isUserInteractionEnabled = true
            }
            
            
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignData = JsonDict!["result"] as! [AnyObject]
                
               
                if self.arrCampaignData.count > 0 {
                    self.arrCampaignName = self.arrCampaignData.compactMap { $0["txtCampName"] as? String }
                    self.arrCampaignId = self.arrCampaignData.compactMap { $0["txtCampId"] as? String }
                    self.arrTemplateCount = self.arrCampaignData.compactMap { $0["txtTemplateCount"] as? String }
                    
                    self.arrCampaignImage = self.arrCampaignData.compactMap { $0["campaignImage"] as? String ?? "" }
                    self.arrCampaignColor = self.arrCampaignData.compactMap { $0["campaignColor"]} as [AnyObject]
                    
                }
                if self.arrCampaignName.count > 0 {
                    self.noRecView.isHidden = true
                }else{
                    self.noRecView.isHidden = false
                }
                self.tblTextCampaign.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblTextCampaign.reloadData()
                self.noRecView.isHidden = false
                OBJCOM.hideLoader()
            }
            
            DispatchQueue.main.async {
                if isFirstTimeTextCampaign == true {
                    let pages = ["CreateTextCamp1", "CreateTextCamp2"]
                    self.createIntroductionViewForEachModule(pages)
                    isFirstTimeTextCampaign = false
                }
            }
        }
    }
    
    @objc func addCampaign(){
        
        if self.txtMsgCount == "0" {
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTextCampaignVC),
            name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
            object: nil)
      
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAddTextCampaignVC") as! AddTextCampaignVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func UpdateTextCampaignVC(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTextCampaignFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension TextCampaignVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCampaignName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblTextCampaign.dequeueReusableCell(withIdentifier: "TextCell") as! TextCampaignCell
        
//        if let imgUrl = self.arrCampaignImage[indexPath.row] as? String ?? ""{
            if self.arrCampaignImage[indexPath.row] != "" {
                cell.imgView.imageFromServerURL(urlString: self.arrCampaignImage[indexPath.row])
            }else{
                cell.imgView.image = #imageLiteral(resourceName: "txt_camp")
            }
//        }
        
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let redColor = colorObj.object(at: 0)
            let blueColor = colorObj.object(at: 2)
            let greenColor = colorObj.object(at: 1)
            
            cell.vwCell.backgroundColor = UIColor.init(red: redColor as! Int, green: greenColor as! Int, blue: blueColor as! Int)
            cell.vwCell.layer.cornerRadius = 5.0;
        }
        
        cell.lblCampaignTitle.text = self.arrCampaignName[indexPath.row]
        cell.lblCampaignTitle.textColor = .white
        cell.btnOptions.tag = indexPath.row
        cell.btnOptions.addTarget(self, action: #selector(selectMenuOptions(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTextCampDetailVC") as! TextCampDetailVC
        vc.textCampaignId = self.arrCampaignId[indexPath.row]
        vc.textCampaignTitle = self.arrCampaignName[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}

extension TextCampaignVC {
    @IBAction func selectMenuOptions (_ sender:UIButton) {
        
        let selectedObj = self.arrCampaignData[sender.tag]
        let isPredefine = selectedObj["txtCampfeature"] as? String ?? "0"
        
        if isPredefine == "1" {
            self.selectMenuOptionsForPredefineCampaigns(sender.tag)
        }else{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionCreateTextMessage = UIAlertAction(title: "Create Text Message", style: .default)
            {
                UIAlertAction in
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.UpdateTextCampaignVC),
                    name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
                    object: nil)
                
                let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idCreateTextMessageVC") as! CreateTextMessageVC
                vc.campaignId = self.arrCampaignId[sender.tag]
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
                
            }
            actionCreateTextMessage.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionStartCamp = UIAlertAction(title: "Start Campaign", style: .default)
            {
                UIAlertAction in
                if self.arrTemplateCount[sender.tag] != "" && self.arrTemplateCount[sender.tag] != "0" {
                    self.startTextCampaigns(index:sender.tag)
                }else{
                    OBJCOM.setAlert(_title: "", message: "You cannot start campaign, because template or members is not added in this campaign.")
                }
            }
            actionStartCamp.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionAddMembers = UIAlertAction(title: "Add Member", style: .default)
            {
                UIAlertAction in
                let count = self.arrTemplateCount[sender.tag]
                if count == "0" {
                    OBJCOM.setAlert(_title: "", message: "You cannot add members, because template is not added in this campaign.")
                }else{
                    self.addMembersOptions(sender.tag)
                }
            }
            actionAddMembers.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionRemoveMembers = UIAlertAction(title: "Assigned Members", style: .default)
            {
                UIAlertAction in
                let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idRemoveMemberVC") as! RemoveMemberVC
                vc.textCampaignId = self.arrCampaignId[sender.tag]
                vc.textCampaignName = self.arrCampaignName[sender.tag]
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }
            actionRemoveMembers.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionEditCampaign = UIAlertAction(title: "Rename Campaign", style: .default)
            {
                UIAlertAction in
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.UpdateTextCampaignVC),
                    name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
                    object: nil)
                
                let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "idEditTextCampaignVC") as! EditTextCampaignVC
                vc.txtCampId = self.arrCampaignId[sender.tag]
                vc.textCampaignTitle = self.arrCampaignName[sender.tag]
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
                
            }
            actionEditCampaign.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionDeleteCampaign = UIAlertAction(title: "Delete Campaign", style: .default)
            {
                UIAlertAction in
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.UpdateTextCampaignVC),
                    name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
                    object: nil)
                self.deleteCampaignAlert(sender.tag)
                
            }
            actionDeleteCampaign.setValue(UIColor.black, forKey: "titleTextColor")
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            {
                UIAlertAction in
            }
            actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
            
            alert.addAction(actionCreateTextMessage)
            alert.addAction(actionAddMembers)
            alert.addAction(actionStartCamp)
            alert.addAction(actionRemoveMembers)
            alert.addAction(actionEditCampaign)
            alert.addAction(actionDeleteCampaign)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func selectMenuOptionsForPredefineCampaigns (_ tag:Int) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionStartCamp = UIAlertAction(title: "Start Campaign", style: .default)
        {
            UIAlertAction in
            if self.arrTemplateCount[tag] != "" && self.arrTemplateCount[tag] != "0" {
                self.startTextCampaigns(index:tag)
            }else{
                OBJCOM.setAlert(_title: "", message: "You cannot start campaign, because template or members is not added in this campaign.")
            }
        }
        actionStartCamp.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionAddMembers = UIAlertAction(title: "Add Member", style: .default)
        {
            UIAlertAction in
            let count = self.arrTemplateCount[tag]
            if count == "0" {
                OBJCOM.setAlert(_title: "", message: "You cannot add members, because template is not added in this campaign.")
            }else{
                self.addMembersOptions(tag)
            }
        }
        actionAddMembers.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionRemoveMembers = UIAlertAction(title: "Assigned Members", style: .default)
        {
            UIAlertAction in
            let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idRemoveMemberVC") as! RemoveMemberVC
            vc.textCampaignId = self.arrCampaignId[tag]
            vc.textCampaignName = self.arrCampaignName[tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
            
        }
        actionRemoveMembers.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionAddMembers)
        alert.addAction(actionStartCamp)
        alert.addAction(actionRemoveMembers)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func startTextCampaigns (index:Int) {
        let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idStartTextCampaignVC") as! StartTextCampaignVC
        vc.modalPresentationStyle = .custom
        vc.campaignId = self.arrCampaignId[index]
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteCampaignAlert (_ index:Int) {
        
        let alertController = UIAlertController(title: "", message: "Do you really want to delete '\(self.arrCampaignName[index])' campaign?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteCampaign (index)
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
                         "campIdToDelete":self.arrCampaignId[index]] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("UpdateTextCampaignVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    func addMembersOptions(_ index:Int){
       
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionSystemContacts = UIAlertAction(title: "From system contact(s)", style: .default)
        {
            UIAlertAction in
            //AddMembersSystemVC
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateTextCampaignVC),
                name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddMembersSystemVC") as! AddMembersSystemVC
            vc.CampaignType = "TextCampaign"
            vc.CampaignId = self.arrCampaignId[index]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
          //  vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
            
        }
        actionSystemContacts.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionManuallyContacts = UIAlertAction(title: "Add Member Manually", style: .default)
        {
            UIAlertAction in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.UpdateTextCampaignVC),
                name: NSNotification.Name(rawValue: "UpdateTextCampaignVC"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "TextCampaign", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddMembersManualVC") as! AddMembersManualVC
            vc.CampaignId = self.arrCampaignId[index]
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
    
    @IBAction func actionMenu(_ sender: AnyObject) {
        if self.txtMsgCount == "0" {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionWeeklyArchive = UIAlertAction(title: "Help", style: .default)
        {
            UIAlertAction in
            self.actionHelpMenuOptions()
        }
        actionWeeklyArchive.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionWeeklyArchive)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func actionHelpMenuOptions(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCreateCamp = UIAlertAction(title: "How to create text campaign?", style: .default)
        {
            UIAlertAction in
            let pages = ["CreateTextCamp1", "CreateTextCamp2"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionCreateCamp.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCreateMsg = UIAlertAction(title: "How to create message?", style: .default)
        {
            UIAlertAction in
            let pages = ["CreateMsg1", "CreateMsg2", "CreateMsg3", "CreateMsg4", "CreateMsg5"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionCreateMsg.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionAddMember = UIAlertAction(title: "How to add member(s)?", style: .default)
        {
            UIAlertAction in
            let pages = ["AddMember1", "AddMember2", "AddMember3", "AddMember4", "AddMember5"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionAddMember.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionCreateCamp)
        alert.addAction(actionCreateMsg)
        alert.addAction(actionAddMember)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createIntroductionViewForEachModule(_ arrScreens : [String]){
        var pages = [EAIntroPage]()
        for screen in arrScreens {
            let page = EAIntroPage.init(customViewFromNibNamed: screen)
            pages.append(page!)
        }
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: pages)
        introView?.delegate = self
        introView?.show(in: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
    }
}
