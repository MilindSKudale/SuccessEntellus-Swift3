//
//  ScrachPadDashboardVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit


class ScrachPadDashboardVC: SliderVC, UITextFieldDelegate {

    @IBOutlet weak var notesView : UIView!
    @IBOutlet weak var btnTakeNote : UIButton!
    @IBOutlet weak var tblNotes : UITableView!
    @IBOutlet weak var txtSearch : UITextField!
    
    var arrTitle = [String]()
    var arrNotesId = [String]()
    var arrCreatedDate = [String]()
    var arrReminderDate = [String]()
    var arrNoteText = [String]()
    var arrNoteColor = [String]()
    var arrNotesData = [AnyObject]()
    
    var arrCreatedDateSearch = [String]()
    var arrReminderDateSearch = [String]()
    var arrNoteTextSearch = [String]()
    var arrNotesIdSearch = [String]()
    var arrNotesColorSearch = [String]()
    var arrNotesDataSearch = [AnyObject]()
    
    var isFilter = false;
    var badgeCount = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scratch pad"
        designUI()
    }
    
    func designUI(){
        btnTakeNote.layer.cornerRadius = btnTakeNote.frame.height/2
        btnTakeNote.layer.borderWidth = 0.5
        btnTakeNote.layer.borderColor = UIColor.darkGray.cgColor
        btnTakeNote.clipsToBounds = true
        
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
        
        self.tblNotes.tableFooterView = UIView()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        self.badgeCount = "0"
        setUpBadgeCountAndBarButton()
    }
    
    @IBAction func actionTakeANote(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCreateNoteView") as! CreateNoteView
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func UpdateScratchPadList(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
}

extension ScrachPadDashboardVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.arrNoteTextSearch.count
        }else { return self.arrNotesData.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblNotes.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoteCell
        
        if isFilter {
            cell.lblCreatedDate.text = "Created on : \(self.arrCreatedDateSearch[indexPath.row])"
            cell.lblReminderDate.text = self.arrReminderDate[indexPath.row]
            
//            let str = self.arrNoteTextSearch[indexPath.row]
//            if str.count > 130 {
//
//                cell.lblNotesText.text = substring(string: str, fromIndex: 0, toIndex: 130)
//                let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 13.0)
//                DispatchQueue.main.async {
//                    cell.lblNotesText.addTrailing(with: "... ", moreText: "View Details", moreTextFont: readmoreFont!, moreTextColor: UIColor.blue)
//                }
//            }else{
            let str = self.arrNoteTextSearch[indexPath.row]
                cell.lblNotesText.text = str.htmlToString
//            }
            
            let bgColor = self.arrNotesColorSearch[indexPath.row]
            if bgColor == "" || bgColor == "white" {
                cell.viewNotes.layer.borderWidth = 0.3
                cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
            }
            cell.viewNotes.backgroundColor = getColor(bgColor)
        }else{
            cell.lblCreatedDate.text = "Created on : \(self.arrCreatedDate[indexPath.row])"
            cell.lblReminderDate.text = self.arrReminderDate[indexPath.row]
            
//            let str = self.arrNoteText[indexPath.row]
//            if str.count > 130 {
//
//                cell.lblNotesText.text = substring(string: str, fromIndex: 0, toIndex: 130)
//                let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 13.0)
//                DispatchQueue.main.async {
//                    cell.lblNotesText.addTrailing(with: "... ", moreText: "View Details", moreTextFont: readmoreFont!, moreTextColor: UIColor.blue)
//                }
//            }else{
              //  cell.lblNotesText.text = self.arrNoteText[indexPath.row]
            
            let str = self.arrNoteText[indexPath.row]
            cell.lblNotesText.text = str.htmlToString
//            }
            
            let bgColor = self.arrNoteColor[indexPath.row]
            if bgColor == "" || bgColor == "white" {
                cell.viewNotes.layer.borderWidth = 0.3
                cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
            }
            cell.viewNotes.backgroundColor = getColor(bgColor)
        }
        
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        cell.btnViewNotes.tag = indexPath.row
        
        cell.btnViewNotes.addTarget(self, action: #selector(viewNote(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(deleteNote(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editNote(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func getColor(_ color:String) -> UIColor {
        
        if color == "blue" {
            return UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0)
        }else if color == "pink" {
            return UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0)
        }else if color == "green" {
            return UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0)
        }else if color == "orange" {
            return UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0)
        }else if color == "violet" {
            return UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0)
        }else if color == "white"{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }else{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }
        
        
    }
    
    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count {
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        }else{
            return nil
        }
    }
}

extension ScrachPadDashboardVC  {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getAllScratchDetails", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrTitle = []
            self.arrNotesId = []
            self.arrCreatedDate = []
            self.arrNoteText = []
            self.arrNoteColor = []
            self.arrReminderDate = []
            self.arrNotesData = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrNotesData = JsonDict!["result"] as! [AnyObject]
                self.badgeCount = JsonDict!["notificationCnt"] as? String ?? "0"
                self.setUpBadgeCountAndBarButton()
                if self.arrNotesData.count > 0 {
                    self.arrTitle = self.arrNotesData.compactMap { $0["scratchNoteTitle"] as? String }
                    self.arrNotesId = self.arrNotesData.compactMap { $0["scratchNoteId"] as? String }
                    self.arrCreatedDate = self.arrNotesData.compactMap { $0["scratchNoteCreatedDate"] as? String }
                    self.arrNoteText = self.arrNotesData.compactMap { $0["scratchNoteText"] as? String }
                    self.arrNoteColor = self.arrNotesData.compactMap { $0["scratchNoteColor"] as? String }
                    self.arrReminderDate = self.arrNotesData.compactMap { $0["scratchNoteReminderDate"] as? String }
                }
                
                self.tblNotes.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblNotes.reloadData()
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    @objc func viewNote(_ sender: UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }

        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idViewNoteDetails") as! ViewNoteDetails
        vc.noteId = arrId[sender.tag]
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: true, completion: nil)

    }
    
    @objc func editNote(_ sender: UIButton){
        
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditNoteDetailsVC") as! EditNoteDetailsVC
        vc.noteId = arrId[sender.tag]
        vc.isView = false
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteNote(_ sender: UIButton){
        var arrId : [String] = []
        if isFilter {
            arrId = arrNotesIdSearch
        }else{
            arrId = arrNotesId
        }
        
        let alertController = UIAlertController(title: "", message: "Do you want to delete this note", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.deleteSelectedNotes(arrId[sender.tag])
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
    
    func deleteSelectedNotes(_ noteId : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
                
            }else{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result as! String)
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getDataFromServer()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        };
    }
}


extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedStringKey.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedStringKey.font: moreTextFont, NSAttributedStringKey.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedStringKey : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension ScrachPadDashboardVC {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        arrCreatedDateSearch.removeAll()
        arrReminderDateSearch.removeAll()
        arrNoteTextSearch.removeAll()
        arrNotesIdSearch.removeAll()
        arrNotesColorSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrNotesData.count {
                let nText = arrNoteText[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let createDate = arrCreatedDate[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                let remindDate = arrReminderDate[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                if nText != nil || createDate != nil || remindDate != nil {
                    arrNoteTextSearch.append(arrNoteText[i])
                    arrCreatedDateSearch.append(arrCreatedDate[i])
                    arrReminderDateSearch.append(arrReminderDate[i])
                    arrNotesIdSearch.append(arrNotesId[i])
                    arrNotesColorSearch.append(arrNoteColor[i])
                }
            }
        } else {
            isFilter = false
        }
        tblNotes.reloadData()
    }
    
    func setUpBadgeCountAndBarButton() {
        // badge label
        
        let label = UILabel(frame: CGRect(x: 16, y: -05, width: 22, height: 22))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.backgroundColor = .red
        label.text = self.badgeCount
        
        // button
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "bell"), for: .normal)
        rightButton.addTarget(self, action: #selector(notificationBarButtonClick), for: .touchUpInside)
        if self.badgeCount != "0" && self.badgeCount != "" {
            rightButton.addSubview(label)
        }
        // Bar button item
        let rightBarButtomItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButtomItem
    }
    
    @objc func notificationBarButtonClick(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idScratchNotificationVC") as! ScratchNotificationVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
}
