//
//  CFTMapView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class CFTMapView: UIViewController {
    
    @IBOutlet var switchStatus : UISwitch!
    @IBOutlet var viewSwitchStatus : UIView!
    @IBOutlet var mapView : GMSMapView!
    
    //var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.isHidden = false
//        self.mapView.isMyLocationEnabled = true
//        self.mapView.settings.myLocationButton = true
//        self.mapView.settings.compassButton = true
//        self.mapView.settings.zoomGestures = true
        
        whichView = "CFTLocator"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.createSpotlight()
    }
    
    func createSpotlight(){
        
        let viewSwitchStatusPoint = self.viewSwitchStatus.getGlobalPoint(toView: self.view)
        
        
        let itemsToBeHighlighted : [WalkthroughItemType] = [
            (point: viewSwitchStatusPoint,
             height: self.viewSwitchStatus.frame.height,
             width: self.viewSwitchStatus.frame.width,
             title: "CFT Availability",
             description: "Turn ON/OFF your CFT locator availability on map.")]
        
        showWalkthroughView(currentViewController: self, itemsToBeHighlighted: itemsToBeHighlighted)
        
        
    }

}
