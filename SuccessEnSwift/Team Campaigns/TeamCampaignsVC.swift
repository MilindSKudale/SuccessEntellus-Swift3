//
//  TeamCampaignsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TeamCampaignsVC: SliderVC {
    
    @IBOutlet var tblTeamCampaign : UITableView!
    @IBOutlet var noRecView : UIView!
    
    var arrCampaignData = [AnyObject]()
    var arrCampaignName = [String]()
    var arrCampaignId = [String]()
    var arrCampaignImage = [String]()
    var arrCampaignColor = [AnyObject]()
    var arrTemplateCount = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Team Campaigns"
        self.tblTeamCampaign.tableFooterView = UIView()
        noRecView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTeamCampaignFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getTeamCampaignFromServer(){
        
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllTeamCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            self.arrCampaignName = []
            self.arrCampaignId = []
            self.arrCampaignImage = []
            self.arrCampaignColor = []
            self.arrTemplateCount = []
        
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignData = JsonDict!["result"] as! [AnyObject]
                if self.arrCampaignData.count > 0 {
                    self.arrCampaignName = self.arrCampaignData.compactMap { $0["teamCampaignTitle"] as? String }
                    self.arrCampaignId = self.arrCampaignData.compactMap { $0["teamCampaignId"] as? String }
                    self.arrCampaignImage = self.arrCampaignData.compactMap { $0["campaignImage"] as? String ?? "" }
                    self.arrCampaignColor = self.arrCampaignData.compactMap { $0["campaignColor"]} as [AnyObject]
                    self.arrTemplateCount = self.arrCampaignData.compactMap { $0["templateCount"] as? String ?? ""}
                    
                }
                if self.arrCampaignName.count > 0 {
                    self.noRecView.isHidden = true
                }else{
                    self.noRecView.isHidden = false
                }
                self.tblTeamCampaign.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblTeamCampaign.reloadData()
                self.noRecView.isHidden = false
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func addTeamCampaign(_ sender:AnyObject){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateTeamCampaignVC),
            name: NSNotification.Name(rawValue: "UpdateTeamCampaignVC"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAddTeamCampaignVC") as! AddTeamCampaignVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func UpdateTeamCampaignVC(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getTeamCampaignFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

}


extension TeamCampaignsVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCampaignName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblTeamCampaign.dequeueReusableCell(withIdentifier: "TeamCell") as! TeamCampaignCell
        
        let imgUrl = self.arrCampaignImage[indexPath.row]
        if imgUrl != "" {
            cell.imgView.imageFromServerURL(urlString: imgUrl)
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "team_ic")
        }
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
        cell.btnShareCamp.tag = indexPath.row
        cell.btnOptions.addTarget(self, action: #selector(selectMenuOptions(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let templateCount = self.arrTemplateCount[indexPath.row]
        
        if templateCount == "0" {
            return
        }
        
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTeamCampaignDetailsVC") as! TeamCampaignDetailsVC
        vc.campaignName = self.arrCampaignName[indexPath.row]
        vc.campaignId = self.arrCampaignId[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
   
}

extension TeamCampaignsVC {
    @IBAction func selectMenuOptions (_ sender:UIButton) {
    
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionCreateTemplate = UIAlertAction(title: "Create Template", style: .default)
        {
            UIAlertAction in
            self.createTemplate (index: sender.tag)
        }
        actionCreateTemplate.setValue(UIColor.black, forKey: "titleTextColor")
       
        let actionImportTemplates = UIAlertAction(title: "Import Templates", style: .default)
        {
            UIAlertAction in
            self.importTemplate(index:sender.tag)
        }
        actionImportTemplates.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionSetaSelfReminder = UIAlertAction(title: "Set a Self Reminder", style: .default)
        {
            UIAlertAction in
            self.setSelfReminder(index: sender.tag)
        }
        actionSetaSelfReminder.setValue(UIColor.black, forKey: "titleTextColor")
        

        let actionEditCampaign = UIAlertAction(title: "Edit Campaign", style: .default)
        {
            UIAlertAction in
            self.editCampaign(index: sender.tag)
        }
        actionEditCampaign.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionDeleteCampaign = UIAlertAction(title: "Delete Campaign", style: .default)
        {
            UIAlertAction in

            self.deleteCampaignAlert(sender.tag)
            
        }
        actionDeleteCampaign.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionCreateTemplate)
        alert.addAction(actionImportTemplates)
        alert.addAction(actionSetaSelfReminder)
        alert.addAction(actionEditCampaign)
        alert.addAction(actionDeleteCampaign)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension TeamCampaignsVC {
    func createTemplate (index:Int) {
        
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAddTemplateForTC") as! AddTemplateForTC
        vc.campaignId = self.arrCampaignId[index]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func importTemplate(index:Int) {
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idImportTemplateVC") as! ImportTemplateVC
        vc.campaignId = self.arrCampaignId[index]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func setSelfReminder(index:Int) {
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
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
            selector: #selector(self.UpdateTeamCampaignVC),
            name: NSNotification.Name(rawValue: "UpdateTeamCampaignVC"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "TeamCampaigns", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditTeamCampaignVC") as! EditTeamCampaignVC
        vc.campaignId = self.arrCampaignId[index]
        vc.campaignData = self.arrCampaignData[index] as! [String : AnyObject]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteCampaignAlert (_ index:Int) {
        
        let alertController = UIAlertController(title: "", message: "Do you really want to delete '\(self.arrCampaignName[index])' campaign?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteCampaign(self.arrCampaignId[index])
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
    
    func deleteCampaign (_ campaignId:String) {
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "teamCampaignId": campaignId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTeamCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getTeamCampaignFromServer()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
}


