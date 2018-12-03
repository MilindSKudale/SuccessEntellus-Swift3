//
//  NewCftLocVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 21/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import MapKit

class NewCftLocVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Search
    
    fileprivate var searchController: UISearchController!
    fileprivate var localSearchRequest: MKLocalSearch.Request!
    fileprivate var localSearch: MKLocalSearch!
    fileprivate var localSearchResponse: MKLocalSearch.Response!
    
    // MARK: - Map variables
    
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!
    fileprivate var isCurrentLocation: Bool = false
    fileprivate var isSetNavigation: Bool = false
    
    var arrCftUserName = [String]()
    var arrCftUserId = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentLocationButton = UIBarButtonItem(title: "+", style: UIBarButtonItem.Style.plain , target: self, action: #selector(currentLocationButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = currentLocationButton
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = searchButton
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true
        
        let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.mapView.layoutMargins = layoutMargins
        setCurrentLocation()
    }
    
    @objc func currentLocationButtonAction(_ sender: UIBarButtonItem) {
        if isSetNavigation == false {
            setCurrentLocation()
            let layoutMargins = UIEdgeInsets(top: self.mapView.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
            self.mapView.layoutMargins = layoutMargins
            isSetNavigation = true
        }else{
            setCurrentLocation()
            let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.mapView.layoutMargins = layoutMargins
            isSetNavigation = false
        }
        
    }
    
    func setCurrentLocation(){
        if (CLLocationManager.locationServicesEnabled()) {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            locationManager?.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            isCurrentLocation = true
        }
    }
    
    // MARK: - Search
    
    @objc func searchButtonAction(_ button: UIBarButtonItem) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                OBJCOM.setAlert(_title: "", message: "Place not found.")
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mapView.centerCoordinate = pointAnnotation.coordinate
            self!.mapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isCurrentLocation {
            return
        }
        
        isCurrentLocation = false
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = "CFT"
        mapView.addAnnotation(pointAnnotation)
        getCFTfromCurrentLocation("", "")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let pin = mapView.view(for: annotation) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.pinTintColor = UIColor.purple
            return pin
            
        } else {
//            let pin = mapView.view(for: annotation) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            pin.pinTintColor = UIColor.green
            return nil
            
        }
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
                    
                    
//                    let marker = GMSMarker()
//                    self.newCoodinate = coordinates
//                    if userStatus == "1" {
//                        marker.icon = GMSMarker.markerImage(with: UIColor.green)
//                    }else{
//                        marker.icon = GMSMarker.markerImage(with: UIColor.red)
//                    }
//                    marker.map = self.mapView
//                    marker.userData = obj
//                    marker.position =  self.newCoodinate
//                    self.oldCoodinate = self.newCoodinate
                    
//                    if self.mapView.annotations.count != 0 {
//                        self.annotation = self.mapView.annotations[0]
//                        self.mapView.removeAnnotation(self.annotation)
//                    }
                    
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = coordinates
                    pointAnnotation.title = ""
                    self.mapView.addAnnotation(pointAnnotation)
                }
            }
            if let cftOffices = JsonDict!["cftOffices"] as? [AnyObject] {
                for office in cftOffices {
                    let strLat = Double(office["cftOfficeLatitude"] as? String ?? "")
                    let strLong = Double(office["cftOfficeLongitude"] as? String ?? "")
                    
//                    let marker = GMSMarker()
                    let coordinates = CLLocationCoordinate2D(latitude:strLat!
                        , longitude:strLong!)
//                    marker.icon = #imageLiteral(resourceName: "officelogo")
//                    if self.mapView.annotations.count != 0 {
//                        self.annotation = self.mapView.annotations[0]
//                        self.mapView.removeAnnotation(self.annotation)
//                    }
                    
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = coordinates
                    pointAnnotation.title = ""
                    //pointAnnotation = #imageLiteral(resourceName: "officelogo")
                    self.mapView.addAnnotation(pointAnnotation)
                }
            }
            OBJCOM.hideLoader()
            //            } else {
            //                OBJCOM.hideLoader()
            //            }
        };
    }


}
