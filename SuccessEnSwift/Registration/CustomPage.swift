//
//  CustomPage.swift
//  SwiftyOnboardExample
//
//  Created by Jay on 3/27/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class CustomPage: SwiftyOnboardPage {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
//    @IBOutlet weak var buttonLogin: UIButton!
//    @IBOutlet weak var buttonSubscribe: UIButton!
  //  @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        
        
        
      //  self.mapView.isMyLocationEnabled = true
        self.mapView.settings.zoomGestures = true
        
        let strLat = Double("37.266949")
        let strLong = Double("-122.025146")

        var coordinates = CLLocationCoordinate2D(latitude:strLat!
            , longitude:strLong!)
        
        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 5);
        self.mapView.camera = camera
        self.mapView.animate(to: camera)
        
        let dictParam = ["platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        performRequest( requestURL: SITEURL+"getAllCftLocation", params: dictParamTemp as [String : AnyObject]){ json in
            let success:String = json?["IsSuccess"] as? String ?? ""
            if success == "true"{
                
                let result = json!["result"] as! [AnyObject]
                print("result:",result)
                self.mapView.clear()
                for obj in result {
                    let strLat = Double(obj["userLatitude"] as! String)
                    let strLong = Double(obj["userLongitude"] as! String)
                    let userStatus = "\(obj["userCftActiveStatus"] as? String ?? "2")"
                    
                    coordinates = CLLocationCoordinate2D(latitude:strLat!
                        , longitude:strLong!)
                    
                    let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 5);
                    self.mapView.camera = camera
                    self.mapView.animate(to: camera)
                    
                    let marker = GMSMarker()
                    marker.position = coordinates
                    if userStatus == "2" {
                        marker.icon = GMSMarker.markerImage(with: UIColor.red)
                    }else{
                        marker.icon = GMSMarker.markerImage(with: UIColor.green)
                    }
                    marker.title = "CFT"
                    marker.map = self.mapView
                }
                OBJCOM.hideLoader()

            }else{
                OBJCOM.hideLoader()
            }
        };
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomPage", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    func performRequest(requestURL: String, params: [String: AnyObject], comletion: @escaping (_ json: AnyObject?) -> Void) {
        
        Alamofire.request(requestURL, method: .post, parameters: params, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
            switch(response.result) {
            case .success(_):
                let  JSON : [String:Any]
                if let json = response.result.value{
                    JSON = json as! [String : Any]
                    comletion(JSON as AnyObject)
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "Error")
                
                comletion(nil)
                break
                
            }
        }
    }
    
    
}
