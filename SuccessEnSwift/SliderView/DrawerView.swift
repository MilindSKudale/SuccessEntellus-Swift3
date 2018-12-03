//
//  DrawerView.swift
//  NavigationDrawer
//
//  Created by Sowrirajan Sugumaran on 05/10/17.
//  Copyright © 2017 Sowrirajan Sugumaran. All rights reserved.
//

import UIKit

// Delegate protocolo for parsing viewcontroller to push the selected viewcontroller
var selectedCellIndex = 1
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
    var data = [[String:Any]]()
    
//    #imageLiteral(resourceName: "ic_visionBoard")
    var userInfo = [String : Any]()
    var drawerIcon = [#imageLiteral(resourceName: "ic_myTools"), #imageLiteral(resourceName: "dashboard"), #imageLiteral(resourceName: "daily-checklist"), #imageLiteral(resourceName: "weekly-tracking"), #imageLiteral(resourceName: "weekly-graph"), #imageLiteral(resourceName: "add-edit-goals"), #imageLiteral(resourceName: "CFT-dashboard"), #imageLiteral(resourceName: "CFT_Community"), #imageLiteral(resourceName: "icd_myCampaigns"), #imageLiteral(resourceName: "icd_crm"), #imageLiteral(resourceName: "change-profile"), #imageLiteral(resourceName: "help-center")]
    // #imageLiteral(resourceName: "ic_teamCampaign"),

    fileprivate var imgProPic = UIImageView()
    fileprivate let imgBG = UIImageView()
    fileprivate var lblUserName = UILabel()
    fileprivate var lblUserStatus = UILabel()
    fileprivate var imgUserStatus = UIImageView()
    fileprivate var switchAvailable = UISwitch()
    fileprivate var gradientLayer: CAGradientLayer!
    var isCollapseCrm = true
    var isCollapseCampaign = true
    var isCollapseTools = true
    
    var PopupDelegate: PopupProtocol?

    convenience init(aryControllers: NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
        }
        
        if selectedCellIndex == 9 {
            isCollapseCrm = false
            isCollapseCampaign = true
            isCollapseTools = true
        }else if selectedCellIndex == 8 {
            isCollapseCampaign = false
            isCollapseCrm = true
            isCollapseTools = true
        }else if selectedCellIndex == 0 {
            isCollapseTools = false
            isCollapseCampaign = true
            isCollapseCrm = true
        }else{
            isCollapseCampaign = true
            isCollapseCrm = true
            isCollapseTools = true
        }
//["sectionHeader": "Vision Board","isCollapsed":true,"items":[], "icons":[]],
        data = [["sectionHeader": "My Tools","isCollapsed":true,"items":["Daily Top 10", "Vision Board", "Scratch Pad", "Calendar", "Time Analysis"], "icons":[#imageLiteral(resourceName: "top_10_2x"), #imageLiteral(resourceName: "ic_visionBoard"), #imageLiteral(resourceName: "ic_scratchpad"), #imageLiteral(resourceName: "ic_calendar"), #imageLiteral(resourceName: "time-analysis")]],
//            ["sectionHeader": "Calendar","isCollapsed":true,"items":[], "icons":[]],
//            ["sectionHeader": "Time Analysis","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Dashboard","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Daily Checklist","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Weekly Tracking","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Weekly Graph","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Add/Edit Goals","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "CFT Dashboard","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "CFT Locator","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "My Campaigns","isCollapsed":isCollapseCampaign,"items":["Email Campaigns", "Text Campaigns", "Upload Documents"], "icons":[ #imageLiteral(resourceName: "Email-campaign"), #imageLiteral(resourceName: "ic_textCamp"), #imageLiteral(resourceName: "upload-Doc")]],
            
            ["sectionHeader": "My CRM", "isCollapsed":isCollapseCrm,"items":["My Groups","My Prospects", "My Contacts", "My Customers", "My Recruits"], "icons":[ #imageLiteral(resourceName: "my-group"), #imageLiteral(resourceName: "my-prospects"), #imageLiteral(resourceName: "My-Contacts"), #imageLiteral(resourceName: "my-customers"), #imageLiteral(resourceName: "My-Recruits")]],
            ["sectionHeader": "My Profile","isCollapsed":true,"items":[], "icons":[]],
            ["sectionHeader": "Help","isCollapsed":true,"items":[], "icons":[]]]
        
        self.tblVw.register(UINib.init(nibName: "DrawerCell", bundle: nil), forCellReuseIdentifier: "DrawerCell")
        self.tblVw.register(UINib.init(nibName: "DrawerSubmenuCell", bundle: nil), forCellReuseIdentifier: "DrawerSubmenuCell")
        self.initialise(controllers: aryViewControllers, isBlurEffect: isBlurEffect, isHeaderInTop: isHeaderInTop, controller:controller)
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
        
        lblUserStatus = UILabel(frame:CGRect(x:lblUserName.frame.origin.x, y:lblUserName.frame.origin.y+35, width:lblUserName.frame.size.width, height:15))
        lblUserStatus.text = versionNumber
        lblUserStatus.font = UIFont(name: "Euphemia UCAS", size: 12)
        lblUserStatus.textAlignment = .left
        lblUserStatus.textColor = UIColor.lightText
        vwForHeader.addSubview(lblUserStatus)
    
        drawerView.addSubview(vwForHeader)
        addSubview(drawerView)
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

extension DrawerView {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "DrawerCell") as! DrawerCell
        
        if selectedCellIndex == section {
            cell.backgroundColor = UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0)
        }else{
            cell.backgroundColor = UIColor.clear
        }
        
        cell.lblController.text = data[section]["sectionHeader"] as? String
        cell.imgController.image = drawerIcon[section]
        cell.btnSelectCell.tag = section
        cell.btnSelectCell.addTarget(self, action: #selector(self.sectionButtonTapped(_:)), for: .touchUpInside)
        //cell.backgroundColor = .black
        
        //section == 1 || section == 2 ||
        if section == 0 || section == 10 || section == 11 {
            cell.pkgAvailable.image = nil
        }else{
            if moduleNames.contains(data[section]["sectionHeader"] as! String){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if section == 8 {
                if moduleIds.contains("9") || moduleIds.contains("10"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else{
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
                }
            }else if section == 9 {
                if moduleIds.contains("7"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else if moduleIds.contains("11"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else if moduleIds.contains("12"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else if moduleIds.contains("13"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }else if moduleIds.contains("16"){
                    cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
                }
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }

        
        if section == 8 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "right-arrowd"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "up-arrowd"), for: .normal)
            }
        }else if section == 9 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "right-arrowd"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "up-arrowd"), for: .normal)
            }
        }else if section == 0 {
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "right-arrowd"), for: .normal)
            } else {
                cell.btnSelectCell.setImage(#imageLiteral(resourceName: "up-arrowd"), for: .normal)
            }
        }else{
            cell.btnSelectCell.setImage(nil, for: .normal)
        }

        cell.lblController.textColor = self.cellTextColor ?? UIColor.white
        cell.lblController.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 16)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCollapsed = data[section]["isCollapsed"] as! Bool
        let item = data[section]["items"] as! [String]
        return isCollapsed ? 0 : item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "DrawerSubmenuCell", for: indexPath) as! DrawerSubmenuCell
        let item = data[indexPath.section]["items"] as! [String]
        let icon = data[indexPath.section]["icons"] as! [UIImage]
        
        cell.backgroundColor = UIColor.clear
        
        cell.lblController.text = item[indexPath.row]
        cell.imgController.image = icon[indexPath.row]
        cell.btnSelectSubCell.tag = indexPath.row
        cell.btnSelectSubCell.addTarget(self, action: #selector(cellButtonTapped(_:)), for: .touchUpInside)
        
        cell.lblController.textColor = self.cellTextColor ?? UIColor.white
        cell.lblController.font = fontNew ?? UIFont(name: "Euphemia UCAS", size: 15)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = APPGRAYCOLOR
        
        if indexPath.section == 0 {
            cell.pkgAvailable.image = nil
        }else if indexPath.section == 8 {
            if moduleIds.contains("9") {
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("10") {
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("15"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }else if indexPath.section == 9 {
            if moduleIds.contains("7"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("11"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("12"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("13,"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else if moduleIds.contains("16"){
                cell.pkgAvailable.image = #imageLiteral(resourceName: "green_avail")
            }else{
                cell.pkgAvailable.image = #imageLiteral(resourceName: "red_avail")
            }
        }
        return cell
    }
    
    @objc func sectionButtonTapped(_ button: UIButton) {
        let section = button.tag
    
        switch section {
        case 0:
            repeatCall = false
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
            } else {
                data[section]["isCollapsed"] = true
            }
            self.tblVw.reloadData()
            break
        case 1:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("17") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDashboardVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 2:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("1") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDailyChecklistView"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 3:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("4") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"WeeklyTracking", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyTracking"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)}
            break
        case 4:
            user = ""
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("3") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"WeeklyTracking", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idWeeklyGraphVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
            
        case 5:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("2") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idAddEditGoalsVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 6:
            user = "cft"
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("8") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CFT", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTDashboard"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 7:
            user = ""
            repeatCall = true
            actDissmiss()
            selectedCellIndex = section
            if !moduleIds.contains("21") {
                goTOSubscription()
            }else{
                let storyBoard = UIStoryboard(name:"CFTCommunity", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCFTCommunityVC")) //idNewCftLocVC
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
            }
            break
        case 8:
            repeatCall = false
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
            }
            else {
                data[section]["isCollapsed"] = true
            }
            self.tblVw.reloadData()
            break
       
        case 9:
            repeatCall = false
            selectedCellIndex = section
            let isCollapsed = data[section]["isCollapsed"] as! Bool
            if isCollapsed {
                data[section]["isCollapsed"] = false
            }
            else {
                data[section]["isCollapsed"] = true
            }
            self.tblVw.reloadData()
            break
        case 10:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
            let storyBoard = UIStoryboard(name:"Profile", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idChangeProfileVC"))
            controllerName.hidesBottomBarWhenPushed = true
            self.delegate?.pushTo(viewController: controllerName)
            break
        case 11:
            repeatCall = false
            actDissmiss()
            selectedCellIndex = section
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
    
    @objc func cellButtonTapped(_ button: UIButton) {
        let index = button.tag
        if selectedCellIndex == 8 {
            switch index {
            case 0:
                repeatCall = false
                actDissmiss()
                
                if !moduleIds.contains("9") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"EmailCampaign", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idEmailCampaignDashboardVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }

                break
            case 1:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("10") {
                    goTOSubscription()
                } else {
                    let storyBoard = UIStoryboard(name:"TextCampaign", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTextCampaignVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            case 2:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("15") {
                    goTOSubscription()
                } else {
                    let storyBoard = UIStoryboard(name:"Document", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDocumentVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            
            default:
                repeatCall = false
                break
            }
        }else if selectedCellIndex == 9 {
            switch index {
            case 0:
                repeatCall = false
                actDissmiss()
                
                if !moduleIds.contains("7") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyGroupVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            case 1:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("13") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyProspectVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            case 2:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("11") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyContactVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            case 3:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("12") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyCustomerVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            case 4:
                repeatCall = false
                actDissmiss()
                if !moduleIds.contains("16") {
                    goTOSubscription()
                }else{
                    let storyBoard = UIStoryboard(name:"CRM", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idMyRecruitVC"))
                    controllerName.hidesBottomBarWhenPushed = true
                    self.delegate?.pushTo(viewController: controllerName)
                }
                break
            default:
                repeatCall = false
                break
            }
        }else if selectedCellIndex == 0 {
            switch index {
            case 0:
                repeatCall = false
                actDissmiss()
                let storyBoard = UIStoryboard(name:"DailyTopTen", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDailyTopTenVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
                break
            case 1:
                repeatCall = false
                actDissmiss()
                let storyBoard = UIStoryboard(name:"VisionBoard", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idDashboardVB"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
                break
            case 2:
                repeatCall = false
                actDissmiss()
                let storyBoard = UIStoryboard(name:"Scrachpad", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idScrachPadDashboardVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
                break
            case 3:
                repeatCall = false
                actDissmiss()
                let storyBoard = UIStoryboard(name:"Calender", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idCalenderVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
                break
            case 4:
                repeatCall = false
                actDissmiss()
                let storyBoard = UIStoryboard(name:"TimeAnalysis", bundle:nil)
                let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idTimeAnalysisVC"))
                controllerName.hidesBottomBarWhenPushed = true
                self.delegate?.pushTo(viewController: controllerName)
                break
            default:
                repeatCall = false
                break
            }
        }
        
    }
}
