//
//  DrawerView.swift
//  NavigationDrawer
//
//  Created by Sowrirajan Sugumaran on 05/10/17.
//  Copyright © 2017 Sowrirajan Sugumaran. All rights reserved.
//

import UIKit

// Delegate protocolo for parsing viewcontroller to push the selected viewcontroller
var selectedCellIndex = 4
protocol DrawerControllerDelegate: class {
    func pushTo(viewController : UIViewController)
}

class DrawerView: UIView, drawerProtocolNew, UITableViewDelegate, UITableViewDataSource {
    
    public let screenSize = UIScreen.main.bounds
    var backgroundView = UIView()
    var drawerView = UIView()
    
    var tblVw = UITableView()
    var aryViewControllers = NSArray()
    weak var delegate:DrawerControllerDelegate?
    var currentViewController = UIViewController()
    var cellTextColor:UIColor?
    var userNameTextColor:UIColor?
    var btnLogOut = UIButton()
    var vwForHeader = UIView()
    var lblunderLine = UILabel()
    var imgBg : UIImage?
    var fontNew : UIFont?
    var moduleIds = [String]()
    var moduleNames = [String]()
  
    
    
    var userInfo = [String : Any]()
    var drawerIcon = [#imageLiteral(resourceName: "top_10_2x"), #imageLiteral(resourceName: "ic_scratchpad"), #imageLiteral(resourceName: "ic_calendar"), #imageLiteral(resourceName: "time-analysis"), #imageLiteral(resourceName: "dashboard"), #imageLiteral(resourceName: "daily-checklist"), #imageLiteral(resourceName: "weekly-tracking"), #imageLiteral(resourceName: "weekly-graph"), #imageLiteral(resourceName: "add-edit-goals"), #imageLiteral(resourceName: "CFT-dashboard"), #imageLiteral(resourceName: "CFT_Community"), #imageLiteral(resourceName: "Email-campaign"), #imageLiteral(resourceName: "ic_textCamp"), #imageLiteral(resourceName: "upload-Doc"), #imageLiteral(resourceName: "my-group"), #imageLiteral(resourceName: "my-prospects"), #imageLiteral(resourceName: "My-Contacts"), #imageLiteral(resourceName: "my-customers"), #imageLiteral(resourceName: "My-Recruits"), #imageLiteral(resourceName: "change-profile"), #imageLiteral(resourceName: "help-center")]
    // #imageLiteral(resourceName: "ic_teamCampaign"),

    fileprivate var imgProPic = UIImageView()
    fileprivate let imgBG = UIImageView()
    fileprivate var lblUserName = UILabel()
    fileprivate var lblUserStatus = UILabel()
    fileprivate var imgUserStatus = UIImageView()
    fileprivate var switchAvailable = UISwitch()
    fileprivate var gradientLayer: CAGradientLayer!
    
    var PopupDelegate: PopupProtocol?

    convenience init(aryControllers: NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
        }
        
        self.tblVw.register(UINib.init(nibName: "DrawerCell", bundle: nil), forCellReuseIdentifier: "DrawerCell")
        self.initialise(controllers: aryControllers, isBlurEffect: isBlurEffect, isHeaderInTop: isHeaderInTop, controller:controller)
        moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
        moduleNames = UserDefaults.standard.value(forKey: "PACKAGESNAME") as? [String] ?? []
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // To change the profile picture of account
    func changeProfilePic(img:UIImage) {
        imgProPic.image = img
        imgBG.image = img
        imgBg = img
    }
    
    // To change the user name of account
    func changeUserName(name:String) {
        lblUserName.text = name
    }
    
    // To change the background color of background view
    func changeGradientColor(colorTop:UIColor, colorBottom:UIColor) {
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // To change the tableview cell text color
    func changeCellTextColor(txtColor:UIColor) {
        self.cellTextColor = txtColor
        btnLogOut.setTitleColor(txtColor, for: .normal)
        lblunderLine.backgroundColor = txtColor.withAlphaComponent(0.6)
        self.tblVw.reloadData()
    }
    
    // To change the user name label text color
    func changeUserNameTextColor(txtColor:UIColor) {
        lblUserName.textColor = txtColor
    }
    
    // To change the font for table view cell label text
    func changeFont(font:UIFont) {
        fontNew = font
        self.tblVw.reloadData()
    }

    func initialise(controllers:NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        currentViewController = controller
        currentViewController.tabBarController?.tabBar.isHidden = true
        
        backgroundView.frame = frame
        drawerView.backgroundColor = UIColor.clear
        backgroundView.backgroundColor = APPGRAYCOLOR
        backgroundView.alpha = 0.3

        // Initialize the tap gesture to hide the drawer.
        let tap = UITapGestureRecognizer(target: self, action: #selector(DrawerView.actDissmiss))
        backgroundView.addGestureRecognizer(tap)
        addSubview(backgroundView)
        
        drawerView.frame = CGRect(x:0, y:0, width:screenSize.width/2+75, height:screenSize.height)
        drawerView.clipsToBounds = true

        // Initialize the gradient color for background view
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = drawerView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.darkGray.cgColor]

        imgBG.frame = drawerView.frame
        drawerView.backgroundColor = APPGRAYCOLOR
        imgBG.image = nil//imgBg ?? #imageLiteral(resourceName: "splash")
        
        // Initialize the blur effect upon the image view for background view
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = drawerView.bounds
        imgBG.addSubview(blurView)
        
        // Check wether need the blur effect or not
        if isBlurEffect == true {
            self.drawerView.addSubview(imgBG)
        }else{
            self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // This is for adjusting the header frame to set header either top (isHeaderInTop:true) or bottom (isHeaderInTop:false)
        self.allocateLayout(controllers:controllers, isHeaderInTop: isHeaderInTop)
    }
    
    func allocateLayout(controllers:NSArray, isHeaderInTop:Bool) {
        
        if isHeaderInTop {
            vwForHeader = UIView(frame:CGRect(x:0, y:10, width:drawerView.frame.size.width, height:100))
            self.lblunderLine = UILabel(frame:CGRect(x:vwForHeader.frame.origin.x+10, y:vwForHeader.frame.size.height - 1 , width:vwForHeader.frame.size.width-20, height:1.0))
            tblVw.frame = CGRect(x:0, y:vwForHeader.frame.origin.y+vwForHeader.frame.size.height, width:screenSize.width/2+75, height:screenSize.height-120)

        }else{
            tblVw.frame = CGRect(x:0, y:20, width:screenSize.width/2+75, height:screenSize.height-110)
            vwForHeader = UIView(frame:CGRect(x:0, y:tblVw.frame.origin.y+tblVw.frame.size.height, width:drawerView.frame.size.width, height:screenSize.height - tblVw.frame.size.height))
            lblunderLine.frame = CGRect(x:10, y:0, width:vwForHeader.frame.size.width-20, height:1)
        }
        
        tblVw.separatorStyle = UITableViewCellSeparatorStyle.none
        aryViewControllers = controllers
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = UIColor.clear
        tblVw.allowsSelection = true
        tblVw.allowsMultipleSelection = false
        drawerView.addSubview(tblVw)
        tblVw.reloadData()

        lblunderLine.backgroundColor = UIColor.groupTableViewBackground
        vwForHeader.addSubview(lblunderLine)
        
        btnLogOut = UIButton(frame:CGRect(x:10, y:5, width:vwForHeader.frame.size.width-20, height:50))
        btnLogOut.setTitle("Logout", for: .normal)
        btnLogOut.contentHorizontalAlignment = .left
        btnLogOut.contentVerticalAlignment = .top
        btnLogOut.addTarget(self, action: #selector(actLogOut), for: .touchUpInside)
        btnLogOut.titleLabel?.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 18)
        btnLogOut.setTitleColor(UIColor.white, for: .normal)
        btnLogOut.backgroundColor = .clear
        vwForHeader.addSubview(btnLogOut)
        var profile_pic = ""
        
        imgProPic = UIImageView(frame:CGRect(x:vwForHeader.frame.size.width-70, y:btnLogOut.frame.origin.y+5, width:60, height:60))
        imgProPic.layer.cornerRadius = imgProPic.frame.size.height/2
        imgProPic.layer.masksToBounds = true
        imgProPic.contentMode = .scaleAspectFill
        
        if self.userInfo != nil {
            profile_pic = userInfo["profile_pic"] as? String ?? ""
            if profile_pic != "" {
                imgProPic.imageFromServerURL(urlString: profile_pic)
            }else{
                imgProPic.image = #imageLiteral(resourceName: "profile")
            }
        }else{
            imgProPic.image = #imageLiteral(resourceName: "profile")
        }
        vwForHeader.addSubview(imgProPic)
        
        var userName = "User name"
        if self.userInfo != nil {
            let first_name = userInfo["first_name"] ?? ""
            let last_name = userInfo["last_name"] ?? ""
            userName = "\(first_name) \(last_name)"
        }
        lblUserName = UILabel(frame:CGRect(x:btnLogOut.frame.origin.x, y:btnLogOut.frame.origin.y+25, width:btnLogOut.frame.size.width, height:25))
        lblUserName.text = userName
        lblUserName.font = UIFont(name: "Euphemia UCAS", size: 15)
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor.lightText
        vwForHeader.addSubview(lblUserName)
        
//        imgUserStatus = UIImageView(frame:CGRect(x:lblUserName.frame.origin.x, y:lblUserName.frame.origin.y+25, width:15, height:15))
//        imgUserStatus.layer.cornerRadius = imgUserStatus.frame.size.height/2
//        imgUserStatus.layer.masksToBounds = true
//        imgUserStatus.contentMode = .center
//        imgUserStatus.image = #imageLiteral(resourceName: "green_avail")
//        vwForHeader.addSubview(imgUserStatus)

        lblUserStatus = UILabel(frame:CGRect(x:lblUserName.frame.origin.x, y:lblUserName.frame.origin.y+35, width:lblUserName.frame.size.width, height:15))
        lblUserStatus.text = versionNumber
        lblUserStatus.font = UIFont(name: "Euphemia UCAS", size: 12)
        lblUserStatus.textAlignment = .left
        lblUserStatus.textColor = UIColor.lightText
        vwForHeader.addSubview(lblUserStatus)
        
//        switchAvailable = UISwitch(frame:CGRect(x:100, y:lblUserName.frame.origin.y+25, width:50, height:20))
//
//        vwForHeader.addSubview(switchAvailable)
        
        drawerView.addSubview(vwForHeader)
        addSubview(drawerView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryViewControllers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerCell") as! DrawerCell
        
        if selectedCellIndex == indexPath.row {
            cell.backgroundColor = UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0)
        }else{
           cell.backgroundColor = UIColor.clear
        }
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 19 || indexPath.row == 20 {
            cell.pkgAvailable.image = nil
        }else{
            if moduleNames.contains(aryViewControllers[indexPath.row] as! String){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
            
        }
        
        cell.lblController?.text = aryViewControllers[indexPath.row] as? String
        cell.imgController?.image = drawerIcon[indexPath.row]
        cell.lblController.textColor = self.cellTextColor ?? UIColor.white
        cell.lblController.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 16)
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actDissmiss()
        
        selectedCellIndex = indexPath.row
        switch indexPath.row {
        case 0:
            repeatCall = false
            let storyBoard = UIStoryboard(name:"DailyTopTen", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDailyTopTenVC"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 1:
            repeatCall = false
            let storyBoard = UIStoryboard(name:"Scrachpad", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idScrachPadDashboardVC"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 2:
            repeatCall = false
            if !moduleIds.contains("5") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Calender", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCalenderVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
            
        case 3:
            repeatCall = false
            if !moduleIds.contains("6") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"TimeAnalysis", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTimeAnalysisVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 4:
            repeatCall = false
            
            if !moduleIds.contains("17") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDashboardVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 5:
            repeatCall = false
            if !moduleIds.contains("1") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDailyChecklistView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 6:
            repeatCall = false
            if !moduleIds.contains("4") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"WeeklyTracking", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyTracking"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)}
            break
        case 7:
            user = ""
            repeatCall = false
            if !moduleIds.contains("3") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"WeeklyTracking", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyGraphVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        
        case 8:
            repeatCall = false
            if !moduleIds.contains("2") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idAddEditGoalsVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 9:
            user = "cft"
            repeatCall = false
            if !moduleIds.contains("8") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CFT", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTDashboard"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 10:
            user = ""
            repeatCall = true
            if !moduleIds.contains("21") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CFTCommunity", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTCommunityVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 11:
            repeatCall = false
            if !moduleIds.contains("9") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"EmailCampaign", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idEmailCampaignDashboardVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
//        case 12:
//            repeatCall = false
//            if !moduleIds.contains("9") {
//                goTOSubscription()
//            }else{
//                let storyBoard = UIStoryboard(name:"TeamCampaigns", bundle:nil)
//                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTeamCampaignsVC"))
//                controllerName.hidesBottomBarWhenPushed = true
//                self.delegate?.pushTo(viewController: controllerName)
//            }
//
//            break
        case 12:
            repeatCall = false
            if !moduleIds.contains("10") {
                goTOSubscription()
            } else {
                let storyBoard = UIStoryboard(name:"TextCampaign", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTextCampaignVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 13:
            repeatCall = false
            if !moduleIds.contains("15") {
                goTOSubscription()
            } else {
                let storyBoard = UIStoryboard(name:"Document", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDocumentVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 14:
            repeatCall = false
            if !moduleIds.contains("7") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyGroupVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 15:
            repeatCall = false
            if !moduleIds.contains("13") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyProspectVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 16:
            repeatCall = false
            if !moduleIds.contains("11") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyContactVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 17:
            repeatCall = false
            if !moduleIds.contains("12") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyCustomerVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 18:
            repeatCall = false
            if !moduleIds.contains("16") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyRecruitVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 19:
            repeatCall = false
            let storyBoard = UIStoryboard(name:"Profile", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idChangeProfileVC"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 20:
            repeatCall = false
            let storyBoard = UIStoryboard(name:"CMS", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCMSDashboard"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        
        default:
            repeatCall = false
            break
        }
        
    }

    // To dissmiss the current view controller tab bar along with navigation drawer
    @objc func actDissmiss() {
        currentViewController.tabBarController?.tabBar.isHidden = false
        self.dissmiss()
    }
    
    @objc func goTOSubscription() {
        let storyBoard = UIStoryboard(name:"Packages", bundle:nil)
        let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idPackagesFilterVC"))
        controllerName.hidesBottomBarWhenPushed = true
      //  controllerName.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.delegate?.pushTo(viewController: controllerName)
    }
    
    // Action for logout to quit the application.
    @objc func actLogOut() {
       // exit(0)
        repeatCall = false
        isFirstTimeChecklist = true
        isFirstTimeEmailCampaign = true
        isFirstTimeCftLocator = true
        isFirstTimeTextCampaign = true
        
        OBJLOC.StopUpdateLocation()
        UserDefaults.standard.removeObject(forKey: "USERINFO")
        UserDefaults.standard.removeObject(forKey: "ALL_CONTACTS")
        UserDefaults.standard.removeObject(forKey: "BUSY_START_DATE")
        UserDefaults.standard.removeObject(forKey: "PACKAGES")
        UserDefaults.standard.removeObject(forKey: "PACKAGESNAME")
        UserDefaults.standard.synchronize()
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "idCFTMapLaunchVC")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
}
