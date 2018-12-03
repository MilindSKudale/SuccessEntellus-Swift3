//
//  AppDelegate.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Google
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import CoreLocation
import UserNotifications

let appDel = AppDelegate()
var isOnboarding = true
var isOnboard = "true"
var userID = ""
var deviceTokenId = ""

//com.successentellusplus.swift
//com.bundle.Successen

var demoClientID = "624666392300-t1qrfgkolo9dmefik04atodpmi2dqp68.apps.googleusercontent.com"
var liveClientID = "97989711624-378qr7e67khvt6bo5ab2j3aimbmj6ccp.apps.googleusercontent.com"

var liveGoogleAPIKey = "AIzaSyBH0nr8tMah_mYOc9CGqox1q_ZBYmci6hQ"
var demoGoogleAPIKey = "AIzaSyCqHXNGqgGM1NylycUFKam2D2iksxme9Yc"

var liveGooglePlacesAPIKey = "AIzaSyD1s5xIDXMBvh2JyLdrmPxQXM-t1RnkpIM"
var demoGooglePlacesAPIKey = "AIzaSyDIZJLrQjA0CZdnGBOH8xeXILZ-FG3FDaw"

var isFirstTimeChecklist : Bool!
var isFirstTimeEmailCampaign : Bool!
var isFirstTimeCftLocator : Bool!
var isFirstTimeTextCampaign : Bool!

//https://successentellus.com/home/privacyPolicy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var bgtimer = Timer()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var current_time = NSDate().timeIntervalSince1970
    var timer = Timer()
    var f = 0
    
    var isActive = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        IQKeyboardManager.sharedManager().enable = true
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.black

        GIDSignIn.sharedInstance().clientID = demoClientID
        GMSPlacesClient.provideAPIKey(demoGooglePlacesAPIKey)
        GMSServices.provideAPIKey(liveGoogleAPIKey)
        
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/contacts.readonly")
    
        customNavBar()
        setupSiren()
//        registerForPushNotifications()
        
        DispatchQueue.main.async {
            OBJCOM.getPackagesInfo()
            self.setRootVC()
        }
        
        if (UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]) != nil {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            
            if userData.count > 0 {
                let cft = userData["userCft"] as? String ?? "0"
                if cft == "1" {
                    OBJLOC.StartupdateLocation()
                }
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
       // if (UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]) != nil {
            OBJCOM.getPackagesInfo()
       // }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        if (UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]) != nil {
            OBJCOM.getPackagesInfo()
//        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .immediately)
//        if (UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]) != nil {
            OBJCOM.getPackagesInfo()
//        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .daily)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    public func getLocReapete() {
        if isActive == true {
            self.StartupdateLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.getLocReapete()
            }
        }else{
            return
        }
    }

    func setRootVC (){
    
        if UserDefaults.standard.value(forKey: "USERINFO") != nil && isOnboarding == true {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            userID = userData["zo_user_id"] as! String
            if isOnboard == "false"{
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "idProgramGoalsVC")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }else{
                let moduleIds = UserDefaults.standard.value(forKey: "PACKAGES") as? [String] ?? []
                if moduleIds.count > 0 && !moduleIds.contains("17") {
                    let storyBoard = UIStoryboard(name:"Packages", bundle:nil)
                    let controllerName = (storyBoard.instantiateViewController(withIdentifier: "idNavPack"))
                    self.window?.rootViewController = controllerName
                    self.window?.makeKeyAndVisible()
                }else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "idnav")
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            }
        }else if UserDefaults.standard.value(forKey: "USERINFO") != nil && isOnboarding == false {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            userID = userData["zo_user_id"] as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "idAddGoals")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }else{
          //  isCFTMap =  true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "idCFTMapLaunchVC") // idLoginVC
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func customNavBar(){
        let nav = UINavigationBar.appearance()
        nav.tintColor = APPORANGECOLOR
        nav.titleTextAttributes = [NSAttributedStringKey.foregroundColor: APPORANGECOLOR];
    UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func setupSiren() {
        let siren = Siren.shared
        // Optional
        siren.delegate = self
        // Optional
        siren.debugEnabled = true
        siren.alertType = .option // or .force, .skip, .none
        siren.majorUpdateAlertType = .option
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .option
        siren.revisionUpdateAlertType = .option
    }
}


extension AppDelegate: SirenDelegate
{
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
        print(#function, alertType)
    }
    
    func sirenUserDidCancel() {
        print(#function)
    }
    
    func sirenUserDidSkipVersion() {
        print(#function)
    }
    
    func sirenUserDidLaunchAppStore() {
        print(#function)
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        print(#function, error)
        
    }
    
    func sirenLatestVersionInstalled() {
        print(#function, "Latest version of app is installed")
    }
    
    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
        print(#function, "\(message).\nRelease type: \(updateType.rawValue.capitalized)")
    }
}

extension AppDelegate {
    
    func doBackgroundTask() {
        
        bgtimer.fire()
        
        DispatchQueue.main.async {
            self.beginBackgroundUpdateTask()
            self.bgtimer = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(AppDelegate.bgtimer(_:)), userInfo: nil, repeats: true)
            
            self.StartupdateLocation()
            
            RunLoop.current.add(self.bgtimer, forMode: RunLoopMode.defaultRunLoopMode)
            RunLoop.current.run()
            self.endBackgroundUpdateTask()
        }
    }
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
        self.bgtimer.invalidate()
    }
    
    func StartupdateLocation() {
        locationManager.requestAlwaysAuthorization()
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted:
            break
        case .denied:
            let alertController = UIAlertController(title: "\"SuccessEntellus\" would like to access your location.", message: "SuccessEntellus app needs access to your current location to connect you with CFTs near you. If you are a CFT, then your current location will be tracked. Please click Settings and select Always for best optimal experience and maximum sales leads.", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in }
                    )}
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        case .authorizedAlways:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startMonitoringSignificantLocationChanges()
//            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while requesting new coordinates")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.latitude = manager.location!.coordinate.latitude
        self.longitude = manager.location!.coordinate.longitude
        print("UPDATE LOCATION ---------")
        print(self.latitude)
        print(self.longitude)
        
        let dict = ["lat":"\(self.latitude)",
            "long":"\(self.longitude)",
            "address": "",
            "city": "",
            "state": "",
            "country": "",
            "zipCode": ""]
        print(dict)
        OBJCOM.sendCurrentLocationToServer(dict)
        locationManager.stopUpdatingLocation()
    }
    
    @objc func bgtimer(_ timer:Timer!){
        sleep(1)
        if UIApplication.shared.applicationState == .active {
            timer.invalidate()
        }else{
            self.updateLocation()
        }
        
    }
    
    func updateLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.stopUpdatingLocation()
    }
}
 
//Push notifications setting
extension AppDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.sync {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        deviceTokenId = token
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            let userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String : Any]
            userID = userInfo["zo_user_id"] as? String ?? ""
            OBJCOM.sendUDIDToServer(deviceTokenId)
        }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

