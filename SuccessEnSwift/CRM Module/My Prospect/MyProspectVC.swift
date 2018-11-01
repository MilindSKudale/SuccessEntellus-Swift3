//
//  MyProspectVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 20/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView
import Contacts

class MyProspectVC: SliderVC, UITextFieldDelegate, UIDocumentPickerDelegate, UIDocumentMenuDelegate {
   
    var selectedTag = ""
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var tblProspectList : LUExpandableTableView!
    @IBOutlet var btnMove : UIButton!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet weak var actionViewHeight: NSLayoutConstraint!
    @IBOutlet var noRecView : UIView!
    
    var isFilter = false;
    var selectAllRecords = false
    let cellReuseIdentifier = "CrmCell"
    let sectionHeaderReuseIdentifier = "MyCrmHeader"
    
    var arrProspectData = [AnyObject]()
    var arrFirstName = [String]()
    var arrLastName = [String]()
    var arrEmail = [String]()
    var arrPhone = [String]()
    var arrProspectId = [String]()
    var arrMiddleName = [String]()
    var arrCategory = [String]()
    
    var arrFirstNameSearch = [String]()
    var arrLastNameSearch = [String]()
    var arrEmailSearch = [String]()
    var arrPhoneSearch = [String]()
    var arrMiddleNameSearch = [String]()
    var arrCategorySearch = [String]()
    var arrProspectIdSearch = [String]()
    
    var arrImpFname = [String]()
    var arrImpMiddle = [String]();
    var arrImpLname = [String]();
    var arrImpEmail = [String]();
    var arrImpPhone = [String]();
    
    var arrSelectedRecords = [String]()
    var prospectCsvArray:[Dictionary<String, AnyObject>] =  Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Prospects"
        
        tblProspectList.register(MyCrmCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tblProspectList.register(UINib(nibName: "CrmHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)

        tblProspectList.tableFooterView = UIView()
        noRecView.isHidden = true
        
        isFilter = false;
        
        actionViewHeight.constant = 0.0
        btnMove.layer.cornerRadius = 5.0
        btnDelete.layer.cornerRadius = 5.0
        btnMove.clipsToBounds = true
        btnDelete.clipsToBounds = true
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = APPORANGECOLOR
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "ic_add_white")) { item in
            print("Action Float button")
            OBJCOM.animateButton(button: actionButton)
            let storyboard = UIStoryboard(name: "CRM", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddProspectVC")
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
        }
        actionButton.display(inViewController: self)
        
        txtSearch.leftViewMode = UITextFieldViewMode.always
        txtSearch.layer.cornerRadius = txtSearch.frame.size.height/2
        txtSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        txtSearch.layer.borderWidth = 1.0
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
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getProspectData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getProspectData(){
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
                self.arrProspectData = JsonDict!["result"] as! [AnyObject]
                if self.arrProspectData.count > 0 {
                    self.arrFirstName = self.arrProspectData.compactMap { $0["contact_fname"] as? String }
                    self.arrMiddleName = self.arrProspectData.compactMap { $0["contact_middle"] as? String }
                    self.arrLastName = self.arrProspectData.compactMap { $0["contact_lname"] as? String }
                    self.arrEmail = self.arrProspectData.compactMap { $0["contact_email"] as? String }
                    self.arrPhone = self.arrProspectData.compactMap { $0["contact_phone"] as? String }
                    self.arrProspectId = self.arrProspectData.compactMap { $0["contact_id"] as? String }
                    self.arrCategory = self.arrProspectData.compactMap { $0["contact_category"] as? String }
                    
                }
                if self.arrFirstName.count > 0 {
                    self.noRecView.isHidden = true
                }
                OBJCOM.hideLoader()
            }else{
                self.noRecView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblProspectList.expandableTableViewDataSource = self
            self.tblProspectList.expandableTableViewDelegate = self
            self.tblProspectList.reloadData()
        };
    }
    
    @IBAction func actionSelectAll(_ sender: UIButton) {
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        if !sender.isSelected{
            self.arrSelectedRecords.removeAll()
            for id in arrId {
                self.arrSelectedRecords.append(id)
            }
            sender.isSelected = true
            selectAllRecords = true
        }else{
            self.arrSelectedRecords.removeAll()
            sender.isSelected = false
            selectAllRecords = false
        }
        self.tblProspectList.reloadData()
        showHideMoveDeleteButtons()
        print("Selected id >> ",self.arrSelectedRecords)
    }
    
    @IBAction func actionSelectRecord(_ sender: UIButton) {
        selectAllRecords = false
        view.layoutIfNeeded()
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        if self.arrSelectedRecords.contains(arrId[sender.tag]){
            if let index = self.arrSelectedRecords.index(of: arrId[sender.tag]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(arrId[sender.tag])
        }
        print("Selected id >> ",self.arrSelectedRecords)
        self.tblProspectList.reloadData()
        
        showHideMoveDeleteButtons()
    }
    
    func showHideMoveDeleteButtons(){
        if self.arrSelectedRecords.count > 0{
            self.actionViewHeight.constant = 40.0
        }else{
            self.actionViewHeight.constant = 0.0
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
     //selectOptionsForMoveProspects
    
    @IBAction func actionMoveRecord(_ sender: UIButton) {
        
        if arrSelectedRecords.count > 0 {
            let selected = arrSelectedRecords.joined(separator: ",")
            self.selectOptionsForMoveProspects(prospectId: selected)
        }
    }
    
    @IBAction func actionDeleteMultipleRecord(_ sender: UIButton) {
        if self.arrSelectedRecords.count>0{
            let strSelectedID = self.arrSelectedRecords.joined(separator: ",")
            var msg = ""
            if self.selectAllRecords == true {
                msg = "Do you want to delete all prospects."
            }else{
                msg = "Do you want to delete selected prospects."
            }
            let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if self.selectAllRecords == true {
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.deleteAllRecords()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }else{
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.deleteProspect(prospectId: strSelectedID)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one or more prospect(s) to delete.")
        }
    }
    
    func deleteAllRecords(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contact_flag":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteAllCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                self.showHideMoveDeleteButtons()
                self.selectAllRecords = false
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getProspectData()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
    
    @IBAction func actionEditRecord(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        let selectedID = arrId[sender.tag]
        print("SelectedID >> ",selectedID)
        self.editProspect(prospectId: selectedID, view: sender)
    }
    
    @IBAction func actionDeleteRecord(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        let selectedID = arrId[sender.tag]
        let alertController = UIAlertController(title: "", message: "Do you want to delete this prospect", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.deleteProspect(prospectId: selectedID)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        print("SelectedID >> ",selectedID)
    }
    @IBAction func actionAssignCampaign(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpAssignCampaign") as! PopUpAssignCampaign
        vc.contactId = arrId[sender.tag]
        vc.isGroup = false
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func actionSetTag(_ sender: UIButton) {
        var arrId : [String] = []
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        
        let contact_id = arrId[sender.tag]
        setTagCrm(contact_id:contact_id)
    }
    @IBAction func actionBtnMore(_ sender: Any) {
        self.selectOptions()
    }
    
    
}

// MARK: - LUExpandableTableViewDataSource
extension MyProspectVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        if isFilter {
           return self.arrFirstNameSearch.count
        }else { return self.arrFirstName.count }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblProspectList.dequeueReusableCell(withIdentifier: "CrmCell") as? MyCrmCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        var category = ""
        
        cell.btnEdit.setImage(#imageLiteral(resourceName: "edit_black"), for: .normal)
        cell.btnDelete.setImage(#imageLiteral(resourceName: "delete_black"), for: .normal)
        cell.btnAssignCampaign.setImage(#imageLiteral(resourceName: "campain_black"), for: .normal)
        
        cell.btnTag.tag = indexPath.section
        cell.btnEdit.tag = indexPath.section
        cell.btnDelete.tag = indexPath.section
        cell.btnAssignCampaign.tag = indexPath.section
        
        if isFilter {
            cell.selectionStyle = .none
           
            cell.lblEmail.text = "Email : \(self.arrEmailSearch[indexPath.section])";
            cell.lblPhone.text = "Phone : \(self.arrPhoneSearch[indexPath.section])";
            cell.lblTag.text = "Tag : ";
            
            category = self.arrCategorySearch[indexPath.section]
            
            if self.arrEmailSearch[indexPath.section] == "" {
                cell.btnAssignCampaign.isHidden = true
            }else{
                cell.btnAssignCampaign.isHidden = false
            }
            
        }else{
            cell.selectionStyle = .none
            cell.lblEmail.text = "Email : \(self.arrEmail[indexPath.section])";
            cell.lblPhone.text = "Phone : \(self.arrPhone[indexPath.section])";
           
            cell.lblTag.text = "Tag : ";
            
            category = self.arrCategory[indexPath.section]
            
            if self.arrEmail[indexPath.section] == "" {
                cell.btnAssignCampaign.isHidden = true
            }else{
                cell.btnAssignCampaign.isHidden = false
            }
            
        }
        
        if category != "" {
            cell.btnTag.setTitle(category, for: .normal)
            if category == "Green Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "greenApple"), for: .normal)
                cell.btnTag.setTitleColor(colorGreenApple, for: .normal)
                cell.btnTag.layer.borderColor = colorGreenApple.cgColor
            }else if category == "Red Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "redApple"), for: .normal)
                cell.btnTag.setTitleColor(colorRedApple, for: .normal)
                cell.btnTag.layer.borderColor = colorRedApple.cgColor
            }else if category == "Brown Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "brownApple"), for: .normal)
                cell.btnTag.setTitleColor(colorBrownApple, for: .normal)
                cell.btnTag.layer.borderColor = colorBrownApple.cgColor
            }else if category == "Rotten Apple"{
                cell.btnTag.setImage(#imageLiteral(resourceName: "rottenApple"), for: .normal)
                cell.btnTag.setTitleColor(colorRottenApple, for: .normal)
                cell.btnTag.layer.borderColor = colorRottenApple.cgColor
            }
        }else{
            cell.btnTag.setTitle(" Add Tag ", for: .normal)
            cell.btnTag.setTitleColor(UIColor.black, for: .normal)
            cell.btnTag.setImage(#imageLiteral(resourceName: "40x40_ios"), for: .normal)
            cell.btnTag.layer.borderColor = APPGRAYCOLOR.cgColor
        }
    
        
        
        cell.btnTag.addTarget(self, action: #selector(actionSetTag), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(actionEditRecord), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteRecord), for: .touchUpInside)
        cell.btnAssignCampaign.addTarget(self, action: #selector(actionAssignCampaign), for: .touchUpInside)
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = tblProspectList.dequeueReusableHeaderFooterView(withIdentifier: "MyCrmHeader") as? CrmHeaderCell else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        var fname = ""
        var lname = ""
        if isFilter {
            fname = self.arrFirstNameSearch[section]
            lname = self.arrLastNameSearch[section]
            if self.arrSelectedRecords.contains(self.arrProspectIdSearch[section]){
                sectionHeader.selectRecordButton.isSelected = true
            }else{
                sectionHeader.selectRecordButton.isSelected = false
            }
        }else{
            fname = self.arrFirstName[section]
            lname = self.arrLastName[section]
            if self.arrSelectedRecords.contains(self.arrProspectId[section]){
                sectionHeader.selectRecordButton.isSelected = true
            }else{
                sectionHeader.selectRecordButton.isSelected = false
            }
        }
        sectionHeader.label.text = "\(fname) \(lname)"
        
        sectionHeader.selectRecordButton.tag = section
        sectionHeader.selectRecordButton.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        sectionHeader.selectRecordButton.setImage(#imageLiteral(resourceName: "checkbox_ic"), for: .selected)
        sectionHeader.selectRecordButton.addTarget(self, action: #selector(actionSelectRecord), for: .touchUpInside)
        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate

extension MyProspectVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 130 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat { return 44.0 }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        var arrId : [String] = []
        if isFilter {
            arrId = arrProspectIdSearch
        }else{
            arrId = arrProspectId
        }
        print("Did select section header at section \(section)")
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idViewAndEditProspectVC") as! ViewAndEditProspectVC
        vc.contactID = arrId[section]
        vc.isEditable = false
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
       // self.arrSelectedRecords.removeAll()
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
}
extension MyProspectVC {

    func selectOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionImportDevice = UIAlertAction(title: "Import New Device Contact(s)", style: .default)
        {
            UIAlertAction in
            
            let storyboard = UIStoryboard(name: "CRM", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idNewContactListVC") as! NewContactListVC
            vc.contact_flag = "3"
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)

        }
        actionImportDevice.setValue(UIColor.black, forKey: "titleTextColor")
        
        //let image = #imageLiteral(resourceName: "chk")
        let actionImport = UIAlertAction(title: "Import prospect(s) CSV", style: .default)
        {
            UIAlertAction in
              let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
            
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
            
        }
        actionImport.setValue(UIColor.black, forKey: "titleTextColor")
       // actionImport.setValue(image, forKey: "image")
        
        let actionExport = UIAlertAction(title: "Export prospect(s)", style: .default)
        {
            UIAlertAction in
            
            self.prospectCsvArray = []
            for obj in self.arrProspectData {
                self.prospectCsvArray.append(obj as! Dictionary<String, AnyObject>)
            }
            print(self.prospectCsvArray)
            self.createCSV(from: self.prospectCsvArray, crmFlag: "3")
        }
        actionExport.setValue(UIColor.black, forKey: "titleTextColor")
        //actionExport.setValue(image, forKey: "image")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
      
        alert.addAction(actionImportDevice)
        alert.addAction(actionImport)
        alert.addAction(actionExport)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectOptionsForMoveProspects(prospectId: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionImport = UIAlertAction(title: "My Customers", style: .default)
        {
            UIAlertAction in
            self.moveProspect(prospectId: prospectId, crmFlag:  "2")
        }
        actionImport.setValue(UIColor.black, forKey: "titleTextColor")
        let actionExport = UIAlertAction(title: "My Contacts", style: .default)
        {
            UIAlertAction in
            self.moveProspect(prospectId: prospectId, crmFlag:  "1")
        }
        actionExport.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionRecruit = UIAlertAction(title: "My Recruits", style: .default)
        {
            UIAlertAction in
            self.moveProspect(prospectId: prospectId, crmFlag:  "4")
        }
        actionRecruit.setValue(UIColor.black, forKey: "titleTextColor")

        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionImport)
        alert.addAction(actionExport)
        alert.addAction(actionRecruit)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editProspect(prospectId: String, view:UIButton){
        OBJCOM.animateButton(button: view)
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idViewAndEditProspectVC") as! ViewAndEditProspectVC
        vc.modalTransitionStyle = .crossDissolve
        vc.contactID = prospectId
        vc.isEditable = true
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteProspect(prospectId: String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactIds":prospectId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteMultipleRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getProspectData()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func moveProspect(prospectId: String, crmFlag: String){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "contactId":prospectId,
                         "newCrmFlag" : crmFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "moveRowCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getProspectData()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
}

extension MyProspectVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        arrFirstNameSearch.removeAll()
        arrLastNameSearch.removeAll()
        arrMiddleNameSearch.removeAll()
        arrEmailSearch.removeAll()
        arrPhoneSearch.removeAll()
        arrCategorySearch.removeAll()
        arrProspectIdSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrProspectData.count {
                let strfName = arrFirstName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strmName = arrMiddleName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strlName = arrLastName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strEmail = arrEmail[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strPhone = arrPhone[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let strCat = arrCategory[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                if strfName != nil || strmName != nil || strlName != nil || strEmail != nil || strPhone != nil || strCat != nil{
                    arrFirstNameSearch.append(arrFirstName[i])
                    arrMiddleNameSearch.append(arrMiddleName[i])
                    arrLastNameSearch.append(arrLastName[i])
                    arrEmailSearch.append(arrEmail[i])
                    arrPhoneSearch.append(arrPhone[i])
                    arrCategorySearch.append(arrCategory[i])
                    arrProspectIdSearch.append(arrProspectId[i])
                }
            }
        } else {
            isFilter = false
        }
        tblProspectList.reloadData()
    }
}

extension MyProspectVC {
    func setTagCrm(contact_id:String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionGreenApple = UIAlertAction(title: "Green Apple", style: .default)
        {
            UIAlertAction in
            self.apiCallForUpdateTag(tag: "Green Apple", contact_id: contact_id)
        }
        actionGreenApple.setValue(colorGreenApple, forKey: "titleTextColor")
        actionGreenApple.setValue(arrAppleImages[2], forKey: "image")
        
        let actionRedApple = UIAlertAction(title: "Red Apple", style: .default)
        {
            UIAlertAction in
            self.apiCallForUpdateTag(tag: "Red Apple", contact_id: contact_id)
        }
        actionRedApple.setValue(colorRedApple, forKey: "titleTextColor")
        actionRedApple.setValue(arrAppleImages[1], forKey: "image")
        
        let actionBrownApple = UIAlertAction(title: "Brown Apple", style: .default)
        {
            UIAlertAction in
            self.apiCallForUpdateTag(tag: "Brown Apple", contact_id: contact_id)
        }
        actionBrownApple.setValue(colorBrownApple, forKey: "titleTextColor")
        actionBrownApple.setValue(arrAppleImages[3], forKey: "image")
        
        let actionRottenApple = UIAlertAction(title: "Rotten Apple", style: .default)
        {
            UIAlertAction in
            self.apiCallForUpdateTag(tag: "Rotten Apple", contact_id: contact_id)
        }
        actionRottenApple.setValue(colorRottenApple, forKey: "titleTextColor")
        actionRottenApple.setValue(arrAppleImages[4], forKey: "image")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(actionGreenApple)
        alert.addAction(actionRedApple)
        alert.addAction(actionBrownApple)
        alert.addAction(actionRottenApple)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func apiCallForUpdateTag(tag:String, contact_id:String){
        let dictParam = ["contact_id": contact_id,
                         "contact_category":tag]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateTag", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getProspectData()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
        
        print(url.lastPathComponent)
        print(url.pathExtension)
        
        if controller.documentPickerMode == .import {
            arrImpFname = [];
            //   arrImpMiddle = [];
            arrImpLname = [];
            arrImpEmail = [];
            arrImpPhone = [];
            
            let content = try? String(contentsOf: url, encoding: .ascii)
            var rows = content?.components(separatedBy: "\n")
            
            var columnsTitle = rows![0].components(separatedBy: ",")
            if columnsTitle.count >= 4 {
                var fn = columnsTitle[0]
                // let mn = columnsTitle[1]
                var ln = columnsTitle[1]
                var em = columnsTitle[2]
                var ph = columnsTitle[3]
                
                fn = fn.replacingOccurrences(of: "\r", with: "")
                ln = ln.replacingOccurrences(of: "\r", with: "")
                em = em.replacingOccurrences(of: "\r", with: "")
                ph = ph.replacingOccurrences(of: "\r", with: "")
                
                if fn == "fname" && ln == "lname" && em == "email" && ph == "phone"{
                    for i in 1..<(rows?.count)!-1 {
                        var columns = rows![i].components(separatedBy: ",")
                        if columns.count > 0{
                            arrImpFname.append(columns[0])
                            // arrImpMiddle.append(columns[1])
                            arrImpLname.append(columns[1])
                            arrImpEmail.append(columns[2])
                            arrImpPhone.append(columns[3])
                        }
                    }
                    var importArray = [AnyObject]()
                    for i in 0..<arrImpFname.count {
                        let tempDict = ["fname": arrImpFname[i],
                                        "lname": arrImpLname[i],
                                        "email": arrImpEmail[i],
                                        "phone": arrImpPhone[i]]
                        importArray.append(tempDict as AnyObject)
                    }
                    if importArray.count > 0 {
                        self.importCSVAPIProspects(impArray: importArray, crmFlag: "3")
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
                }
            }else{
                OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
            }
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
    }
    
    func importCSVAPIProspects(impArray : [AnyObject], crmFlag : String){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "crmFlag":"3",
                         "csvDetails": impArray] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "importCsvCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
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
                        self.getProspectData()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
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

extension UIViewController {
    func createCSV(from recArray:[Dictionary<String, AnyObject>], crmFlag : String) {
        
        var csvString = "fname, middle, lname, email, phone\n"
        
       
        for dct in recArray {
            csvString = csvString.appending("\n\(String(describing: dct["contact_fname"]!)), \(String(describing: dct["contact_middle"]!)), \(String(describing: dct["contact_lname"]!)), \(String(describing: dct["contact_email"]!)), \(String(describing: dct["contact_phone"]!))")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("csvProspect.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            //  let userInfo = UserDefaults.standard.value(forKey: "USERINFO")
            self.exportCSVAPI(crmFlag : crmFlag)
            
        } catch {
            print("error creating file")
        }
        
    }
    
    func exportCSVAPI(crmFlag : String){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "crmFlag":crmFlag,
                         "csvFileContent": ""]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "sendCsvbyEmailCrm", param:dictParam as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
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

