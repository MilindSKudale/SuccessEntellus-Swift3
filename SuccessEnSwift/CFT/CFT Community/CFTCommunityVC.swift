//
//  CFTCommunityVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import EAIntroView

enum Location {
    case startLocation
    case destinationLocation
}
var repeatCall = false

class CFTCommunityVC: SliderVC, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate, EAIntroDelegate {
    
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    
    var isSource = ""
    var isSearch = false
    var searchBy = ""
    @IBOutlet var btnSearchByCft : UIButton!
    @IBOutlet var btnSearchByLoc : UIButton!
    @IBOutlet var txtSearchByCft : UITextField!
   
    var sourceLatitude = CLLocationDegrees()
    var sourceLongitude = CLLocationDegrees()
    var destLatitude = CLLocationDegrees()
    var destLongitude = CLLocationDegrees()
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    var arrCftUserName = [String]()
    var arrCftUserId = [String]()
    var selectedCftUserForSearch = ""
    
    @IBOutlet var mapView : GMSMapView!
    @IBOutlet var txtSource : UITextField!
    @IBOutlet var txtDestination : UITextField!
    @IBOutlet var btnFindRoute : UIButton!
    @IBOutlet var viewRoute : UIView!
    @IBOutlet var viewSwitchStatus : UIView!
    @IBOutlet var searchView : UIView!
    @IBOutlet var viewRouteHeight : NSLayoutConstraint!
    @IBOutlet var searchViewHeight : NSLayoutConstraint!
    @IBOutlet var btnSearch : UIButton!
    
     @IBOutlet var switchStatus : UISwitch!
     @IBOutlet var lblStatus : UILabel!
    // @IBOutlet var switchLicence : UISwitch!
    
    var currentLat = ""
    var currentLong = ""
    var currentAddress = ""
    var currentCity = ""
    var currentState = ""
    var currentCountry = ""
    var currentZipCode = ""
    
    var oldCoodinate: CLLocationCoordinate2D!
    var newCoodinate: CLLocationCoordinate2D!
    var oldCFT: [String:AnyObject]!
    var newCFT: [String:AnyObject]!
    
    var isLoadView = "0"
    var zoomValue : Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "CFT Locator"
        self.isLoadView = "0"
        self.isSource = ""
        self.lblStatus.text = ""
        searchBy = ""
        isSearch = false
        self.searchViewHeight.constant = 0.0
        self.searchView.isHidden = true
        txtSearchByCft.layer.cornerRadius = txtSearchByCft.frame.size.height/2
        txtSearchByCft.layer.borderColor = APPGRAYCOLOR.cgColor
        txtSearchByCft.layer.borderWidth = 0.5
        txtSearchByCft.clipsToBounds = true
        txtSource.isUserInteractionEnabled = false

        self.viewRoute.layer.cornerRadius = 10.0
        self.viewRouteHeight.constant = 0.0
        self.viewRoute.clipsToBounds = true
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.mapView.layoutMargins = layoutMargins
        
        
        btnFindRoute.layer.cornerRadius = 5.0
        btnFindRoute.clipsToBounds = true
        btnSearch.layer.cornerRadius = 5.0
        btnSearch.clipsToBounds = true
        
        locationManager.requestAlwaysAuthorization()
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            setUpLoc()
        case .restricted:
           // setUpLoc()
            break
        case .denied:
            setUpLoc()
            break
        case .authorizedAlways:
            setUpLoc()
        case .authorizedWhenInUse:
            setUpLoc()
        }

        switchStatus.addTarget(self, action: #selector(statusSwitchValueChanged(_:)), for: .valueChanged)
        repeatCall = true
        self.executeRepeatedly()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callExecuteReapeate),
            name: NSNotification.Name(rawValue: "executeRepeatedly"),
            object: nil)
    }
    
    func createIntroductionView(){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "CftLoc1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "CftLoc2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "CftLoc3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "CftLoc4")
        let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "CftLoc5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!, ingropage2!,ingropage3!,ingropage4!, ingropage5!])
        introView?.delegate = self
        
        introView?.show(in: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
    }
    
    func setUpLoc(){
        self.zoomValue = 15.0
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.distanceFilter = 10
        locationManager.headingFilter = 1
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func callExecuteReapeate(notification: NSNotification){
        repeatCall = true
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCFTStatus()
            self.executeRepeatedly()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCFTStatus()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        DispatchQueue.main.async {
            if isFirstTimeCftLocator == true {
                self.createIntroductionView()
                isFirstTimeCftLocator = false
            }
        }
    }
    
   @objc func statusSwitchValueChanged(_ sender : UISwitch!){
        if sender.isOn {
            self.updateCFTStatus("1")
            self.lblStatus.text = "Available"
        } else {
          self.updateCFTStatus("2")
            self.lblStatus.text = "Not Available"
        }
    }

    @IBAction func actionFindRoute(_ sender : UIButton!){
    
        self.viewRoute.layoutIfNeeded()
        self.viewRouteHeight.constant = 200.0
        UIView.animate(withDuration: 0.3, animations: {
            self.viewRoute.layoutIfNeeded()
        })
        repeatCall = false
        
//        let layoutMargins = UIEdgeInsets(top: self.mapView.frame.height/2, left: 0, bottom: 0, right: 0)
//        self.mapView.layoutMargins = layoutMargins
        //self.mapView.camera.zoom = 20.0
    }
    
    public func executeRepeatedly() {
        if repeatCall == true {
            if OBJCOM.isConnectedToNetwork(){
                self.getCFTfromCurrentLocation("", "")
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1800.0) { [weak self] in
                self?.executeRepeatedly()
            }
        }else{
            return
        }
    }
    
    @IBAction func actionMoreOption(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionWeeklyArchive = UIAlertAction(title: "Privacy options", style: .default)
        {
            UIAlertAction in
            
            let storyboard = UIStoryboard(name: "CFTCommunity", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idCFTUserListVC") as! CFTUserListVC
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            repeatCall = false
            self.present(vc, animated: false, completion: nil)
        }
        actionWeeklyArchive.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionHelp = UIAlertAction(title: "Help", style: .default)
        {
            UIAlertAction in
            self.createIntroductionView()
            
        }
        actionHelp.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionWeeklyArchive)
        alert.addAction(actionHelp)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension CFTCommunityVC : GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: self.zoomValue);
    
        camera.accessibilityNavigationStyle = .automatic
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        self.mapView.animate(to: camera)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            self.sourceLatitude = userLocation.coordinate.latitude
            self.sourceLongitude = userLocation.coordinate.longitude
            self.getCFTfromCurrentLocation("","")
           // self.oldCoodinate = coordinates
            if placemarks != nil {
                print(placemarks as Any)
                let placeMark = placemarks?.last
                self.currentAddress = placeMark!.subLocality ?? ""
                self.currentCity = placeMark!.locality ?? ""
                self.currentState = placeMark!.administrativeArea ?? ""
                self.currentCountry = placeMark!.country ?? ""
                self.currentZipCode = placeMark!.postalCode ?? ""
                self.currentLat = "\(userLocation.coordinate.latitude)"
                self.currentLong = "\(userLocation.coordinate.longitude)"
                self.txtSource.text = "\(self.currentAddress) \(self.currentCity) \(self.currentState) \(self.currentCountry) \(self.currentZipCode)"
                let dict = ["lat":self.currentLat,
                            "long":self.currentLong,
                            "address":self.currentAddress,
                            "city":self.currentCity,
                            "state":self.currentState,
                            "country":self.currentCountry,
                            "zipCode":self.currentZipCode]
                print(dict)
                self.sendCurrentLocationToServer(dict)
                self.isLoadView = "1"
            }
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.zoomValue = mapView.camera.zoom
        print("****** \(self.zoomValue) ******")

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        let marker = GMSMarker()
        let  heading:Double = newHeading.trueHeading;
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.rotation = heading
        marker.map = mapView;
        print(marker.rotation)
    }
   
    
     func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        

        if marker.userData != nil {
            
            if marker.icon != #imageLiteral(resourceName: "officelogo") {
                let infoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first! as! CustomInfoWindow
                let data = marker.userData as! [String:AnyObject]
                infoWindow.lblName.text = "\(data["first_name"] as? String ?? "") \(data["last_name"] as? String ?? "")"
                infoWindow.lblEmail.text = data["email"] as? String ?? ""
                infoWindow.lblPhone.text = data["phone"] as? String ?? ""
                
                let coordinates0 = CLLocationCoordinate2D(latitude:self.sourceLatitude
                    , longitude:self.sourceLongitude)
                
                let strLat = Double(data["userLatitude"] as! String)
                let strLong = Double(data["userLongitude"] as! String)
                let coordinates1 = CLLocationCoordinate2D(latitude:strLat!
                    , longitude:strLong!)
                
                let distance = calculateDistanceInMiles(coordinates0, coordinates1)
                infoWindow.lblDistance.text = distance
                infoWindow.lblTimeStamp.text = "Last updated : \(data["userLocationDate"] as? String ?? "Not determined")"
                
                infoWindow.imgProfile.layer.cornerRadius = infoWindow.imgProfile.frame.height/2
                infoWindow.imgProfile.clipsToBounds = true
                
                let docImg =  data["profile_pic"] as? String ?? ""
                if docImg != "" || docImg != "https://successentellus.com/assets/uploads/profile/" {
                    infoWindow.imgProfile.imageFromServerURL(urlString: docImg)
                }else{
                    infoWindow.imgProfile.image = #imageLiteral(resourceName: "profile")
                }
                return infoWindow
            }else{
                let infoWindow = Bundle.main.loadNibNamed("AddressInfoWindow", owner: self, options: nil)?.first! as! AddressInfoWindow
                let data = marker.userData as! [String:AnyObject]
                
                let officeName = data["cftOfficeName"] as? String ?? "Not available"
                let officeEmail = data["cftOfficeEmail"] as? String ?? "Not available"
                let officeAddress = "\(data["cftOfficeAddress"] as? String ?? ""), \(data["cftOfficeCity"] as? String ?? ""), \(data["cftOfficeState"] as? String ?? ""), \(data["cftOfficeCountry"] as? String ?? ""), \(data["cftOfficeZipcode"] as? String ?? "")"
                infoWindow.lblOfficeName.text = officeName
                infoWindow.lblAddress.text = officeAddress
                infoWindow.lblEmail.text = officeEmail
                
                let coordinates0 = CLLocationCoordinate2D(latitude:self.sourceLatitude
                    , longitude:self.sourceLongitude)
                
                let strLat = Double(data["cftOfficeLatitude"] as! String)
                let strLong = Double(data["cftOfficeLongitude"] as! String)
                let coordinates1 = CLLocationCoordinate2D(latitude:strLat!
                    , longitude:strLong!)
                
                let distance = calculateDistanceInMiles(coordinates0, coordinates1)
                infoWindow.lblDistance.text = "Distance \(distance)"
                
                return infoWindow
            }
        }else{ return nil }
    }
}

extension CFTCommunityVC {
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
        if self.isSource == "" {
            if place.name != "" {
                self.txtSearchByCft.text = place.name
            }
        }else if self.isSource == "SOURCE" {
            self.txtSource.text = place.name
            self.sourceLatitude = place.coordinate.latitude
            self.sourceLongitude = place.coordinate.longitude
        }else if self.isSource == "DESTINATION" {
            self.txtDestination.text = place.name
            self.destLatitude = place.coordinate.latitude
            self.destLongitude = place.coordinate.longitude
        }
        self.dismiss(animated: true, completion: nil) // dismiss after select place
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        self.isSource = ""

            self.view.layoutIfNeeded()
            self.searchViewHeight.constant = 110.0
            searchBy = "cft"
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.searchView.isHidden = false
                self.btnSearchByCft.isSelected = true
                self.btnSearchByLoc.isSelected = false
                //self.txtSearchByCft.isHidden = false
            })
            isSearch = true
            repeatCall = false

    }
}

extension CFTCommunityVC {
    func getCFTStatus(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftActiveStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let result = JsonDict!["result"] as! String
                print("result:",result)
                if result == "1"{
                    self.switchStatus.isOn = true
                    self.lblStatus.text = "Available"
                }else{
                    self.switchStatus.isOn = false
                    self.lblStatus.text = "Not Available"
                }
                cftDisplayFlagAll = JsonDict!["cftDisplayFlagAll"] as? String ?? "0"
                OBJCOM.hideLoader()
            } else {
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateCFTStatus(_ status:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftActiveStatus":status]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCftStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
    
    func getCFTfromLocationSearch(_ loc : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "searchlocation":loc,
                         "cftActive":"yes",
                         "cftLicense":"yes"]
        
       
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "findCftFromLocations", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
//            let success:String = JsonDict!["IsSuccess"] as! String
//            if success == "true" {
                if let result = JsonDict!["result"] as? [AnyObject] {
                    for obj in result {
                        let strLat = Double(obj["userLatitude"] as! String)
                        let strLong = Double(obj["userLongitude"] as! String)
                        let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "2")"
                        
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        
//                        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 18);
                        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: self.zoomValue);
                        self.mapView.camera = camera
                        self.mapView.animate(to: camera)
                    
                        let marker = GMSMarker()
                        marker.position = coordinates
                        if userStatus == "1" {
                            marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        }else{
                            marker.icon = GMSMarker.markerImage(with: UIColor.red)
                        }
                        marker.map = self.mapView
                        marker.userData = obj
                
                        self.oldCoodinate = self.newCoodinate
                    }
                }
                if let cftOffices = JsonDict!["cftOffices"] as? [AnyObject] {
                    for office in cftOffices {
                        let strLat = Double(office["cftOfficeLatitude"] as! String)
                        let strLong = Double(office["cftOfficeLongitude"] as! String)
                        
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        
                        let marker = GMSMarker()
                        marker.icon = #imageLiteral(resourceName: "officelogo")
                        marker.position = coordinates
                        marker.map = self.mapView
                        marker.userData = office
                    }
                }
            
                OBJCOM.hideLoader()
//            } else {
//                OBJCOM.hideLoader()
//            }
        };
    }
    
    func sendCurrentLocationToServer(_ dict:[String:String]) {
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "userLatitude":dict["lat"],
                         "userLongitude":dict["long"],
                         "userAddress":dict["address"],
                         "userCity":dict["city"],
                         "userState":dict["state"],
                         "userCountry":dict["country"],
                         "userZipcode":dict["zipCode"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addCurrentLocationUser", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCFTfromCurrentLocation(_ lat : String, _ long : String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "userLatitude":lat,
                         "userLongitude":long]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftLocationsFromUserLoc", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            self.arrCftUserName = []
            self.arrCftUserId = []
//            let success:String = JsonDict!["IsSuccess"] as! String
//            if success == "true" {
                if let result = JsonDict!["result"] as? [AnyObject] {
                    print("result:",result)
//                    self.mapView.clear()
                    for obj in result {
                        let strLat = Double(obj["userLatitude"] as! String)
                        let strLong = Double(obj["userLongitude"] as! String)
                        let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "1")"
                        
                        let cftName = "\(obj["first_name"] as? String ?? "") \(obj["last_name"] as? String ?? "")"
                        self.arrCftUserName.append(cftName)
                        self.arrCftUserId.append("\(obj["zo_user_id"] as? String ?? "")")
                        
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        
                        
                        let marker = GMSMarker()
                        self.newCoodinate = coordinates
                        if userStatus == "1" {
                            marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        }else{
                            marker.icon = GMSMarker.markerImage(with: UIColor.red)
                        }
                        marker.map = self.mapView
                        marker.userData = obj
                        marker.position =  self.newCoodinate
                        self.oldCoodinate = self.newCoodinate
                    }
                }
                if let cftOffices = JsonDict!["cftOffices"] as? [AnyObject] {
                    for office in cftOffices {
                        let strLat = Double(office["cftOfficeLatitude"] as? String ?? "")
                        let strLong = Double(office["cftOfficeLongitude"] as? String ?? "")
                        
                        let marker = GMSMarker()
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        marker.icon = #imageLiteral(resourceName: "officelogo")
                        marker.position = coordinates
                        marker.map = self.mapView
                        marker.userData = office
                    }
                }
                OBJCOM.hideLoader()
//            } else {
//                OBJCOM.hideLoader()
//            }
        };
    }
}

extension CFTCommunityVC {
    
    func openStartLocation() {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        locationSelected = .startLocation
        self.isSource = "SOURCE"
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    func openDestinationLocation() {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.isSource = "DESTINATION"
        locationSelected = .destinationLocation
        self.locationManager.stopUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
}

extension CFTCommunityVC : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtSource {
            self.openStartLocation()
            return false
        }else if textField == self.txtDestination {
            self.openDestinationLocation()
            return false
        }else if textField == self.txtSearchByCft {
            self.selectedCftUserForSearch = ""
            if searchBy == "location" {
                
                //textField.resignFirstResponder()
                let autoCompleteController = GMSAutocompleteViewController()
                autoCompleteController.delegate = self
                self.isSource = ""
                self.locationManager.stopUpdatingLocation()
                locationSelected = .destinationLocation
                self.present(autoCompleteController, animated: true, completion: nil)
                return false
            }else if searchBy == "cft" || searchBy == "" {
                if searchBy == "cft" {
                    
                    let dropDownTop = VPAutoComplete()
                    dropDownTop.dataSource = self.arrCftUserName
                    dropDownTop.onTextField = self.txtSearchByCft
                    dropDownTop.onView = self.view
                    dropDownTop.show { (str, index) in
                        print("string : \(str) and Index : \(index)")
                        self.txtSearchByCft.text = str
                        self.selectedCftUserForSearch = self.arrCftUserId[index]
                        self.txtSearchByCft.resignFirstResponder()
                    }
                }
                
                return true
            }
        }
        return true
    }

    @IBAction func actionCloseRouteView(_ sender: UIButton) {
        self.mapView.clear()
        self.isSource = ""
        repeatCall = true
        locationManager.requestWhenInUseAuthorization();
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
        }
        else{
            OBJCOM.setAlert(_title: "", message: "Location service disabled")
        }
        
        self.viewRoute.layoutIfNeeded()
        self.viewRouteHeight.constant = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewRoute.layoutIfNeeded()
        })
        
        self.executeRepeatedly()

    }
    
    @IBAction func actionFindDirection(_ sender: UIButton) {

        repeatCall = false
//        let src = self.txtSource.text?.replacingOccurrences(of: " ", with: "%20")
//        let dest = self.txtDestination.text?.replacingOccurrences(of: " ", with: "%20")
//        self.drawPath(origin: src!, destination: dest!)
        // if GoogleMap installed
        if let url = URL(string: "comgooglemaps://?saddr=\(self.sourceLatitude),\(self.sourceLongitude)&daddr=\(self.destLatitude),\(self.destLongitude)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        } else {
            // if GoogleMap App is not installed
            UIApplication.shared.open(URL(string:
                "https://www.google.co.in/maps/dir/?saddr=\(self.sourceLatitude),\(self.sourceLongitude)&daddr=\(self.destLatitude),\(self.destLongitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
        }
      
    }
    
    
    func drawPath (origin: String, destination: String) {
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=true&mode=driving"
      
        Alamofire.request(url).responseJSON{(responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let resData = swiftyJsonVar["routes"].arrayObject {
                    let routes = resData as! [[String: AnyObject]]
                    self.mapView.clear()
                    let start = CLLocationCoordinate2D(latitude: self.sourceLatitude, longitude: self.sourceLongitude)
                    
                    let marker = GMSMarker()
                    marker.position = start
                    marker.icon = #imageLiteral(resourceName: "my_location")
                    marker.map = self.mapView
                   
                    let camera = GMSCameraPosition.camera(withLatitude: self.sourceLatitude, longitude: self.sourceLongitude, zoom: self.zoomValue);
                    self.mapView.camera = camera
                    self.mapView.animate(to: camera)
                    
                    let end = CLLocationCoordinate2D(latitude: self.destLatitude, longitude: self.destLongitude)
                    
                    let marker1 = GMSMarker()
                    marker1.position = end
                    marker1.icon = #imageLiteral(resourceName: "destination")
                    marker1.map = self.mapView
                    
                    if routes.count > 0 {
                        
                        for rts in routes {
                            let overViewPolyLine = rts["overview_polyline"]?["points"]
                            let path = GMSMutablePath(fromEncodedPath: overViewPolyLine as! String)
                            
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 2
                            polyline.map = self.mapView
                        }
                    }
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.getCFTfromLocationSearch(origin)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
            }
        }
    }
    
    func getLatLong(_ address:String)-> CLLocation {
        let geoCoder = CLGeocoder()
        var location = CLLocation()
        geoCoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            location = (placemark?.location)!
            
        }
         return location        
    }
}

extension CLLocationCoordinate2D {
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}

extension CFTCommunityVC {
    @IBAction func actionCloseSearchView(_ sender: UIButton) {
       // VPAutoComplete().tableView?.removeFromSuperview()
        
        self.selectedCftUserForSearch = ""
        self.txtSearchByCft.text = ""
        
        isSearch = false
        searchBy = ""
        self.view.layoutIfNeeded()
        self.searchViewHeight.constant = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.searchView.isHidden = true
            self.view.layoutIfNeeded()
        })
        
        repeatCall = true
        self.executeRepeatedly()
        
        if OBJCOM.isConnectedToNetwork(){
            self.getCFTfromCurrentLocation("", "")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionSearchByCFTUser(_ sender: UIButton) {
        
        self.selectedCftUserForSearch = ""
        self.txtSearchByCft.text = ""
        
        self.view.layoutIfNeeded()
        self.searchViewHeight.constant = 110.0
        searchBy = "cft"
        UIView.animate(withDuration: 0.3, animations: {
            self.btnSearchByCft.isSelected = true
            self.btnSearchByLoc.isSelected = false
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSearchByLocation(_ sender: UIButton) {
        
        self.selectedCftUserForSearch = ""
        self.txtSearchByCft.text = ""
    
        VPAutoComplete().isShowView(is_show: false)
        self.view.layoutIfNeeded()
        self.searchViewHeight.constant = 110.0
        searchBy = "location"
        self.txtSearchByCft.text = ""
        self.txtSearchByCft.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.btnSearchByCft.isSelected = false
            self.btnSearchByLoc.isSelected = true
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSearch(_ sender: UIButton) {
        self.mapView.clear()
        VPAutoComplete().isShowView(is_show: false)
        
            if searchBy == "location" {
                if self.txtSearchByCft.text != "" {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(self.txtSearchByCft.text!) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                            else {
                                return
                            }
                    
                        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: self.zoomValue);
                        self.mapView.camera = camera
                        self.mapView.animate(to: camera)
                    }
                    if OBJCOM.isConnectedToNetwork(){
                        self.getCFTfromLocationSearch (self.txtSearchByCft.text!)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Please select location to search.")
                }
            }else if searchBy == "cft" {
                if self.txtSearchByCft.text != "" {
                    if self.selectedCftUserForSearch == "" {
                        OBJCOM.setAlert(_title: "", message: "Please select CFT user from list.")
                        self.txtSearchByCft.text = ""
                        self.selectedCftUserForSearch = ""
                        return
                    }else if self.selectedCftUserForSearch == "" {
                        OBJCOM.setAlert(_title: "", message: "No CFT user available with this name.")
                        self.txtSearchByCft.text = ""
                        self.selectedCftUserForSearch = ""
                        return
                    }
                    if OBJCOM.isConnectedToNetwork(){
                        self.getCFTUserLocationSearch(self.selectedCftUserForSearch)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                
                }else{
                    OBJCOM.setAlert(_title: "", message: "Please select CFT user from list.")
                }
            }
    }
    
    func getCFTUserLocationSearch(_ cftUserId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "searchUserId":cftUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftUserLocationOnSearch", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                if let result = JsonDict!["result"] as? [AnyObject] {
                    for obj in result {
                        let strLat = Double(obj["userLatitude"] as! String)
                        let strLong = Double(obj["userLongitude"] as! String)
                        let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "2")"
                        
                        let coordinates = CLLocationCoordinate2D(latitude:strLat!
                            , longitude:strLong!)
                        
                        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: self.zoomValue);
                        self.mapView.camera = camera
                      //  self.mapView.animate(to: camera)
                        
                        let marker = GMSMarker()
                        marker.position = coordinates
                        if userStatus == "1" {
                            marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        }else{
                            marker.icon = GMSMarker.markerImage(with: UIColor.red)
                        }
                        marker.map = self.mapView
                        marker.userData = obj
                       
                
                        // Keep Rotation Short
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(0.3)
                        marker.rotation = 0
                        CATransaction.commit()
                        
                        // Movement
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(0.1)
                        marker.position = coordinates
                        
                        // Center Map View
                        let camera1 = GMSCameraUpdate.setTarget(coordinates)
                        self.mapView.animate(with: camera1)
                        
                        CATransaction.commit()
                    }
                }
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
        };
    }
    
    func calculateDistanceInMiles(_ start:CLLocationCoordinate2D, _ dest:CLLocationCoordinate2D) -> String{
        
        let coordinate₀ = CLLocation(latitude:start.latitude, longitude:start.longitude)
        let coordinate₁ = CLLocation(latitude: dest.latitude, longitude:dest.longitude)
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        let distanceInMiles = distanceInMeters/1609.344
        let finalDist = String(format: "%.2f", distanceInMiles)

        return    "\(finalDist) miles"
    }
    
//    func updateMarker(coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double) {
//        // Keep Rotation Short
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.3)
//        marker.rotation = degrees
//        CATransaction.commit()
//
//        // Movement
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(duration)
//        marker.position = coordinates
//
//        // Center Map View
//        let camera = GMSCameraUpdate.setTarget(coordinates)
//        mapView.animate(with: camera)
//
//        CATransaction.commit()
//    }
    
//    @IBAction func shareLocationAction(_ sender: Any)
//    {
//        let msg = "geo:\(self.sourceLatitude),\(self.sourceLongitude)"
//        //let urlWhats = "whatsapp://send?text=\(msg)"
//        let urlWhats = "whatsapp://app"
//        
//        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
//            if let whatsappURL = NSURL(string: urlString) {
//                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
//                    UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
//                } else {
//                    print("please install whatsapp")
//                }
//            }
//        }
//    }
}
