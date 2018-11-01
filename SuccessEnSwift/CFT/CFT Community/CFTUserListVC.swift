//
//  CFTUserListVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 06/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var cftDisplayFlagAll = "0"

class CFTUserListVC: UIViewController {
    
    @IBOutlet var tblCftList : UITableView!
    @IBOutlet var btnDisableAll : UIButton!
    var arrUserId = [String]()
    var arrUserName = [String]()
    var arrUserProfile = [String]()
    var arrStatus = [AnyObject]()
    
    var arrSelectedForHide = [String]()
    //var arrSelectedForShow : [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCftList.tableFooterView = UIView()
        self.arrSelectedForHide = []
        
        if cftDisplayFlagAll == "1" {
            btnDisableAll.setTitle("Enable All", for: .normal)
        }else{
            btnDisableAll.setTitle("Disable All", for: .normal)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getCftInfoWithShowStatus()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionCloseVC(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name("executeRepeatedly"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDisableAll(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Disable All" {
            self.disableAllCFT("1")
            sender.setTitle("Enable All", for: .normal)
        }else{
            self.disableAllCFT("0")
            sender.setTitle("Disable All", for: .normal)
        }
        
    }
}

extension CFTUserListVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrUserId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblCftList.dequeueReusableCell(withIdentifier: "Cell") as! CFTUserListCell
   
        cell.lblCftName.text = self.arrUserName[indexPath.row]
        let userIdHide = self.arrUserId[indexPath.row]
        
        if self.arrSelectedForHide.contains(userIdHide) {
            cell.btnShowHide.setOn(false, animated: true)
        }else{
            cell.btnShowHide.setOn(true, animated: true)
        }
        
        cell.btnShowHide.tag = indexPath.row
        cell.btnShowHide.addTarget(self, action: #selector(actionShowHide(_:)), for: .valueChanged)
    
        return cell
    }
}

extension CFTUserListVC {
    
    @objc func actionShowHide(_ sender : UISwitch!) {
        
        let selectedUID = self.arrUserId[sender.tag]

        if !sender.isOn {
            if !self.arrSelectedForHide.contains(selectedUID) {
                 self.arrSelectedForHide.append(selectedUID)
            }
            self.hideVisibility(selectedUID)
            sender.isOn = false
        }else{
            if self.arrSelectedForHide.contains(selectedUID) {
                let index = self.arrSelectedForHide.index(of: selectedUID)
                self.arrSelectedForHide.remove(at: index!)
                self.showVisibility(selectedUID)
                sender.isOn = true
                self.btnDisableAll.setTitle("Disable All", for: .normal)
            }
        }
    }
    
    
    func getCftInfoWithShowStatus(){
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCftInfoWithShowStatus", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrUserId = []
            self.arrUserName = []
            self.arrUserProfile = []
            self.arrStatus = []
            self.arrSelectedForHide = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" {
                let result = JsonDict!["result"] as! [AnyObject]
              //  print("result:",result)
                for obj in result {
                    let name = "\(obj["first_name"] as? String ?? "") \(obj["last_name"] as? String ?? "")"
                    self.arrUserId.append(obj["userId"] as? String ?? "")
                    self.arrUserName.append(name)
                    self.arrUserProfile.append(obj["profile_pic"] as? String ?? "")
                    self.arrStatus.append(obj["showStatus"] as AnyObject)
                }
                
                for i in 0 ..< self.arrStatus.count {
                    if "\(self.arrStatus[i])" == "0" {
                        self.arrSelectedForHide.append(self.arrUserId[i])
                    }
                }
                OBJCOM.hideLoader()
            } else {
                OBJCOM.hideLoader()
            }
            self.tblCftList.reloadData()
        };
    }
    
    func showVisibility(_ selectedid:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftShowListUser":selectedid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "showHiddenCftList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
    
    func hideVisibility(_ selectedid:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftListUser":selectedid]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "hiddenCftList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            OBJCOM.hideLoader()
        };
    }
    
    func disableAllCFT(_ disableFlag:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "disableFlag":disableFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "cftDisableToAll", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            cftDisplayFlagAll = JsonDict!["disableFlag"] as? String ?? "0"
            
            if cftDisplayFlagAll == "1" {
                self.btnDisableAll.setTitle("Enable All", for: .normal)
            }else{
                self.btnDisableAll.setTitle("Disable All", for: .normal)
            }
            
            self.getCftInfoWithShowStatus()
            OBJCOM.hideLoader()
        };
    }
    
    
    
    

}

