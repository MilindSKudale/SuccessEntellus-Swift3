//
//  MemberDetailsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class MemberDetailsVC: UIViewController {

    @IBOutlet var emailTableView : LUExpandableTableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnDeleteAllFollw: UIButton!
    @IBOutlet weak var lblTemplateName: UILabel!
    @IBOutlet weak var lblTemplateCreatedDate: UILabel!
    
    var arrContactId = [String]()
    var arrContactEmail = [String]()
    var arrContactName = [String]()
    var arrContactPhone = [String]()
//    var arrReadImg = [String]()
    var arrScheduleDate = [String]()
    var arrStatus = [String]()
    
    let cellIdentifier = "Cell"
    let sectionHeaderIdentifier = "Header"
    
    var arrSelectedRecords = [String]()
    var templateId = ""
    var campaignId = ""
    var isRepeate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.isHidden = true
        
        emailTableView.register(EmailDetailsCell.self, forCellReuseIdentifier: cellIdentifier)
        emailTableView.register(UINib(nibName: "EmailDetailsHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderIdentifier)
        
        emailTableView.expandableTableViewDataSource = self
        emailTableView.expandableTableViewDelegate = self
        emailTableView.tableFooterView = UIView()
        
        btnDelete.layer.cornerRadius = 5
        btnDeleteAllFollw.layer.cornerRadius = 5
        btnDelete.clipsToBounds = true
        btnDeleteAllFollw.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.setView(view: self.noDataView, hidden: true)
                self.getMemberDetails()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnDelete(sender: UIButton) {
        if self.arrSelectedRecords.count > 0 {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.deteteAPI()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one record to delete.")
        }
    }
    
    @IBAction func actionBtnDeleteAllFollowing(sender: UIButton) {
        if isRepeate == true {
            OBJCOM.setAlert(_title: "", message: "Not allowed for repeat time interval.")
            return
        }else{
            if self.arrSelectedRecords.count > 0 {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                        self.deteteAllFollowingAPI()
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                OBJCOM.setAlert(_title: "", message: "Please select atleast one record to delete.")
            }
        }
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}

// MARK: - LUExpandableTableViewDataSource
extension MemberDetailsVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return self.arrContactName.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "Cell") as? EmailDetailsCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
            
        }
        cell.lblEmail.text = "Phone : \(self.arrContactPhone[indexPath.section])";
        cell.lblPhone.text = "Schedule date : \(self.arrScheduleDate[indexPath.section])";
        cell.lblDate.text = "";
        cell.selectionStyle = .none
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as? EmailDetailsHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        sectionHeader.labelName.text = self.arrContactName[section]
        sectionHeader.labelStatus.text = "Status : \(self.arrStatus[section])"
        if self.arrSelectedRecords.contains(arrContactId[section]){
            sectionHeader.btnSelect.setImage(#imageLiteral(resourceName: "checkbox_ic"), for: .normal)
        }else{
            sectionHeader.btnSelect.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        sectionHeader.btnSelect.tag = section
        sectionHeader.btnSelect.addTarget(self, action: #selector(actionSelectRecord(_:)), for: .touchUpInside)
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension MemberDetailsVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 80 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat { return 55 }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select section header at section \(section)")
        
        if self.arrSelectedRecords.contains(arrContactId[section]){
            if let index = self.arrSelectedRecords.index(of: self.arrContactId[section]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(self.arrContactId[section])
        }
        self.emailTableView.reloadData()
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
}

extension MemberDetailsVC {
    
    @IBAction func actionSelectRecord(_ sender : UIButton) {
        if self.arrSelectedRecords.contains(arrContactId[sender.tag]){
            if let index = self.arrSelectedRecords.index(of: self.arrContactId[sender.tag]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(self.arrContactId[sender.tag])
        }
        print(self.arrSelectedRecords)
        self.emailTableView.reloadData()
    }
    
    func getMemberDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateId":templateId,
                         "txtTemplateCampId":campaignId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTxtMsgAssigndetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String : AnyObject]
                print(result)
                self.setView(view: self.noDataView, hidden: true)
                self.lblTemplateName.text = result["campaignStepTitle"] as? String ?? ""
                self.lblTemplateCreatedDate.text = "Email template created on : \(result["txtTemplateAddDate"] as? String ?? "")"
                
                let memberDetails = result["memberDetails"] as! [AnyObject]
                
                self.arrContactId = []
                self.arrContactEmail = []
                self.arrContactName = []
                self.arrContactPhone = []
//                self.arrReadImg = []
                self.arrScheduleDate = []
                self.arrStatus = []
                
                if memberDetails.count > 0 {
                    for obj in memberDetails {
                        self.arrContactId.append(obj.value(forKey: "txtcontactCampaignId") as! String)
                        self.arrContactEmail.append(obj.value(forKey: "contactEmail") as! String)
                        self.arrContactName.append(obj.value(forKey: "contactName") as! String)
                        self.arrContactPhone.append(obj.value(forKey: "contactPhone") as! String)
                        self.arrScheduleDate.append(obj.value(forKey: "scheduleDate") as! String)
                        self.arrStatus.append(obj.value(forKey: "sent") as! String)
                    }
                }
                self.emailTableView.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.arrContactId = []
                self.arrContactEmail = []
                self.arrContactName = []
                self.arrContactPhone = []
//                self.arrReadImg = []
                self.arrScheduleDate = []
                self.arrStatus = []
                self.setView(view: self.noDataView, hidden: false)
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                self.emailTableView.reloadData()
            }
            
        };
    }
    
    func deteteAPI() {
        
        let strEmailId = self.arrSelectedRecords.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateId":templateId,
                         "txtTemplateCampId":campaignId,
                         "emailDetails":strEmailId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getMemberDetails()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func deteteAllFollowingAPI() {
        
        let strEmailId = self.arrSelectedRecords.joined(separator: ",")
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "txtTemplateCampId":campaignId,
                         "txtTemplateId":templateId,
                         "emailDetails":strEmailId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "notSendToCurrentAndFollowingTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        DispatchQueue.main.async {
                            self.getMemberDetails()
                        }
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

