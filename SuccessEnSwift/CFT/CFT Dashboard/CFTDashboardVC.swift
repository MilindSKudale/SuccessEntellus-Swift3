//
//  CFTDashboardVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 21/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var selectedCFTUser = ""

class CFTDashboardVC: SliderVC, ACTabScrollViewDelegate, ACTabScrollViewDataSource {

    @IBOutlet var btnSelectUser : UIButton!
    var lblReqCount : UILabel!
    var lblMsgCount : UILabel!
    @IBOutlet var noUserImage : UIImageView!
    @IBOutlet weak var tabScrollView: ACTabScrollView!
    var contentViews : [UIView] = []
    var arrUser : [String] = []
    var arrUserId : [String] = []
    var titleArray : [String] = ["Weekly Score Card", "Calender", "Weekly graph"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.noUserImage.isHidden = false
        self.btnSelectUser.setTitle("Select user", for: .normal)
        self.designUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getUserData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
        let moreBtn: UIButton = UIButton(type: UIButtonType.custom)
        moreBtn.setImage(#imageLiteral(resourceName: "moreBtn"), for: [])
        moreBtn.addTarget(self, action: #selector(actionMoreOption(_:)), for: UIControlEvents.touchUpInside)
        moreBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 30)
        let moreButton = UIBarButtonItem(customView: moreBtn)
        
        let accessBtn: UIButton = UIButton(type: UIButtonType.custom)
        accessBtn.setImage(#imageLiteral(resourceName: "cft_setting"), for: [])
        accessBtn.addTarget(self, action: #selector(actionAproveAccess(_:)), for: UIControlEvents.touchUpInside)
        accessBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 25)
        self.lblReqCount = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 15))
        self.lblReqCount.text = ""
        self.lblReqCount.layer.cornerRadius = self.lblReqCount.frame.height/2
        self.lblReqCount.clipsToBounds = true
        self.lblReqCount.backgroundColor = .red
        self.lblReqCount.font = UIFont.systemFont(ofSize: 13)
        self.lblReqCount.textColor = .white
        self.lblReqCount.textAlignment = .center
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessBtn.frame = buttonView.frame
        buttonView.addSubview(accessBtn)
        buttonView.addSubview(lblReqCount)
        self.lblReqCount.isHidden = true
        let barButton = UIBarButtonItem.init(customView: buttonView)

        let chatBtn: UIButton = UIButton(type: UIButtonType.custom)
        chatBtn.setImage(#imageLiteral(resourceName: "cft_feedback"), for: [])
        chatBtn.addTarget(self, action: #selector(actionFeedback(_:)), for: UIControlEvents.touchUpInside)
        chatBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.lblMsgCount = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 15))
        self.lblMsgCount.text = ""
        self.lblMsgCount.layer.cornerRadius = self.lblReqCount.frame.height/2
        self.lblMsgCount.clipsToBounds = true
        self.lblMsgCount.backgroundColor = .red
        self.lblMsgCount.font = UIFont.systemFont(ofSize: 13)
        self.lblMsgCount.textColor = .white
        self.lblMsgCount.textAlignment = .center
        
        let buttonView1 = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessBtn.frame = buttonView1.frame
        buttonView1.addSubview(chatBtn)
        buttonView1.addSubview(lblMsgCount)
        self.lblMsgCount.isHidden = true
        let barchatBtn = UIBarButtonItem.init(customView: buttonView1)
        
        self.navigationItem.rightBarButtonItems = [moreButton, barButton, barchatBtn]
        
        btnSelectUser.layer.cornerRadius = 5.0
        btnSelectUser.layer.borderWidth = 0.5
        btnSelectUser.layer.borderColor = APPGRAYCOLOR.cgColor
        btnSelectUser.clipsToBounds = true
        
        self.reloadTabScrollView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadCFTDashboard),
            name: NSNotification.Name(rawValue: "ReloadCFTDashboard"),
            object: nil)
    }
    
    @objc func reloadCFTDashboard(notification: NSNotification){
        DispatchQueue.main.async {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getUserData()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }

    @IBAction func actionSelectUser(_ sender:UIButton) {
        
        if self.arrUser.count > 0 {
            let alert = UIAlertController(title: "Select User", message: nil, preferredStyle: .actionSheet)
            for i in self.arrUser {
                alert.addAction(UIAlertAction(title: i, style: .default, handler: setUser))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            self.present(alert, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "No approved users available yet.")
        }
    }
    
    func setUser(action: UIAlertAction) {
        self.btnSelectUser.setTitle(action.title, for: .normal)
        for i in 0..<self.arrUser.count {
            if action.title == self.arrUser[i] {
                selectedCFTUser = self.arrUserId[i]
                if selectedCFTUser != "" {
                    user = "cft"
                }
            }
        }
        if self.btnSelectUser.titleLabel?.text != "Select user" {
            self.noUserImage.isHidden = true
            self.reloadTabScrollView()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetCFTData"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadView"), object: nil)
        }
    }
    
    @IBAction func actionMoreOption(_ sender:UIButton) {
        self.setMoreOptions()
    }
    
    @IBAction func actionAproveAccess(_ sender:UIButton) {
        if let vc = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idApproveAccessSettingVC") as? ApproveAccessSettingVC {
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func actionFeedback(_ sender:UIButton) {
        if let viewController = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idCFTFeedbackDashboard") as? CFTFeedbackDashboard {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension CFTDashboardVC {
    
    func reloadTabScrollView(){
        tabScrollView.defaultPage = 3
        tabScrollView.arrowIndicator = true
        tabScrollView.tabSectionHeight = 35
        tabScrollView.tabSectionBackgroundColor = APPGRAYCOLOR
        tabScrollView.contentSectionBackgroundColor = APPGRAYCOLOR
        tabScrollView.tabGradient = true
        tabScrollView.pagingEnabled = true
        tabScrollView.cachedPageLimit = 3
        tabScrollView.defaultPage = 0
        tabScrollView.delegate = self
        tabScrollView.dataSource = self
        
        let storyboard = UIStoryboard(name: "CFT", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "idCFTCurrentWeekSummery")
        let vc2 = storyboard.instantiateViewController(withIdentifier: "idCFTCalender")
        let storyboard1 = UIStoryboard(name: "WeeklyTracking", bundle: nil)
        let vc3 = storyboard1.instantiateViewController(withIdentifier: "idWeeklyGraphVC") as! WeeklyGraphVC
        
        user = "cft"
        addChildViewController(vc1)
        addChildViewController(vc2)
        addChildViewController(vc3)
        contentViews.append(vc1.view)
        contentViews.append(vc2.view)
        contentViews.append(vc3.view)
    }
    
    // MARK: ACTabScrollViewDelegate
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        print(index)
        user = "cft"
        if index == 1 {
            NotificationCenter.default.post(name: Notification.Name("ReloadView"), object: nil)
        } else if index == 2 {
            NotificationCenter.default.post(name: Notification.Name("ReloadView"), object: nil)
        }else{

            NotificationCenter.default.post(name: Notification.Name("ReloadView"), object: nil)
        }
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
        user = "cft"
    }
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return contentViews.count
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        // create a label
        let label = UILabel()
        label.text = titleArray[index]
        if #available(iOS 8.2, *) {
            label.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 18)
        }
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.sizeToFit()
        label.frame.size = CGSize(width: label.frame.size.width + 30, height: label.frame.size.height + 8)
        
        return label
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        return contentViews[index]
    }
}

extension CFTDashboardVC {
    func setMoreOptions(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionGiveAccess = UIAlertAction(title: "Give Access", style: .default)
        {
            UIAlertAction in
            if let vc = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idAccessSettingVC") as? AccessSettingVC {
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }
        }
        actionGiveAccess.setValue(APPGRAYCOLOR, forKey: "titleTextColor")
        
        let actionTopScore = UIAlertAction(title: "Top Score Recruits", style: .default)
        {
            UIAlertAction in
            if let vc = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idTop10RecruitListVC") as? Top10RecruitListVC {
                vc.modalPresentationStyle = .custom
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.present(vc, animated: false, completion: nil)
            }
        }
        actionTopScore.setValue(APPGRAYCOLOR, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionGiveAccess)
        alert.addAction(actionTopScore)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getUserData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftAccessUsers", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrUser = []
            self.arrUserId = []

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrUserData = JsonDict!["accessUser"] as! [AnyObject]
                let srtAccessCount = "\(JsonDict!["accessCount"]!)"
                let srtMsgCount = "\(JsonDict!["messageCount"]!)"
                for i in 0..<arrUserData.count {
                    self.arrUser.append(arrUserData[i]["userName"] as? String ?? "")
                    self.arrUserId.append(arrUserData[i]["cftAccessFromUserId"] as? String ?? "")
                }
                
                if srtAccessCount != "" && srtAccessCount != "0" {
                    self.lblReqCount.isHidden = false
                    self.lblReqCount.text = srtAccessCount
                }else{
                    self.lblReqCount.isHidden = true
                    self.lblReqCount.text = srtAccessCount
                }
                
                if srtMsgCount != "" && srtMsgCount != "0" {
                    self.lblMsgCount.isHidden = false
                    self.lblMsgCount.text = srtMsgCount
                }else{
                    self.lblMsgCount.isHidden = true
                    self.lblMsgCount.text = srtMsgCount
                }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
}
