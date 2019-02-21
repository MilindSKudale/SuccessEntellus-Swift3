//
//  SliderVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 06/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class SliderVC: UIViewController, DrawerControllerDelegate {
    
    // 1.Decllare the drawer view
    var drawerVw = DrawerView()
    var userInfo = [String : Any]()
    var vwBG = UIView()
    var flag = true
    override func viewDidLoad() {
        super.viewDidLoad()
        flag = true
        self.navigationController?.navigationBar.isTranslucent = false
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
        }
    }
    
    @IBAction func actShowMenu(_ sender: Any) {
        
        //**** REQUIRED ****//
   
        let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
        if userData.count > 0 {
            let cft = userData["userCft"] as? String ?? "0"
            if cft == "1" {
                OBJLOC.StartupdateLocation()
            }
        }
        
        
        //**** 2.Implement the drawer view object and set delecate to current view controller
        drawerVw = DrawerView(aryControllers:DrawerArray.array, isBlurEffect:true, isHeaderInTop:false, controller:self)
        drawerVw.delegate = self
        // Set default goals
        setGoals()
        // Can change account holder name
        var userName = "User name"
        if self.userInfo.count > 0 {
            let first_name = userInfo["first_name"] ?? ""
            let last_name = userInfo["last_name"] ?? ""
            userName = "\(first_name) \(last_name)"
        }
        drawerVw.changeUserName(name: userName)
        // 3.show the Navigation drawer.
        drawerVw.show()
        
        
    }
    
    // 6.To push the viewcontroller which is selected by user.
    func pushTo(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func popupTo(popupVC: PopupViewController) {
        self.present(popupVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGoals(){
        if isOnboarding == false {
            isOnboarding = true
            isOnboard = "true"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dt = formatter.string(from: Date())
            UserDefaults.standard.set(dt, forKey: "BUSY_START_DATE")
            apiCallForSubmitGoals()
        }
    }
    
    func apiCallForSubmitGoals(){
        
        let dt = UserDefaults.standard.value(forKey: "BUSY_START_DATE") as? String ?? ""
        let dictParam = ["user_id": userID,
                         "start_date": dt,
                         "firstGoalDetails": strCSA,
                         "secondGoalDetails": strCA,
                         "thirdGoalDetails": strBLA]
        
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "setBuinessDateAndGoalsIos", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                isOnboarding = true
                OBJCOM.hideLoader()
            }else{
                isOnboarding = true
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                
                OBJCOM.hideLoader()
            }
        };
    }
}

// 7.Struct for add storyboards which you want show on navigation drawer
struct DrawerArray {
    static let array:NSArray = ["Daily Top 10", "Scratch Pad", "Calendar", "Time Analysis", "Dashboard", "Daily Checklist", "Weekly Tracking", "Weekly Graph", "Add/Edit Goals", "CFT Dashboard", "CFT Locator", "My Campaigns", "Profile", "Help", "Vision Board"]
    //"Team Campaigns", "My Groups", "My Prospects", "My Contacts", "My Customers", "My Recruits", "Email Campaigns", "Text Campaigns", "Upload Documents",
    
}

