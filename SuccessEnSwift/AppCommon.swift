//
//  AppCommon.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SKActivityIndicatorView

let APPORANGECOLOR = UIColor(red:0.96, green:0.36, blue:0.14, alpha:1.0)
let APPGRAYCOLOR = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.0)
let SITEURL:String = "http://bringmax.com/successentellus/successapp/"
//let SITEURL:String = "https://successentellus.com/successapp/"
let SITEURLCHECK:String = "http://bringmax.com/successentellus/successapp/"
let versionNumber = "Version 2.5.7"
var OBJCOM = AppCommon()

class AppCommon: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    private var parameters:[String:AnyObject]?
    var _headers : HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]

    let alert: UIAlertView = UIAlertView()
    override func viewDidLoad() {
        super.viewDidLoad()
        _headers["Accept"] = "application/json, text/json, text/javascript, text/html"
    }
    
    func modalAPICall(Action: String,param : [String : AnyObject]?, vcObject:UIViewController, completionHandler: @escaping ([String:Any]?, Int?) -> ()){
        let BaselUrl = (SITEURL+"\(Action)")
        parameters = param
        print("BaselUrl : ", BaselUrl)
        print("parameters : ", parameters ?? "parameter missing")
        
        Alamofire.request(BaselUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: _headers).responseJSON(completionHandler:{ response in
        
            switch response.result {
            case .success(_):
                print(response.result.value as Any)
                let  JSON : [String:Any]
                if let json = response.result.value {
                    JSON = json as! [String : Any]
                    completionHandler(JSON , 1)
                }
            case .failure(let error):
                print(error)
               // self.setAlert(_title: "Error", message: error.localizedDescription)
                self.hideLoader()
            }
        })
    }
    
    func performRequest(_ method: HTTPMethod, requestURL: String, params: [String: AnyObject], comletion: @escaping (_ json: AnyObject?) -> Void) {
        
        Alamofire.request(requestURL, method: .get, parameters: params, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response)
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                
                    print("YOUR JSON DATA>>  \(response.data!)")
                    comletion(nil)
                    
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "")
                
                comletion(nil)
                break
            }
        }
    }
    
    func NoInternetConnectionCall() {
        OBJCOM.hideLoader()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topVC = self.topMostController()
        let vcToPresent = storyboard.instantiateViewController(withIdentifier: "idNoInternetVC") as! NoInternetVC
        topVC.present(vcToPresent, animated: false, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        if Reachability.connectedToNetwork() == true {
            return true
        } else {
            return false
        }
    }
    
    func showNetworkAlert(){
        
        self.hideLoader()
        self.setAlert(_title: "", message: "Make sure your device is connected to the internet.")

    }
    
    func setAlert(_title : String, message : String){
        
        let alert: UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK");
        
        alert.show();
    }
   
    func setLoader() {
        SKActivityIndicator.spinnerColor(APPORANGECOLOR)
        SKActivityIndicator.statusTextColor(APPGRAYCOLOR)
        SKActivityIndicator.statusLabelFont(UIFont.boldSystemFont (ofSize: 15.0))
        SKActivityIndicator.spinnerStyle(.spinningCircle)
        SKActivityIndicator.show("Please wait...", userInteractionStatus: false)
    }
    
    func hideLoader() {
        SKActivityIndicator.dismiss()
    }
    
    func validateEmail(uiObj:String)  -> Bool{
        var isValidEmail: Bool {
            do {
                let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}", options: .caseInsensitive)
                return regex.firstMatch(in: uiObj, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, uiObj.count)) != nil
            } catch {
                print("Mail not valid");
                return false;
            }
        }
        return isValidEmail;
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func animateButton(button:UIView) {
        
        button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.20,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                    button.transform = .identity
        }, completion: nil)
    }
    
    func setStepperValues(stepper:PKYStepper, min:Float, max:Float){
        stepper.value = min
        stepper.stepInterval = 1
        stepper.minimum = min
        stepper.maximum = max
        stepper.setLabelTextColor(APPGRAYCOLOR)
        stepper.setButtonTextColor(APPGRAYCOLOR, for: .normal)
        stepper.setBorderColor(APPGRAYCOLOR)
        stepper.setLabelTextColor(APPGRAYCOLOR)
        stepper.hidesDecrementWhenMinimum = true
        stepper.hidesIncrementWhenMaximum = true
        stepper.valueChangedCallback = { stepper, count in
            let value = Int(count)
            stepper?.countLabel.text = "\(value)"
        }
        stepper.setup()
    }
    
    func setTopCorner (viewToRound:UIView){
        viewToRound.clipsToBounds = true
        viewToRound.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            viewToRound.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setBottomCorner (viewToRound:UIView){
        viewToRound.clipsToBounds = true
        viewToRound.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            viewToRound.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK : Load image from server.
    func getDataFromUrl(url:NSURL, completion: @escaping ((_ data: NSData?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            completion(data as NSData?, response, error as NSError?)
            }.resume()
    }
    
    func loadImage(url: NSURL,imgObj:UIImageView){
        imgObj.alpha = 0.0
        
        getDataFromUrl(url: url) { (data, response, error)  in
            DispatchQueue.main.async{ () -> Void in
                
                guard let data = data , error == nil else {
                    print(error ?? "ERROR")
                    return
                }
                if let img = UIImage(data: data as Data){
                    imgObj.image = img
                }else{
                    imgObj.image = #imageLiteral(resourceName: "noImg")
                }
                
                UIView.animate(withDuration: 0.2, animations: { imgObj.alpha = 1.0 })
            }
        }
    }
    
    func popUp(context ctx: UIViewController, msg: String) {
        
        let toast = UILabel(frame:
            CGRect(x: 20, y: ctx.view.frame.size.height / 2,
                   width: ctx.view.frame.size.width - 40, height: 60))
        
        toast.backgroundColor = UIColor.black
        toast.textColor = UIColor.white
        toast.textAlignment = .center;
        toast.numberOfLines = 0
        toast.lineBreakMode = .byWordWrapping
        toast.font = UIFont.systemFont(ofSize: 15)
        toast.layer.cornerRadius = 10;
        toast.clipsToBounds  =  true
        toast.text = msg
        
        ctx.view.addSubview(toast)
        
        UIView.animate(withDuration: 2.0, delay: 1.5,
                       options: .curveEaseOut, animations: {
                        toast.alpha = 0.0
        }, completion: {(isCompleted) in
            toast.removeFromSuperview()
        })
    }
    
    func uploadImage (image:UIImage, userId:String, folderNameStr: String, param:String){
        
        let url = NSURL(string: SITEURL+"\(folderNameStr)/uploadImage")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (image == nil) { return }
        let image_data = UIImageJPEGRepresentation(image,0.6)
        if(image_data == nil) { return }
        
        let body = NSMutableData()
        let fname = ("business_\(userId).jpg")
        let mimetype = "image/jpg"
        
        //define the data post parameter
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"zo_user_id\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(userId)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"folder_name\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(folderNameStr)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(param)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString!)
            self.hideLoader()
        }
        task.resume()
    }
    
    func uploadImageProfile (image:UIImage, userId:String, folderNameStr: String, param:String){
        
        let url = NSURL(string: SITEURL+"uploadImage")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (image == nil) { return }
        let image_data = UIImageJPEGRepresentation(image,0.6)
        if(image_data == nil) { return }
        
        let body = NSMutableData()
        let fname = ("profile_\(userId).jpg")
        let mimetype = "image/jpg"
        
        //define the data post parameter
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"zo_user_id\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(userId)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"folder_name\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(folderNameStr)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(param)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request as URLRequest){ (data, response, error) in
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString!)
            if param == "profile_pic"{
                OBJCOM.setAlert(_title: "", message: "User profile updated successfully.")
            }
            self.hideLoader()
        }
        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
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
            print("API CALL ==================\n \(success) ")
            OBJCOM.hideLoader()
        };
    }
    
    func getAddressFromLatLon(latitude: String, longitude: String) -> String {
        var addressString : String = ""
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(latitude)")!
        //21.228124
        let lon: Double = Double("\(longitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "")
                    print(pm.locality ?? "")
                    print(pm.subLocality ?? "")
                    print(pm.thoroughfare ?? "")
                    print(pm.postalCode ?? "")
                    print(pm.subThoroughfare ?? "")
                    
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    
                    print(addressString)
                }
        })
        return addressString
    }
    
    func setRepeateWeeks(_ texField : UITextField){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 1 ..< 13 {
            let actionDay = UIAlertAction(title: "\(i)", style: .default)
            {
                UIAlertAction in
                texField.text = "\(i)"
            }
            actionDay.setValue(UIColor.black, forKey: "titleTextColor")
            alert.addAction(actionDay)
        }
        
        let actionCancel = UIAlertAction(title: "Dismiss", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(actionCancel)
        let topVC = self.topMostController()
        topVC.present(alert, animated: true, completion: nil)
    }
    
    
    func getPackagesInfo(){
        if UserDefaults.standard.value(forKey: "USERINFO") != nil {
            let userData = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
            if userData != nil {
                userID = userData["zo_user_id"] as! String
                let dictParam = ["userId": userID,
                                 "platform":"3"]
                
                let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                let dictParamTemp = ["param":jsonString];
                
                typealias JSONDictionary = [String:Any]
                OBJCOM.modalAPICall(Action: "customizeModuleList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                    JsonDict, staus in
                    
                    arrModuleList = []
                    arrModuleId = []
                    
                    let success:String = JsonDict!["IsSuccess"] as! String
                    if success == "true"{
                        let result = JsonDict!["result"] as! [AnyObject]
                        arrModuleList = result.compactMap { $0["moduleName"] as? String }
                        arrModuleId = result.compactMap { $0["moduleId"] as? String }
                        
                        UserDefaults.standard.set(arrModuleId, forKey: "PACKAGES")
                        UserDefaults.standard.set(arrModuleList, forKey: "PACKAGESNAME")
                        UserDefaults.standard.synchronize()
                        
                    }else{
                        OBJCOM.hideLoader()
                    }
                };
            }
        }
    }
}

extension UIView {
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}
