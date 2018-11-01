//
//  PopEditRequestVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PopEditRequestVC: UIViewController {
    
    var arrSelectedModule = [String]()
    var accessData = [String:AnyObject]()

    //Send request view
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var btnCalender : UIButton!
    @IBOutlet var btnWSC : UIButton!
    @IBOutlet var btnSendRequest : UIButton!
    @IBOutlet var btnClose : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.accessData)
        loadViewDesign()
    }

    func loadViewDesign(){
        
        lblName.text = self.accessData["userNameReq"] as? String ?? ""
        lblDate.text = self.accessData["cftAccessDate"] as? String ?? ""
        let pic = self.accessData["imgPath"] as? String ?? ""
        if pic != "" {
            imgView.imageFromServerURL(urlString: pic)
        }else{
            imgView.image = #imageLiteral(resourceName: "noImg")
        }

        arrSelectedModule = self.accessData["accessModule"] as! [String]

        for _ in 0 ..< arrSelectedModule.count {
            if arrSelectedModule.contains("1"){
                btnWSC.isSelected = true
            }else{
                btnWSC.isSelected = false
            }

            if arrSelectedModule.contains("2"){
                btnCalender.isSelected = true
            }else{
                btnCalender.isSelected = false
            }
        }
        btnSendRequest.layer.cornerRadius = 5.0
        btnSendRequest.clipsToBounds = true
        btnClose.layer.cornerRadius = 5.0
        btnClose.clipsToBounds = true

        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.layer.borderWidth = 3
        imgView.layer.borderColor = UIColor.white.cgColor
        imgView.clipsToBounds = true
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSetCalender(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("2") {
                let index = arrSelectedModule.index(of: "2")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("2") == false {
                arrSelectedModule.append("2")
            }
        }
    }
    
    @IBAction func actionSetWSC(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
            if arrSelectedModule.contains("1") {
                let index = arrSelectedModule.index(of: "1")
                arrSelectedModule.remove(at: index!)
            }
        }else{
            sender.isSelected = true
            if arrSelectedModule.contains("1") == false {
                arrSelectedModule.append("1")
            }
        }
    }
    
    @IBAction func actionSendRequest(_ sender:UIButton){
        
        let strModule = self.arrSelectedModule.joined(separator: ",")
        print(strModule)
        if validate() == true {

            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.apiCallForSendAccessRequest(strModule)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    func apiCallForSendAccessRequest(_ module : String){

        let accessId = self.accessData["accessId"] as? String ?? ""
        if accessId == "" {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId": accessId,
                         "moduleName":module]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "changeAccess", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUI"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }

    func validate() -> Bool {

        if self.arrSelectedModule.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one access module to send request.")
            return false
        }

        return true
    }

}
