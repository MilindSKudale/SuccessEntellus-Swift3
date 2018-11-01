//
//  AddGroupVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddGroupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var txtGrpName : SkyFloatingLabelTextField!
    @IBOutlet var viewSearch : UIView!
    @IBOutlet var selectionView : UIView!
    @IBOutlet var importCsvView : UIView!
    @IBOutlet var btnContact : UIButton!
    @IBOutlet var btnProspect : UIButton!
    @IBOutlet var btnCustomer : UIButton!
    @IBOutlet var btnRecruit : UIButton!
    
    @IBOutlet var btnFromSystemContact : UIButton!
    @IBOutlet var btnImportCsvContact : UIButton!
    @IBOutlet var btnSelectCsvFile : UIButton!
    @IBOutlet var btnImportCsvFile : UIButton!
    @IBOutlet var lblCsvFile : UILabel!
    var importArray = [AnyObject]()
    
    var isFilter = false;
    var isImportCsv = false
    
    var mainArrayList = [String]()
    var mainArrayID = [String]()
    var mainArrayListSearch = [String]()
    var mainArrayIDSearch = [String]()
    var arrContactList = [String]()
    var arrProspectList = [String]()
    var arrCustomerList = [String]()
    var arrRecruitList = [String]()
    var arrContactID = [String]()
    var arrProspectID = [String]()
    var arrCustomerID = [String]()
    var arrRecruitID = [String]()
    var arrSelectedIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        self.tblList.tableFooterView = UIView()
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        
        isFilter = false;
        self.txtGrpName.text = ""
        self.arrSelectedIDs = []
        self.btnFromSystemContact.isSelected = true
        self.btnImportCsvContact.isSelected = false
        self.selectionView.isHidden = false
        self.importCsvView.isHidden = true
        self.isImportCsv = false
        self.lblCsvFile.text = ""
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getContactList()
            self.getProspectList()
            self.getCustomerList()
            self.getRecruitList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
    }
    
//    func refreshUIWithData(){
//       // getGroupData()
//        if OBJCOM.isConnectedToNetwork(){
//            OBJCOM.setLoader()
//            self.getContactList()
//            self.getProspectList()
//            self.getCustomerList()
//            self.getRecruitList()
//        }else{
//            OBJCOM.NoInternetConnectionCall()
//        }
//
//        self.btnFromSystemContact.isSelected = true
//        self.btnImportCsvContact.isSelected = false
//        self.selectionView.isHidden = false
//        self.importCsvView.isHidden = true
//
//        self.setSelected(self.btnProspect)
//        self.setDeSelected(self.btnContact)
//        self.setDeSelected(self.btnCustomer)
//        self.setDeSelected(self.btnRecruit)
//
//        mainArrayList = arrProspectList
//        mainArrayID = arrProspectID
//        isFilter = false
//        txtSearch.text = ""
//        self.isImportCsv = true
//        txtSearch.resignFirstResponder()
//        self.tblList.reloadData()
//    }
    
    func designUI(){
        selectionView.layer.borderColor = APPGRAYCOLOR.cgColor
        selectionView.layer.borderWidth = 1.0
        importCsvView.layer.borderColor = APPGRAYCOLOR.cgColor
        importCsvView.layer.borderWidth = 1.0
        
        self.btnSelectCsvFile.layer.cornerRadius = 5.0
        self.btnSelectCsvFile.clipsToBounds = true
        self.btnImportCsvFile.layer.cornerRadius = 5.0
        self.btnImportCsvFile.clipsToBounds = true
        self.btnImportCsvFile.isEnabled = false
        viewSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        viewSearch.layer.borderWidth = 1.0
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
    
    @IBAction func actionClose (_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddGroupVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.mainArrayListSearch.count
        }else { return mainArrayList.count }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "EditCell") as! EditGroupCell
        
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
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        self.tblList.reloadData()
    }
}

extension AddGroupVC {
    
    @IBAction func actionShowContactList (_ sender:UIButton){
        self.setSelected(btnContact)
        self.setDeSelected(btnProspect)
        self.setDeSelected(btnCustomer)
        self.setDeSelected(btnRecruit)
        mainArrayList = arrContactList
        mainArrayID = arrContactID
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
    
    @IBAction func actionAddGroup (_ sender:UIButton){
        if txtGrpName.text == ""{
            OBJCOM.setAlert(_title: "", message: "Please enter group name.")
        } else if self.arrSelectedIDs.count == 0 && self.isImportCsv == false {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one group member.")
        }
        else{
            self.addGroup()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension AddGroupVC {
    
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
            //    if self.isImportCsv == true {
            //        self.mainArrayList = self.arrProspectList
            //        self.mainArrayID = self.arrProspectID
            //        self.tblList.reloadData()
            //        self.isImportCsv = false
            //    }
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
    
    func addGroup(){
        let strSelect = self.arrSelectedIDs.joined(separator: ",")
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "group_name":txtGrpName.text!,
                         "group_contact_id": strSelect] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let groupId = "\(JsonDict!["group_id"] ?? "")"
                let groupName = "\(JsonDict!["group_name"] ?? "")"
                
                if self.importArray.count > 0 && groupId != ""{
                    self.importCSVgroup(impArray: self.importArray, crmFlag: "3", grpId: groupId, grpName: groupName)
                }else{
                    let result = JsonDict!["result"] as? String ?? ""
                    print(result)
                    let alertController = UIAlertController(title: "", message: "Group '\(groupName)' created successfully.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.dismiss(animated: true, completion: nil)
    
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
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

extension AddGroupVC {
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
}

extension AddGroupVC : UIDocumentPickerDelegate, UIDocumentMenuDelegate  {
    @IBAction func actionSelectSystemContacts(_ btn : UIButton){
        self.btnFromSystemContact.isSelected = true
        self.btnImportCsvContact.isSelected = false
        self.selectionView.isHidden = false
        self.importCsvView.isHidden = true
    }
    
    @IBAction func actionImportCsvContacts(_ btn : UIButton){
        self.btnFromSystemContact.isSelected = false
        self.btnImportCsvContact.isSelected = true
        self.selectionView.isHidden = true
        self.importCsvView.isHidden = false
    }
    
    @IBAction func actionSelectCsvFile(_ btn : UIButton){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func actionImportCsvFile(_ btn : UIButton){
//        if importArray.count > 0 && groupId != ""{
//            self.importCSVgroup(impArray: importArray, crmFlag: "3", grpId: groupId)
//        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
        
        print(url.lastPathComponent)
        print(url.pathExtension)
        
        if controller.documentPickerMode == .import {
            var arrImpFname = [String]();
            // var arrImpMiddle = [String]();
            var arrImpLname = [String]();
            var arrImpEmail = [String]();
            var arrImpPhone = [String]();
            
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
                    
                    for i in 0..<arrImpFname.count {
                        let tempDict = ["fname": arrImpFname[i],
                                        "lname": arrImpLname[i],
                                        "email": arrImpEmail[i],
                                        "phone": arrImpPhone[i]]
                        importArray.append(tempDict as AnyObject)
                    }
                    self.btnImportCsvFile.isEnabled = true
                    self.lblCsvFile.text = " \(url.lastPathComponent)"
                    self.lblCsvFile.addImageWith(name: "ic_file", behindText: false)
                    if self.importArray.count > 0 {
                        self.isImportCsv = true
                    }else{
                        OBJCOM.setAlert(_title: "", message: "No records available in CSV file.")
                        return
                    }
                }else{
                    
                    OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
                    return
                }
            }else{
                OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
                return
            }
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
    }
    
    func importCSVgroup(impArray : [AnyObject], crmFlag : String, grpId: String, grpName:String) {
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "crmFlag":crmFlag,
                         "csvDetails": impArray,
                         "groupId":grpId] as [String : Any]
        
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
                let alertController = UIAlertController(title: "", message: "'\(grpName)' created successfully. All entries in CSV file will be visible in My Prospects.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                    //self.refreshUIWithData()
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


