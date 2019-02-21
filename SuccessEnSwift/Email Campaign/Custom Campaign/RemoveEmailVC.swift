//
//  RemoveEmailVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class RemoveEmailVC: UIViewController {

    @IBOutlet var lblCampaignName : UILabel!
    @IBOutlet var lblCampaignDate : UILabel!
    @IBOutlet var tblMemberList : UITableView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnRemove : UIButton!
    @IBOutlet var uiView : UIView!
    @IBOutlet var noMemberView : UIView!
    
    var textCampaignId = ""
    var textCampaignName = ""
    
    var arrMemberId = [String]()
    var arrMemberName = [String]()
    var arrMemberEmail = [String]()
    var arrAssignedDate = [String]()
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
        lblCampaignDate.text = "Email campaign created on "
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
            OBJCOM.setAlert(_title: "", message: "Please select atleast one email to remove.")
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

extension RemoveEmailVC {
    func getMemberDetails(){
        
        if textCampaignId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":textCampaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMemberAssignedToEmailCampaign", param : dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMemberId = []
            self.arrMemberName = []
            self.arrMemberEmail = []
            self.arrAssignedDate = []
            self.arrSelectedMemberId = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.btnRemove.isEnabled = true
                
                self.lblCampaignName.text = result["campaignTitle"] as? String ?? ""
                self.lblCampaignDate.text = "Email campaign created on \(result["campaignDateTime"] as? String ?? "")"
                let memberDetails = result["memberDetails"] as! [AnyObject]
                
                for obj in memberDetails {
                    self.arrMemberName.append(obj.value(forKey: "contact_name") as! String)
                    self.arrMemberEmail.append(obj.value(forKey: "contact_email") as! String)
                    self.arrMemberId.append(obj.value(forKey: "contactCampaignId") as! String)
                    self.arrAssignedDate.append(obj.value(forKey: "contactCampaignDate") as! String)
                }
                self.tblMemberList.reloadData()
                OBJCOM.hideLoader()
            }else{
                let campDetails = JsonDict!["responseCampDetails"] as! [String : AnyObject]
                self.lblCampaignName.text = campDetails["campaignTitle"] as? String ?? ""
                self.lblCampaignDate.text = "Email campaign created on \(campDetails["campaignDateTime"] as? String ?? "")"
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
                         "contactCampaignIds":memberId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "removeMemberFromGivenEmailCamp", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? "Email removed from given email campaign!"
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

extension RemoveEmailVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrMemberName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMemberList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RemoveEmailCell
        
        cell.lblMemberName.text = arrMemberName[indexPath.row]
        cell.lblMemberEmail.text = "Email : \(arrMemberEmail[indexPath.row])"
        cell.lblAssignedDate.text = "Assigned on \(arrAssignedDate[indexPath.row])"
        
        cell.imgView.image = #imageLiteral(resourceName: "unchk")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tblMemberList.cellForRow(at: indexPath) as! RemoveEmailCell
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
