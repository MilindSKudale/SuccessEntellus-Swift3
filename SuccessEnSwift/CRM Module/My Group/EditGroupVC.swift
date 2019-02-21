//
//  EditGroupVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditGroupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var txtGrpName : UITextField!
    @IBOutlet var txtDesc : UITextView!
    @IBOutlet var viewSearch : UIView!
    @IBOutlet var selectionView : UIView!
    @IBOutlet var importCsvView : UIView!
    //@IBOutlet var emailCampaignView : UIView!
    @IBOutlet var btnContact : UIButton!
    @IBOutlet var btnProspect : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var btnRecruit : UIButton!
    @IBOutlet var btnSelectAllSC : UIButton!
    @IBOutlet var lblSelectedCount : UILabel!
    
    @IBOutlet var btnFromSystemContact : UIButton!
    @IBOutlet var btnImportCsvContact : UIButton!
    //@IBOutlet var btnFromEmailCampaigns : UIButton!
    @IBOutlet var btnSelectCsvFile : UIButton!
    @IBOutlet var btnImportCsvFile : UIButton!
    @IBOutlet var lblCsvFile : UILabel!
    var importArray = [AnyObject]()
    
//    @IBOutlet var DDSelectCampaign : UIDropDown!
//    @IBOutlet var btnStatusRead : UIButton!
//    @IBOutlet var btnStatusNotRead : UIButton!
//    @IBOutlet var tblMemberList : UITableView!
//    @IBOutlet var lblTblTitle : UILabel!
//    @IBOutlet var noEmailListView : UIView!
//    @IBOutlet var btnSelectAllECRec : UIButton!

//    var arrCampaignFname = [String]()
//    var arrCampaignLname = [String]()
//    var arrCampaignTitle = [String]()
//    var arrCampaignID = [String]()
//    var arrCampEmailList = [String]()
//    var arrCampEmailID = [String]()
//    var campaignTitle = ""
//    var campaignId = ""
    
    var mainArrayList = [String]()
    var mainArrayID = [String]()
    var mainArrayListSearch = [String]()
    var mainArrayIDSearch = [String]()
    var arrContactList = [String]()
    var arrProspectList = [String]()
    var arrCustomerList = [String]()
    var arrContactID = [String]()
    var arrProspectID = [String]()
    var arrCustomerID = [String]()
    var arrSelectedIDs = [String]()
    var arrRecruitList = [String]()
    var arrRecruitID = [String]()
    var arrSelectedEmailsCampIDs = [String]()
    
    var groupId = ""
    var isEdit = false
    var isFilter = false;
    var isImportCsv = false
    var isImportContact = false
    var docController:UIDocumentInteractionController!
    var dictCsvData = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        self.tblList.tableFooterView = UIView()
        //self.tblMemberList.tableFooterView = UIView()
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
    
        self.btnFromSystemContact.isSelected = true
        self.btnImportCsvContact.isSelected = false
       // self.btnFromEmailCampaigns.isSelected = false
        self.selectionView.isHidden = false
        self.importCsvView.isHidden = true
        //self.emailCampaignView.isHidden = true
        self.isImportCsv = false
        self.dictCsvData = [:]
        self.lblCsvFile.text = ""
        self.btnSelectAllSC.isSelected = false
       // self.lblCsvFile.addImageWith(name: "ic_file", behindText: false)
       
       // DispatchQueue.main.sync {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getGroupData()
            self.getContactList()
            self.getProspectList()
            self.getCustomerList()
            self.getRecruitList()
            //self.getCampaignData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func refreshUIWithData(){
        getGroupData()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getContactList()
            self.getProspectList()
            self.getCustomerList()
            self.getRecruitList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        self.btnFromSystemContact.isSelected = true
        self.btnImportCsvContact.isSelected = false
        //self.btnFromEmailCampaigns.isSelected = false
        self.selectionView.isHidden = false
        self.importCsvView.isHidden = true
       // self.emailCampaignView.isHidden = true
        
        self.setSelected(self.btnProspect)
        self.setDeSelected(self.btnContact)
        self.setDeSelected(self.btnCustomer)
        self.setDeSelected(self.btnRecruit)
        
        mainArrayList = arrProspectList
        mainArrayID = arrProspectID
        isFilter = false
        txtSearch.text = ""
        self.isImportCsv = true
        
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    func designUI(){
        selectionView.layer.borderColor = APPGRAYCOLOR.cgColor
        selectionView.layer.borderWidth = 0.5
        importCsvView.layer.borderColor = APPGRAYCOLOR.cgColor
        importCsvView.layer.borderWidth = 0.5
//        emailCampaignView.layer.borderColor = APPGRAYCOLOR.cgColor
//        emailCampaignView.layer.borderWidth = 0.5
        
//        self.btnStatusRead.isSelected = true
//        self.btnStatusNotRead.isSelected = false
//        self.btnSelectAllECRec.isSelected = false
        
        txtDesc.layer.borderColor = APPGRAYCOLOR.cgColor
        txtDesc.layer.borderWidth = 0.5
        txtDesc.layer.cornerRadius = 5.0
        txtDesc.clipsToBounds = true
        txtDesc.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        txtGrpName.layer.borderColor = APPGRAYCOLOR.cgColor
        txtGrpName.layer.borderWidth = 0.5
        txtGrpName.layer.cornerRadius = 5.0
        txtGrpName.clipsToBounds = true
        txtGrpName.setLeftPaddingPoints()
        txtGrpName.setRightPaddingPoints()
        
        self.btnSelectCsvFile.layer.cornerRadius = 5.0
        self.btnSelectCsvFile.clipsToBounds = true
        self.btnImportCsvFile.layer.cornerRadius = 5.0
        self.btnImportCsvFile.clipsToBounds = true
        self.btnImportCsvFile.isEnabled = false
        viewSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        viewSearch.layer.borderWidth = 0.5
        txtSearch.leftViewMode = UITextFieldViewMode.always
        txtSearch.layer.cornerRadius = txtSearch.frame.size.height/2
        txtSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        txtSearch.layer.borderWidth = 0.5
        txtSearch.clipsToBounds = true
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        let image = #imageLiteral(resourceName: "icons8-search")
        
        imageView.image = image
        uiView.addSubview(imageView)
        txtSearch.leftView = uiView
        self.txtSearch.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func getGroupData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "groupId":groupId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getDetailGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String:AnyObject]
                print(result)
//                group_name
                self.arrSelectedIDs = []
                //self.isImportContact = false
                self.txtGrpName.text = result["group_name"] as? String ?? ""
                self.txtDesc.text = result["group_description"] as? String ?? ""
                let contactData = result["contact"]
                let contactId = contactData!["contact_id"] as! [AnyObject]
                for i in contactId {
                    self.arrSelectedIDs.append(i as! String)
                }
                
                let prospectData = result["prospect"]
                let prospectId = prospectData!["contact_id"] as! [AnyObject]
                for i in prospectId {
                    self.arrSelectedIDs.append(i as! String)
                }
                
                let customerData = result["customer"]
                let customerId = customerData!["contact_id"] as! [AnyObject]
                for i in customerId {
                    self.arrSelectedIDs.append(i as! String)
                }
                
                let recruitData = result["recruit"]
                let recruitId = recruitData!["contact_id"] as! [AnyObject]
                for i in recruitId {
                    self.arrSelectedIDs.append(i as! String)
                }
                self.lblSelectedCount.text = "(\(self.arrSelectedIDs.count))"
                if self.arrSelectedIDs.count > 0 {
                    self.isImportContact = true
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionClose (_ sender:UIButton){
        if isEdit == true {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.presentingViewController?.presentingViewController?.dismiss (animated: true, completion: nil)
        }
    }
    
    @IBAction func actionSelectAllRecords(_ btn : UIButton){
        
        if btn.isSelected {
            if isFilter {
                for i in 0 ..< self.mainArrayIDSearch.count {
                    let selId = self.mainArrayIDSearch[i]
                    if self.arrSelectedIDs.contains(selId){
                        if let index = self.arrSelectedIDs.index(of: selId) {
                            self.arrSelectedIDs.remove(at: index)
                        }
                    }else{
                        self.arrSelectedIDs.append(selId)
                    }
                }
            }else{
                for i in 0 ..< self.mainArrayID.count {
                    let selId = self.mainArrayID[i]
                    if self.arrSelectedIDs.contains(selId){
                        if let index = self.arrSelectedIDs.index(of: selId) {
                            self.arrSelectedIDs.remove(at: index)
                        }
                    }else{
                        self.arrSelectedIDs.append(selId)
                    }
                }
            }
            btn.isSelected = false
        }else{
            btn.isSelected = true
            if isFilter {
                for obj in self.mainArrayIDSearch {
                    if !self.arrSelectedIDs.contains(obj) {
                        self.arrSelectedIDs.append(obj)
                    }
                }
            }else{
                for obj in self.mainArrayID {
                    if !self.arrSelectedIDs.contains(obj) {
                        self.arrSelectedIDs.append(obj)
                    }
                }
            }
        }
        self.lblSelectedCount.text = "(\(self.arrSelectedIDs.count))"
        self.tblList.reloadData()
    }
}

extension EditGroupVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tblList {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblList {
            if isFilter {
                return self.mainArrayListSearch.count
            }else { return mainArrayList.count }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "EditCell") as! EditGroupCell
        if tableView == tblList {
            if isFilter {
                cell.lblName.text = self.mainArrayListSearch[indexPath.row]
                
                let selId = self.mainArrayIDSearch[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    cell.imgSelectBox.image = #imageLiteral(resourceName: "checkbox_ic")
                }else{
                    cell.imgSelectBox.image = #imageLiteral(resourceName: "uncheck")
                }
            }else{
                cell.lblName.text = self.mainArrayList[indexPath.row]
                
                let selId = self.mainArrayID[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    cell.imgSelectBox.image = #imageLiteral(resourceName: "checkbox_ic")
                }else{
                    cell.imgSelectBox.image = #imageLiteral(resourceName: "uncheck")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblList {
            if isFilter {
                let selId = self.mainArrayIDSearch[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    if let index = self.arrSelectedIDs.index(of: selId) {
                        self.arrSelectedIDs.remove(at: index)
                    }
                }else{
                    self.arrSelectedIDs.append(selId)
                }
            }else{
                let selId = self.mainArrayID[indexPath.row]
                if self.arrSelectedIDs.contains(selId){
                    if let index = self.arrSelectedIDs.index(of: selId) {
                        self.arrSelectedIDs.remove(at: index)
                    }
                }else{
                    self.arrSelectedIDs.append(selId)
                }
            }
            if self.arrSelectedIDs.count > 0 {
                self.isImportContact = true
            }else{
                self.isImportContact = false
            }
            self.lblSelectedCount.text = "(\(self.arrSelectedIDs.count))"
            self.tblList.reloadData()
        }
    }
}

extension EditGroupVC {
    
    @IBAction func actionShowContactList (_ sender:UIButton){
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrContactList
        mainArrayID = arrContactID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowProspectList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrProspectList
        mainArrayID = arrProspectID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowCustomerList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrCustomerList
        mainArrayID = arrCustomerID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    @IBAction func actionShowRecruitList (_ sender:UIButton){
        self.setDeSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setSelected(btnRecruit)
        mainArrayList = arrRecruitList
        mainArrayID = arrRecruitID
        var count = 0
        for i in 0 ..< mainArrayID.count {
            if self.arrSelectedIDs.count > 0 {
                if self.arrSelectedIDs.contains(mainArrayID[i]){
                    count = count + 1
                }
            }
        }
        if self.mainArrayID.count > 0 {
            if count == mainArrayID.count {
                self.btnSelectAllSC.isSelected = true
            }else{
                self.btnSelectAllSC.isSelected = false
            }
        }else{
            self.btnSelectAllSC.isSelected = false
        }
        isFilter = false
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        self.tblList.reloadData()
    }
    
    func setSelected(_ btn : UIButton){
        btn.backgroundColor = APPGRAYCOLOR
        btn.setTitleColor(.white, for: .normal)
    }
    func setDeSelected(_ btn : UIButton){
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func actionUpdateGroup (_ sender:UIButton){
        if txtGrpName.text == ""{
            OBJCOM.setAlert(_title: "", message: "Please enter group name.")
            return
        }
        else if self.arrSelectedIDs.count == 0 && self.isImportContact == false {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one group member.")
            return
        }else{
            self.updateGroup()
        }
    }
}

extension EditGroupVC {
    
    func getContactList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrContactList = []
                self.arrContactID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrContactList.append(name)
                        self.arrContactID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                self.mainArrayList = self.arrContactList
                self.mainArrayID = self.arrContactID
                var count = 0
                for i in 0 ..< self.mainArrayID.count {
                    if self.arrSelectedIDs.count > 0 {
                        if self.arrSelectedIDs.contains(self.mainArrayID[i]){
                            count = count + 1
                        }
                    }
                }
                if self.mainArrayID.count > 0 {
                    if count == self.mainArrayID.count {
                        self.btnSelectAllSC.isSelected = true
                    }else{
                        self.btnSelectAllSC.isSelected = false
                    }
                }else{
                    self.btnSelectAllSC.isSelected = false
                }
                self.tblList.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getProspectList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrProspectList = []
                self.arrProspectID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrProspectList.append(name)
                        self.arrProspectID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                if self.isImportCsv == true {
                    self.mainArrayList = self.arrProspectList
                    self.mainArrayID = self.arrProspectID
                    self.tblList.reloadData()
                    self.isImportCsv = false
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getCustomerList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"2"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrCustomerList = []
                self.arrCustomerID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrCustomerList.append(name)
                        self.arrCustomerID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func getRecruitList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"4"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                print(result)
                self.arrRecruitList = []
                self.arrRecruitID = []
                for i in 0..<result.count {
                    let fname = result[i]["contact_fname"] as? String ?? ""
                    let lname = result[i]["contact_lname"] as? String ?? ""
                    let name = fname+" "+lname
                    if name != "" {
                        self.arrRecruitList.append(name)
                        self.arrRecruitID.append(result[i]["contact_id"] as? String ?? "")
                    }
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateGroup(){
        
        let strSelect = self.arrSelectedIDs.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_id": groupId,
                         "group_name":txtGrpName.text!,
                         "group_description":txtDesc.text!,
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if self.isEdit == true {
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        };
    }
}

extension EditGroupVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        mainArrayIDSearch.removeAll()
        mainArrayListSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< self.mainArrayList.count {
                let strName = mainArrayList[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if strName != nil {
                    self.mainArrayListSearch.append(self.mainArrayList[i])
                    self.mainArrayIDSearch.append(self.mainArrayID[i])
                }
            }
        } else {
            isFilter = false
        }
        self.tblList.reloadData()
    }
    
    @IBAction func actionSelectSystemContacts(_ btn : UIButton){
        self.btnFromSystemContact.isSelected = true
        self.btnImportCsvContact.isSelected = false
//        self.btnFromEmailCampaigns.isSelected = false
//        self.emailCampaignView.isHidden = true
        self.selectionView.isHidden = false
        self.importCsvView.isHidden = true
        self.tblList.reloadData()
    }
    
    @IBAction func actionImportCsvContacts(_ btn : UIButton){
        self.btnFromSystemContact.isSelected = false
        self.btnImportCsvContact.isSelected = true
//        self.btnFromEmailCampaigns.isSelected = false
//        self.emailCampaignView.isHidden = true
        self.selectionView.isHidden = true
        self.importCsvView.isHidden = false
    }
    
//    @IBAction func actionSelectEmailCampaigns(_ btn : UIButton){
//        self.btnFromSystemContact.isSelected = false
//        self.btnImportCsvContact.isSelected = false
//        self.btnFromEmailCampaigns.isSelected = true
//        self.emailCampaignView.isHidden = false
//        self.selectionView.isHidden = true
//        self.importCsvView.isHidden = true
//        self.btnSelectAllECRec.isSelected = false
//        self.tblMemberList.reloadData()
//    }
//
    @IBAction func actionSelectCsvFile(_ btn : UIButton){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func actionImportCsvFile(_ btn : UIButton){
        
        if isImportCsv == true && groupId != ""{
          //  self.importCSVgroup(impArray: importArray, crmFlag: "3", grpId: groupId)
            self.importCSVfileInGroup(self.dictCsvData["fileData"] as! Data, filename: self.dictCsvData["fileName"] as! String, grpId: groupId) { JsonDict in
                let success:String = JsonDict!["IsSuccess"] as? String ?? "false"
                if success == "true"{
                    let result = JsonDict!["result"] as? String ?? ""
                    print(result)
                    let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    OBJCOM.hideLoader()
                }else{
                    print("result:",JsonDict ?? "")
                    let result = JsonDict!["result"] as? String ?? ""
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            }
        }
    }
    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        print(url)
//
//        print(url.lastPathComponent)
//        print(url.pathExtension)
//
//        if controller.documentPickerMode == .import {
//            var arrImpFname = [String]();
//           // var arrImpMiddle = [String]();
//            var arrImpLname = [String]();
//            var arrImpEmail = [String]();
//            var arrImpPhone = [String]();
//
//            let content = try? String(contentsOf: url, encoding: .ascii)
//            var rows = content?.components(separatedBy: "\n")
//
//            var columnsTitle = rows![0].components(separatedBy: ",")
//            if columnsTitle.count >= 4 {
//                var fn = columnsTitle[0]
//               // let mn = columnsTitle[1]
//                var ln = columnsTitle[1]
//                var em = columnsTitle[2]
//                var ph = columnsTitle[3]
//
//                fn = fn.replacingOccurrences(of: "\r", with: "")
//                ln = ln.replacingOccurrences(of: "\r", with: "")
//                em = em.replacingOccurrences(of: "\r", with: "")
//                ph = ph.replacingOccurrences(of: "\r", with: "")
//
//                if fn == "fname" && ln == "lname" && em == "email" && ph == "phone"{
//                    for i in 1..<(rows?.count)!-1 {
//                        var columns = rows![i].components(separatedBy: ",")
//                        if columns.count > 0{
//                            arrImpFname.append(columns[0])
//                           // arrImpMiddle.append(columns[1])
//                            arrImpLname.append(columns[1])
//                            arrImpEmail.append(columns[2])
//                            arrImpPhone.append(columns[3])
//                        }
//                    }
//
//                    for i in 0..<arrImpFname.count {
//                        let tempDict = ["fname": arrImpFname[i],
//                                        "lname": arrImpLname[i],
//                                        "email": arrImpEmail[i],
//                                        "phone": arrImpPhone[i]]
//                        importArray.append(tempDict as AnyObject)
//                    }
//                    self.btnImportCsvFile.isEnabled = true
//                    self.lblCsvFile.text = " \(url.lastPathComponent)"
//                    self.lblCsvFile.addImageWith(name: "ic_file", behindText: false)
//                    if self.importArray.count > 0 {
//                        self.isImportContact = true
//                    }else{
//                        OBJCOM.setAlert(_title: "", message: "No records available in CSV file.")
//                        return
//                    }
//
//                }else{
//                    OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
//                    return
//                }
//            }else{
//                OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
//                return
//            }
//        }
//    }
//
//    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
//
//    }
//
//    func importCSVgroup(impArray : [AnyObject], crmFlag : String, grpId: String) {
//        let dictParam = ["userId":userID,
//                         "platform":"3",
//                         "crmFlag":crmFlag,
//                         "csvDetails": impArray,
//                         "groupId":grpId] as [String : Any]
//
//        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//        let jsonString = String(data: jsonData!, encoding: .utf8)
//        let dictParamTemp = ["param":jsonString];
//
//        typealias JSONDictionary = [String:Any]
//        OBJCOM.modalAPICall(Action: "importCsvCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
//            JsonDict, staus in
//
//            let success:String = JsonDict!["IsSuccess"] as! String
//            if success == "true"{
//                OBJCOM.hideLoader()
//                let result = JsonDict!["result"] as! String
//                print(result)
//                let alertController = UIAlertController(title: "", message: "File imported successfully. All entries in CSV file will be visible in My Prospects", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
//                    UIAlertAction in
//
//                    self.refreshUIWithData()
//                }
//                alertController.addAction(okAction)
//                self.present(alertController, animated: true, completion: nil)
//
//            }else{
//                print("result:",JsonDict ?? "")
//                OBJCOM.hideLoader()
//            }
//        };
//    }
}
extension EditGroupVC : UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                OBJCOM.hideLoader()
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                self.dictCsvData = ["fileData":data!,
                                    "fileName": URL.lastPathComponent!] as [String : AnyObject]
                DispatchQueue.main.async(execute: {
                    self.lblCsvFile.text = "\(URL.lastPathComponent!)"
                    self.btnImportCsvFile.isEnabled = true
                    self.isImportCsv = true
                })
            }else {
                // Failure
                OBJCOM.hideLoader()
                print("Failure: %@", error!.localizedDescription)
            }
        });
        task.resume()
    }

    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url = \(url)")
        
        let pathExtention = url.pathExtension
        if pathExtention == "csv" || pathExtention == "CSV" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.downloadfile(URL: url as NSURL)
            }else{
                OBJCOM.showNetworkAlert()
            }
        } else{
            OBJCOM.setAlert(_title: "", message: "Supported file format for importing contact is .csv")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func importCSVfileInGroup(_ file:Data, filename:String, grpId:String, completionHandler: @escaping ([String:Any]?) -> ()) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "groupId":grpId,
                          "groupName":self.txtGrpName.text!]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)importGroupCSV", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
        print(URL2)
        print(parameters)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData as Data, withName: "upload", fileName: filename, mimeType: "text/plain")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: URL2 , encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    if let JsonDict = response.result.value as? [String : Any]{
                        print(JsonDict)
                        completionHandler(JsonDict)
                        OBJCOM.hideLoader()
                    }else {
                        OBJCOM.setAlert(_title: "", message: "Failed to import file.")
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_):
                OBJCOM.hideLoader()
                break
            }
        })
    }
}
