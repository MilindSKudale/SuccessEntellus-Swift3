//
//  DashboardVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 07/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Parchment
import Contacts
import EAIntroView


class DashboardVC: SliderVC, PopupProtocol, EAIntroDelegate {
    
//    var contacts: [CNContact]!
    
    var moduleId = "17"
   // let customAlertVC = CustomAlertViewController.instantiate()

    fileprivate let vcTitles = [
        "Daily Checklist",
        "Daily Score Graph",
        "Weekly Score Card"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let motiFlag = UserDefaults.standard.value(forKey: "MOTIVATIONAL") as? String ?? "true"
        if motiFlag == "false" {
            motivatinalData()
        }
        self.loadDashBoard()
    
//        let moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
//        if moduleIds.contains("17") || moduleIds.contains("1") {
//           
//            let storyboard = UIStoryboard(name: "Packages", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "idPackagesFilterVC") as! PackagesFilterVC
//            vc.modalPresentationStyle = .custom
//            vc.modalTransitionStyle = .coverVertical
//            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            self.present(vc, animated: true, completion: nil)
//        }
        
    }
    
    func dismiss() {
        self.dismissPopup(completion: nil)
    }
    
    func loadDashBoard(){
        // Load each of the view controllers you want to embed
        // from the storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DailyChecklistView = storyboard.instantiateViewController(withIdentifier: "idDailyChecklistView")
        DailyChecklistView.title = "Daily Checklist"
        let DailyScoreGraphView = storyboard.instantiateViewController(withIdentifier: "idDailyScoreGraphView")
        DailyScoreGraphView.title = "Daily Score Graph"
        let WeeklyScoreCardView = storyboard.instantiateViewController(withIdentifier: "idWeeklyScoreCardView")
        WeeklyScoreCardView.title = "Weekly Score Card"
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        let pagingViewController = FixedPagingViewController(viewControllers: [
            DailyChecklistView,
            DailyScoreGraphView,
            WeeklyScoreCardView
            ])
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParentViewController: self)
        
        DispatchQueue.main.async {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.fetchAllContacts()
                let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
                if userData.count > 0 {
                    let cft = userData["userCft"] as? String ?? "0"
                    if cft == "1" {
                        OBJLOC.StartupdateLocation()
                    }
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        DispatchQueue.main.async {
            if isFirstTimeChecklist == true {
                self.createIntroductionView()
                isFirstTimeChecklist = false
            }
        }
        let appdel = AppDelegate()
        appdel.registerForPushNotifications()
    }
    
    func motivatinalData(){
        
        let dictParam = ["user_id": userID]
        OBJCOM.modalAPICall(Action: "getMotivationalQuotes", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                if let vc = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "idMotivationalVC") as? MotivationalVC {
                    vc.dict = dictJsonData
                    vc.modalPresentationStyle = .custom
                    vc.modalTransitionStyle = .crossDissolve
                    vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                    self.present(vc, animated: false, completion: nil)
                }
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getContacts() -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
    
    func fetchAllContacts(){
        var arrContacts = [String]()
        for item in getContacts() {
            if item.isKeyAvailable(CNContactPhoneNumbersKey){
                let phoneNOs=item.phoneNumbers
                let _:String
                for item in phoneNOs{
                    arrContacts.append(item.value.stringValue)
                }
            }
        }
        UserDefaults.standard.set(arrContacts, forKey: "ALL_CONTACTS")
        UserDefaults.standard.synchronize()
    }
    
    func createIntroductionView(){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "page1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "page2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "page3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "page4")
        let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "page5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage2!,ingropage3!,ingropage4!, ingropage5!, ingropage1!])
        introView?.delegate = self
        
        introView?.show(in: self.view)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
            // your code with delay
            introView?.hide(withFadeOutDuration: 3.0)
        }
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
    }
    
    @IBAction func actionMenu(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionWeeklyArchive = UIAlertAction(title: "Help", style: .default)
        {
            UIAlertAction in
            self.createIntroductionView()
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
}
