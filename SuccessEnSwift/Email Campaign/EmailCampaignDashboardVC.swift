//
//  EmailCampaignDashboardVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Parchment
import EAIntroView

class EmailCampaignDashboardVC: SliderVC, EAIntroDelegate {

    fileprivate let vcTitles = [
        //"Company Campaigns",
        "Custom Campaigns"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.title = "Email Campaigns"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadChecklist),
            name: NSNotification.Name(rawValue: "AddEmail"),
            object: nil)
        
  
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
   //     let CompanyCampaign = storyboard.instantiateViewController(withIdentifier: "idCompanyCampaignVC")
   //     CompanyCampaign.title = "Company Campaigns"
        
        let CustomCampaign = storyboard.instantiateViewController(withIdentifier: "idCustomCampaignVC")
        CustomCampaign.title = "Custom Campaigns"
    
        let pagingViewController = FixedPagingViewController(viewControllers: [
           // CompanyCampaign,
            CustomCampaign
            ])
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParentViewController: self)
        
        DispatchQueue.main.async {
            if isFirstTimeEmailCampaign == true {
                let pages = ["CreateCamp1", "CreateCamp2", "CreateCamp3"]
                self.createIntroductionViewForEachModule(pages)
                isFirstTimeEmailCampaign = false
            }
        }
    }
    
    @objc func reloadChecklist(notification: NSNotification){
        DispatchQueue.main.async {
            self.viewDidLoad()
        }
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
    
    @IBAction func actionMenu(_ sender: AnyObject) {
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
        let actionCreateCamp = UIAlertAction(title: "How to create Email Campaign?", style: .default)
        {
            UIAlertAction in
            let pages = ["CreateCamp1", "CreateCamp2", "CreateCamp3"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionCreateCamp.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionAddTemplate = UIAlertAction(title: "How to add Email Template?", style: .default)
        {
            UIAlertAction in
            let pages = ["Temp1", "Temp2", "Temp3", "Temp4", "Temp5", "Temp6"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionAddTemplate.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionAddEmail = UIAlertAction(title: "How to add email into email campaign?", style: .default)
        {
            UIAlertAction in
            let pages = ["AddEmail1", "AddEmail2", "AddEmail3", "AddEmail4"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionAddEmail.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionImportCamp = UIAlertAction(title: "How to import email campaign?", style: .default)
        {
            UIAlertAction in
            let pages = ["ImportTemp1", "ImportTemp2"]
            self.createIntroductionViewForEachModule(pages)
            
        }
        actionImportCamp.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionSetReminder = UIAlertAction(title: "How to set a self reminder?", style: .default)
        {
            UIAlertAction in
            let pages = ["Reminder1", "Reminder2"]
            self.createIntroductionViewForEachModule(pages)
        }
        actionSetReminder.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionCreateCamp)
        alert.addAction(actionAddTemplate)
        alert.addAction(actionAddEmail)
        alert.addAction(actionImportCamp)
        alert.addAction(actionSetReminder)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}
