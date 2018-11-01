//
//  AccessSettingVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AccessSettingVC: UIViewController {
    
    //Send request view
    @IBOutlet var txtEmail : SkyFloatingLabelTextField!
    @IBOutlet var btnCalender : UIButton!
    @IBOutlet var btnWSC : UIButton!
    @IBOutlet var btnSendRequest : UIButton!
    
    //remove request view
    @IBOutlet var tblView : UITableView!
    @IBOutlet var noRecordVw : UIView!
    var data = [AnyObject]()
    var accessData = [[String:AnyObject]]()
    var arrAccessId = [String]()
    var arrModule = [AnyObject]()
    var arrImg = [String]()
    var arrName = [String]()
    var arrEmail = [String]()
    var arrAccessDate = [String]()
    var accessImage : [UIImage] = [#imageLiteral(resourceName: "ic_scorecard"), #imageLiteral(resourceName: "ic_calendar"), #imageLiteral(resourceName: "profile")]
    
    var arrSelectedModule = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noRecordVw.isHidden = true
        self.loadViewDesign()
        self.tblView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateUI),
            name: NSNotification.Name(rawValue: "UpdateUI"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func updateUI(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.accessData = []
            self.arrAccessId = []
            self.arrName = []
            self.arrEmail = []
            self.arrImg = []
            self.arrModule = []
            self.arrAccessDate = []
            
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
               
                //requested user logic
                for i in 0..<data.count {
                    self.accessData.append(data[i] as! [String:AnyObject])
                    self.arrAccessId.append(data[i]["accessId"] as? String ?? "")
                    self.arrName.append(data[i]["userNameReq"] as? String ?? "")
                   // self.arrEmail.append(data[i]["userEmail"] as? String ?? "")
                    self.arrImg.append(data[i]["imgPath"] as? String ?? "")
                    self.arrModule.append(data[i]["accessModule"] as AnyObject)
                    self.arrAccessDate.append(data[i]["cftAccessDate"] as? String ?? "")
                }
                self.noRecordVw.isHidden = true
                self.tblView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noRecordVw.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
}

extension AccessSettingVC {
    
    func loadViewDesign(){
        btnCalender.isSelected = true
        btnWSC.isSelected = true
        btnSendRequest.layer.cornerRadius = 5.0
        btnSendRequest.clipsToBounds = true
        arrSelectedModule = ["1", "2"]
        txtEmail.text = ""
        
    }
    
    @IBAction func actionSetCalender(_ sender:UIButton){
        self.txtEmail.resignFirstResponder()
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
        self.txtEmail.resignFirstResponder()
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
        self.txtEmail.resignFirstResponder()
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
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "managerEmail": self.txtEmail.text!,
                         "moduleName":module]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "requestAccess", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                self.loadViewDesign()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func validate() -> Bool {
        
        if txtEmail.text == "" {
            OBJCOM.setAlert(_title: "", message: "Enter email to send request.")
            return false
        }else if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
            OBJCOM.setAlert(_title: "", message: "Enter valid email to send request.")
            return false
        }else if self.arrSelectedModule.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one access module to send request.")
            return false
        }
        
        return true
    }
}

extension AccessSettingVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "Cell") as! AccessSettingCell
        
        if cell == nil {
            
        }
        
        cell.lblName.text = self.arrName[indexPath.row]
        cell.lblDate.text = "Date : \(self.arrAccessDate[indexPath.row])"
        cell.btnEdit.tag = indexPath.row
        cell.btnRemoveAccess.tag = indexPath.row
        let pic = self.arrImg[indexPath.row]
        if pic != "" {
            cell.imgView.imageFromServerURL(urlString: pic)
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "noImg")
        }
       
        for subview in cell.accessModuleView.subviews {
            subview.removeFromSuperview()
        }
        let tempArr = self.arrModule[indexPath.row] as! [AnyObject]
        if tempArr.count > 0 {
            
            var x = 5.0
            
            for i in 0 ..< tempArr.count {
                let index = "\(tempArr[i])"
                if index != "3" {
                    let btn = UIButton()
                    btn.frame = CGRect(x: x, y: 5, width: 20, height: 20)
                    btn.setImage(accessImage[(Int(index)!)-1], for: .normal)
                    cell.accessModuleView.addSubview(btn)
                    x = x + 25
                }
            }
        }
        
        cell.btnEdit.addTarget(self
            , action: #selector(actionEdit(_:)), for: .touchUpInside)
        cell.btnRemoveAccess.addTarget(self
            , action: #selector(actionRemoveAccess(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func actionEdit(_ sender:UIButton){
        self.txtEmail.resignFirstResponder()

        if let vc = UIStoryboard(name: "CFT", bundle: nil).instantiateViewController(withIdentifier: "idPopEditRequestVC") as? PopEditRequestVC {
            print(self.accessData[sender.tag])
            vc.accessData = self.accessData[sender.tag]
            let bizVC = BIZPopupViewController.init(contentViewController: vc, contentSize: CGSize(width: self.view.frame.width - 20, height: 500))
            self.present(bizVC!, animated: false, completion: nil)
        }

    }
    
    @objc func actionRemoveAccess(_ sender:UIButton){
        self.txtEmail.resignFirstResponder()
        let accessId = self.arrAccessId[sender.tag]
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.removeUserAccess(accessId:accessId)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func removeUserAccess(accessId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "accessId":accessId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeManager", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                self.loadViewDesign()
                self.getDataFromServer()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
}
