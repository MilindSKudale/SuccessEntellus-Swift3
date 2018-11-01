//
//  RemoveMemberVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class RemoveMemberVC: UIViewController {
    
    @IBOutlet var lblCampaignName : UILabel!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnRemove : UIButton!
    @IBOutlet var uiView : UIView!
    @IBOutlet var noMemberView : UIView!
    
    var textCampaignId = ""
    var textCampaignName = ""
    
    var arrMemberId = [String]()
    var arrMemberName = [String]()
    var arrMemberPhone = [String]()
    var arrSelectedMemberId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         designUI()
    }
    
    func designUI(){
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.height/2
        btnCancel.clipsToBounds = true
        
        btnRemove.layer.cornerRadius = btnRemove.frame.height/2
        btnRemove.clipsToBounds = true
        
        lblCampaignName.text = textCampaignName
        noMemberView.isHidden = true
        tblMemberList.tableFooterView = UIView()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.setView(view: self.noMemberView, hidden: true)
                self.getMemberDetails()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRemove(_ sender:UIButton){
        if self.arrSelectedMemberId.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one member to remove.")
            return
        }
        
        let selectId = self.arrSelectedMemberId.joined(separator: ",")
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.removeMembers(selectId)
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension RemoveMemberVC {
    func getMemberDetails(){
        
        if textCampaignId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtCampId":textCampaignId]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];


        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMemberAssignedToTextCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in

            self.arrMemberId = []
            self.arrMemberName = []
            self.arrMemberPhone = []
            self.arrSelectedMemberId = []

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.btnRemove.isEnabled = true
                
                self.lblCampaignName.text = result["txtCampName"] as? String ?? ""
                let memberDetails = result["memberDetails"] as! [AnyObject]
                
                for obj in memberDetails {
                    self.arrMemberName.append(obj.value(forKey: "contact_name") as! String)
                    self.arrMemberPhone.append(obj.value(forKey: "contact_phone") as! String)
                    self.arrMemberId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                }
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.btnRemove.isEnabled = false
                self.setView(view: self.noMemberView, hidden: false)
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
                
            }
            
        };
    }
    
    func removeMembers(_ memberId:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtcontactCampaignIds":memberId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeMemberFromGivenTextCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
           
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? "Member(s) removed from given text campaign!"
                OBJCOM.setAlert(_title: "", message: result)
                print(result)
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                        self.setView(view: self.noMemberView, hidden: true)
                        self.getMemberDetails()
                    }
                }else{ OBJCOM.NoInternetConnectionCall() }
            }else{ OBJCOM.hideLoader() }
        };
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}

extension RemoveMemberVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMemberName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RemoveMemberCell
        
        cell.lblMemberName.text = arrMemberName[indexPath.row]
        cell.lblMemberPhone.text = arrMemberPhone[indexPath.row]
        cell.imgView.image = #imageLiteral(resourceName: "unchk")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let cell = tblMemberList.cellForRow(at: indexPath) as! RemoveMemberCell
        let selId = self.arrMemberId[indexPath.row]
        if arrSelectedMemberId.contains(selId){
            cell.imgView.image = #imageLiteral(resourceName: "unchk")
            let index = arrSelectedMemberId.index(of: selId)
            self.arrSelectedMemberId.remove(at: index!)
        }else{
            cell.imgView.image = #imageLiteral(resourceName: "chk")
            self.arrSelectedMemberId.append(selId)
        }
        print(self.arrSelectedMemberId)
    }
}
