//
//  MyGroupVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

class MyGroupVC: SliderVC, UITextFieldDelegate {
    
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var tblGroupList : LUExpandableTableView!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet weak var actionViewHeight: NSLayoutConstraint!
    @IBOutlet var noRecView : UIView!
    
    var isFilter = false;
    let cellReuseIdentifier = "GroupCell"
    let sectionHeaderReuseIdentifier = "MyCrmHeader"
    
    var arrGroupData = [AnyObject]()
    var arrGroupName = [String]()
    var arrGroupId = [String]()
    var arrGroupType = [AnyObject]()
    var arrGroupMembers = [AnyObject]()
    
    var arrGroupNameSearch = [String]()
    var arrGroupTypeSearch = [AnyObject]()
    var arrGroupMembersSearch = [AnyObject]()
    var arrGroupIdSearch = [String]()
    
    var arrSelectedRecords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Groups"
        self.noRecView.isHidden = true
        
        tblGroupList.register(MyGroupCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tblGroupList.register(UINib(nibName: "CrmHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        self.tblGroupList.expandableTableViewDataSource = self
        self.tblGroupList.expandableTableViewDelegate = self
        
        tblGroupList.tableFooterView = UIView()
        
        isFilter = false;
        
        actionViewHeight.constant = 0.0
        btnDelete.layer.cornerRadius = 5.0
        btnDelete.clipsToBounds = true
        
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
        
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = APPORANGECOLOR
        actionButton.addItem(title: "", image: #imageLiteral(resourceName: "ic_add_white")) { item in
            print("Action Float button")
            OBJCOM.animateButton(button: actionButton)
            let storyboard = UIStoryboard(name: "CRM", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idAddGroupVC")
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
        }
        actionButton.display(inViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getGroupData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getGroupData(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getListGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrGroupData = JsonDict!["result"] as! [AnyObject]
                self.arrGroupName = []
                self.arrGroupType = []
                self.arrGroupMembers = []
                self.arrGroupId = []
                self.arrSelectedRecords = []
                for obj in self.arrGroupData {
                    self.arrGroupName.append(obj.value(forKey: "group_name") as! String)
                    self.arrGroupType.append(obj.value(forKey: "campaign_name") as AnyObject)
                    self.arrGroupMembers.append(obj.value(forKey: "group_member_names") as AnyObject)
                    self.arrGroupId.append(obj.value(forKey: "group_id") as! String)
                }
                if self.arrGroupName.count > 0 {
                    self.noRecView.isHidden = true
                }
                
                self.showHideMoveDeleteButtons()
                self.tblGroupList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noRecView.isHidden = false
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionSelectAll(_ sender: UIButton) {
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        
        if !sender.isSelected{
            self.arrSelectedRecords.removeAll()
            for id in arrId {
                self.arrSelectedRecords.append(id)
            }
            sender.isSelected = true
        }else{
            self.arrSelectedRecords.removeAll()
            sender.isSelected = false
        }
        self.tblGroupList.reloadData()
        showHideMoveDeleteButtons()
        print("Selected id >> ",self.arrSelectedRecords)
    }
    
    @IBAction func actionSelectRecord(_ sender: UIButton) {
        view.layoutIfNeeded()
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        
        if self.arrSelectedRecords.contains(arrId[sender.tag]){
            if let index = self.arrSelectedRecords.index(of: arrId[sender.tag]) {
                self.arrSelectedRecords.remove(at: index)
            }
        }else{
            self.arrSelectedRecords.append(arrId[sender.tag])
        }
        print("Selected id >> ",self.arrSelectedRecords)
        self.tblGroupList.reloadData()
        
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
    
    @IBAction func actionDeleteMultipleRecord(_ sender: UIButton) {
        if self.arrSelectedRecords.count>0{
            let strSelectedID = self.arrSelectedRecords.joined(separator: ",")
            let alertController = UIAlertController(title: "", message: "Do you want to delete selected Group(s)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteGroup(GroupId: strSelectedID)
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "", message: "Please select atleast one or more Group(s) to delete.")
        }
    }
    
    @IBAction func actionEditRecord(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        let selectedID = arrId[sender.tag]
        print("SelectedID >> ",selectedID)
        self.editGroup(GroupId: selectedID)
    }
    
    @IBAction func actionDeleteRecord(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        var arrNm = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
            arrNm = arrGroupNameSearch
        }else{
            arrId = arrGroupId
            arrNm = arrGroupName
        }
        let selectedID = arrId[sender.tag]
        let alertController = UIAlertController(title: "", message: "Do you want to delete '\(arrNm[sender.tag])' group", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.deleteGroup(GroupId: selectedID)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func actionAssignCampaign(_ sender: UIButton) {
        self.arrSelectedRecords.removeAll()
        var arrId = [String]()
        var arrGName = [String]()
        
        if isFilter {
            arrId = arrGroupIdSearch
            arrGName = self.arrGroupNameSearch
        }else{
            arrId = arrGroupId
            arrGName = self.arrGroupName
        }
        
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idPopUpAssignCampaign") as! PopUpAssignCampaign
        vc.contactId = arrId[sender.tag]
        vc.contactName = "\(arrGName[sender.tag])"
        vc.isGroup = true
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}

extension MyGroupVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        if isFilter {
            return self.arrGroupIdSearch.count
        }else { return self.arrGroupId.count }
       
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblGroupList.dequeueReusableCell(withIdentifier: "GroupCell") as? MyGroupCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }

        if isFilter {
          //  let grType : [String] = self.arrGroupTypeSearch[indexPath.section] as! [String]
            let grTypeVal = self.arrGroupTypeSearch[indexPath.section] as! String
//            for i in 0..<grType.count {
//                if grType[i] != "" {
//                    if i == grType.count - 1 {
//                        grTypeVal = grTypeVal.appending("\(grType[i])")
//                    }else{
//                        grTypeVal = grTypeVal.appending("\(grType[i]), ")
//                    }
//                }
//            }
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Assigned email campaigns : ")
                .normal(grTypeVal)
            
            cell.lblGrType.attributedText = formattedString
            cell.lblGrType.lineBreakMode = .byTruncatingTail
            cell.lblGrType.numberOfLines = 2
            
            let grMemb : [String] = self.arrGroupMembersSearch[indexPath.section] as! [String]
            var grMembVal = ""
            for i in 0..<grMemb.count {
                if grMemb[i] != "" {
                    if i == grMemb.count - 1 {
                        grMembVal = grMembVal.appending("\(grMemb[i])")
                    }else{
                        grMembVal = grMembVal.appending("\(grMemb[i]), ")
                    }
                }
            }
            
            let formattedStr = NSMutableAttributedString()
            formattedStr
                .bold("Group members : ")
                .normal(grMembVal)
            
            cell.lblGrMembers.attributedText = formattedStr
            cell.lblGrMembers.lineBreakMode = .byTruncatingTail
            cell.lblGrMembers.numberOfLines = 2
        }else{
           // let grType : [String] = self.arrGroupType[indexPath.section] as! [String]
            let grTypeVal = self.arrGroupType[indexPath.section] as? String ?? ""
//            let arrGrVal = grTypeVal.components(separatedBy: ",")
//            for i in 0..<arrGrVal.count {
//                if arrGrVal[i] != "" {
//                    if i == arrGrVal.count - 1 {
//                        grTypeVal = grTypeVal.appending("\(grType[i])")
//                    }else{
//                        grTypeVal = grTypeVal.appending("\(grType[i]), ")
//                    }
//                }
//            }
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("Assigned email campaigns : ")
                .normal(grTypeVal)

            cell.lblGrType.attributedText = formattedString
            cell.lblGrType.lineBreakMode  = .byTruncatingTail
            cell.lblGrType.numberOfLines  = 2
            
            let grMemb : [String] = self.arrGroupMembers[indexPath.section] as! [String]
            var grMembVal = ""
            for i in 0..<grMemb.count {
                if grMemb[i] != "" {
                    if i == grMemb.count - 1 {
                        grMembVal = grMembVal.appending("\(grMemb[i])")
                    }else{
                        grMembVal = grMembVal.appending("\(grMemb[i]), ")
                    }
                }
            }
            let formattedStr = NSMutableAttributedString()
            formattedStr
                .bold("Group members : ")
                .normal(grMembVal)
            
            cell.lblGrMembers.attributedText = formattedStr
            cell.lblGrMembers.lineBreakMode  = .byTruncatingTail
            cell.lblGrMembers.numberOfLines  = 2
        }
    
        cell.btnViewMore.setTitle("View More", for: .normal)
        cell.btnViewMore.setTitleColor(UIColor.red, for: .normal)
        cell.lblViewMore.backgroundColor = UIColor.red
        cell.btnEdit.setImage(#imageLiteral(resourceName: "edit_black"), for: .normal)
        cell.btnDelete.setImage(#imageLiteral(resourceName: "delete_black"), for: .normal)
        cell.btnAssignCampaign.setImage(#imageLiteral(resourceName: "campain_black"), for: .normal)

        cell.btnViewMore.tag = indexPath.section
        cell.btnEdit.tag = indexPath.section
        cell.btnDelete.tag = indexPath.section
        cell.btnAssignCampaign.tag = indexPath.section

        cell.btnEdit.addTarget(self, action: #selector(actionEditRecord), for: .touchUpInside)
        cell.btnViewMore.addTarget(self, action: #selector(viewGroupDetails(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteRecord), for: .touchUpInside)
        cell.btnAssignCampaign.addTarget(self, action: #selector(actionAssignCampaign), for: .touchUpInside)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = tblGroupList.dequeueReusableHeaderFooterView(withIdentifier: "MyCrmHeader") as? CrmHeaderCell else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }

        if isFilter {
            sectionHeader.label.text = self.arrGroupNameSearch[section]
            if self.arrSelectedRecords.contains(self.arrGroupIdSearch[section]){
                sectionHeader.selectRecordButton.isSelected = true
            }else{
                sectionHeader.selectRecordButton.isSelected = false
            }
        }else{
           sectionHeader.label.text = self.arrGroupName[section]
            if self.arrSelectedRecords.contains(self.arrGroupId[section]){
                sectionHeader.selectRecordButton.isSelected = true
            }else{
                sectionHeader.selectRecordButton.isSelected = false
            }
        }
      
        sectionHeader.selectRecordButton.tag = section
        sectionHeader.selectRecordButton.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        sectionHeader.selectRecordButton.setImage(#imageLiteral(resourceName: "checkbox_ic"), for: .selected)
        sectionHeader.selectRecordButton.addTarget(self, action: #selector(actionSelectRecord), for: .touchUpInside)
        
        return sectionHeader

    }
}

// MARK: - LUExpandableTableViewDelegate

extension MyGroupVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 180 }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat { return 44.0 }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        print("Did select section header at section \(section)")
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idGroupDetailsVC") as! GroupDetailsVC
        vc.groupId = arrId[section]
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
}

extension MyGroupVC {
    
    @objc func viewGroupDetails(_ sender:UIButton){
        var arrId = [String]()
        if isFilter {
            arrId = arrGroupIdSearch
        }else{
            arrId = arrGroupId
        }
        print("Did select section header at section \(sender.tag)")
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idGroupDetailsVC") as! GroupDetailsVC
        vc.groupId = arrId[sender.tag]
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    func editGroup(GroupId: String){
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditGroupVC") as! EditGroupVC
        vc.groupId = GroupId
        vc.isEdit = true
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    func deleteGroup(GroupId: String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "groupIds":GroupId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteMultipleRowGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.getGroupData()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension MyGroupVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        arrGroupNameSearch.removeAll()
        arrGroupMembersSearch.removeAll()
        arrGroupIdSearch.removeAll()
        arrGroupTypeSearch.removeAll()
        
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrGroupData.count {
                let strGName = arrGroupName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if strGName != nil {
                    arrGroupNameSearch.append(arrGroupName[i])
                    arrGroupMembersSearch.append(arrGroupMembers[i])
                    arrGroupIdSearch.append(arrGroupId[i])
                    arrGroupTypeSearch.append(arrGroupType[i])
                }
            }
        } else {
            isFilter = false
        }
        tblGroupList.reloadData()
    }
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
