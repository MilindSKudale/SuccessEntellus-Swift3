//
//  EditTextCampTemplate.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import McPicker
import Alamofire
import SwiftyJSON

class EditTextCampTemplate: UIViewController, TagListViewDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var txtTemplatename : SkyFloatingLabelTextField!
    @IBOutlet var lblTxtMessage : UITextView!
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var btnAddFiles : UIButton!
    //@IBOutlet var btnSetInterval : UIButton!
    
    @IBOutlet var btnAddUrls : UIButton!
    @IBOutlet var vwAddUrls : TagListView!
    var txtAddUrl: UITextField?

    var templateData = [String:Any]()
    var arrAttachUrlSaved = [URL]()
    var arrAttachSaved = [String]()
    
    var arrFileName = [String]()
    var arrFile = [URL]()
    var arrFileId = [String]()
    var arrAttachFileId = [String]()
    var arrAttachSavedFileId = [String]()
    
    var arrIntervalType = [String]()
    var arrIntervalValue = [String]()
    var attachFileUrl : URL!
    var arrlinks = [[String:String]]()
    
    var templateId = ""
    var CampaignId = ""

    var timeIntervalValue = "0"
    var timeIntervalType = "Select"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    
    @IBOutlet var btnImmediate: UIButton!
    @IBOutlet var btnSchedule: UIButton!
    @IBOutlet var btnReapeat: UIButton!
    @IBOutlet var viewSchedule: UIView!
    @IBOutlet var viewReapeat: UIView!
    @IBOutlet var viewScheduleHeight: NSLayoutConstraint!
    @IBOutlet var viewReapeatHeight: NSLayoutConstraint!
    @IBOutlet var btnDaysCollection: [UIButton]!
    @IBOutlet var txtRepeatWeek: UITextField!
    @IBOutlet weak var stepperRepeatOccurance: PKYStepper!
    @IBOutlet var btnIntervalType: UIButton!
    @IBOutlet var txtInterval: UITextField!
    
    var arrSelectedDays = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        lblAttachFiles.text = "Attach files :"
        lblAttachFiles.addImageWith(image: #imageLiteral(resourceName: "ic_attach"), behindText: false)
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        
        btnUpdate.layer.cornerRadius = 5.0
        btnUpdate.clipsToBounds = true
        
        btnAddFiles.layer.cornerRadius = 5.0
        btnAddFiles.layer.borderColor = APPGRAYCOLOR.cgColor
        btnAddFiles.layer.borderWidth = 0.75
        btnAddFiles.clipsToBounds = true
        
        btnAddUrls.layer.cornerRadius = 5.0
        btnAddUrls.layer.borderColor = APPGRAYCOLOR.cgColor
        btnAddUrls.layer.borderWidth = 0.75
        btnAddUrls.clipsToBounds = true
    
        vwAddUrls.delegate = self
        vwAddUrls.textFont = UIFont.systemFont(ofSize: 13)
        vwAddUrls.alignment = .left
        vwAddUrls.enableRemoveButton = false
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
        vwAttachFiles.alignment = .left
        
        OBJCOM.setStepperValues(stepper: stepperRepeatOccurance, min: 0, max: 100)
        btnIntervalType.layer.cornerRadius = 5.0
        btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        btnIntervalType.layer.borderWidth = 0.5
        btnIntervalType.clipsToBounds = true
        
        for btn in btnDaysCollection {
            btn.layer.cornerRadius = 5.0
            btn.layer.borderColor = APPGRAYCOLOR.cgColor
            btn.layer.borderWidth = 0.5
            btn.clipsToBounds = true
        }
        
        txtRepeatWeek.delegate = self
        arrIntervalType = ["hours", "days", "weeks"]
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.designUI()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
        
       // let templateId = templateData["txtTemplateId"] as? String ?? ""
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTextMessageById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                let arrAttachments = result["attachements"] as! [AnyObject]
                //self.templateId = result["txtTemplateId"] as? String ?? ""
                self.CampaignId = result["txtTemplateCampId"] as? String ?? ""
                self.txtTemplatename.text = result["txtTemplateTitle"] as? String ?? ""
                self.lblTxtMessage.text = result["txtTemplateMsg"] as? String ?? ""
                self.timeIntervalValue = result["txtTemplateInterval"] as? String ?? "0"
                self.timeIntervalType = result["txtTemplateIntervalType"] as? String ?? "hours"
                
                let reminderType = result["txtTemplateRepeat"] as? String ?? "0"
                
                if reminderType == "1" {
                    self.btnImmediate.isSelected = false
                    self.btnSchedule.isSelected = false
                    self.btnReapeat.isSelected = true
                    self.isImmediate = "3"
                    self.view.layoutIfNeeded()
                    self.viewScheduleHeight.constant = 0.0
                    self.viewReapeatHeight.constant = 150.0
                    self.viewReapeat.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                    self.repeatWeeks = result["txtempRepeatWeeks"] as? String ?? "0"
                    self.repeatOn = result["txtempRepeatDays"] as? String ?? ""
                    self.repeatEnd = result["txtempRepeatEndOccurrence"] as? String ?? "0"
                    
                    self.txtRepeatWeek.text = self.repeatWeeks
                    self.stepperRepeatOccurance.countLabel.text = self.repeatEnd
                    
                    let dayArray = self.repeatOn.components(separatedBy: ",")
                    for day in dayArray {
                        if day != "" {
                            self.arrSelectedDays.append(day)
                        }
                    }
                    if self.arrSelectedDays.count > 0 {
                        for view in self.btnDaysCollection as [UIView] {
                            if let btn = view as? UIButton {
                                if self.arrSelectedDays.contains ((btn.titleLabel?.text)!){
                                    btn.backgroundColor = APPORANGECOLOR
                                    btn.setTitleColor(.white, for: .normal)
                                }else{
                                    btn.backgroundColor = .white
                                    btn.setTitleColor(.black, for: .normal)
                                }
                            }
                        }
                    }
                    
                    self.timeIntervalValue = "0"
                    self.timeIntervalType = "hours"
                    self.txtInterval.text = self.timeIntervalValue
                    self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
                    
                }else{
                    self.repeatWeeks = ""
                    self.repeatOn = ""
                    self.repeatEnd = ""
                    
                    if self.timeIntervalValue == "0" {
                        self.btnImmediate.isSelected = true
                        self.btnSchedule.isSelected = false
                        self.btnReapeat.isSelected = false
                        self.isImmediate = "1"
                        self.view.layoutIfNeeded()
                        self.viewScheduleHeight.constant = 0.0
                        self.viewReapeatHeight.constant = 0.0
                        self.viewReapeat.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                        self.timeIntervalValue = "0"
                        self.timeIntervalType = "hours"
                        self.txtInterval.text = self.timeIntervalValue
                        self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
                    }else{
                        self.btnImmediate.isSelected = false
                        self.btnSchedule.isSelected = true
                        self.btnReapeat.isSelected = false
                        self.isImmediate = "2"
                        self.view.layoutIfNeeded()
                        self.viewScheduleHeight.constant = 50.0
                        self.viewReapeatHeight.constant = 0.0
                        self.viewReapeat.isHidden = true
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                        
                        self.txtInterval.text = self.timeIntervalValue
                        self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
                    }
                    
                }
                
                let arrUrl = result["links"] as! [String]
                for obj in arrUrl {
                    self.vwAddUrls.addTag(obj)
                    self.vwAddUrls.enableRemoveButton = true
                    let dict = ["link":obj]
                    self.arrlinks.append(dict)
                }
                self.arrFile = []
                self.arrFileName = []
                self.arrFileId = []
                for file in arrAttachments {
                    let filePath = file["filePath"] as? String ?? ""
                    let fileId = file["txtCampAttachId"] as? String ?? ""
                    if filePath != "" {
                        let filename = filePath.components(separatedBy: "/")
                        self.arrFileName.append(filename.last!)
                        let url = URL(fileURLWithPath: filePath)
                        self.arrFile.append(url)
                        self.arrAttachFileId.append(fileId)
                        
                    }
                }
                
                if self.arrFile.count > 0 {
                    for i in 0 ..< self.arrFileName.count {
                        self.vwAttachFiles.addTag(self.arrFileName[i])
                        self.vwAttachFiles.enableRemoveButton = true
                    }
                }else{
//                    self.vwAttachFiles.enableRemoveButton = false
//                    self.vwAttachFiles.addTag("No attachment added yet.")
                }
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateTextTemplateVC"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdate(_ sender:UIButton){
       
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.updateTextMessage()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionAddUrl(_ sender:UIButton){
        self.openAlertView()
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.txtAddUrl = textField! 
            self.txtAddUrl?.placeholder = "Add link/url..";
            self.txtAddUrl?.text = "http://"
            self.txtAddUrl?.keyboardType = .URL
        }
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: "Add Link/URL", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
        
            if self.txtAddUrl?.text! == "http://" || self.txtAddUrl?.text! == "https://" {
                OBJCOM.setAlert(_title: "", message: "Please add url or link.")
            }else{
                if OBJCOM.verifyUrl(urlString: self.txtAddUrl?.text!) == true {
                    self.vwAddUrls.addTag((self.txtAddUrl?.text!)!)
                    self.vwAddUrls.enableRemoveButton = true
                    let dict = ["link":(self.txtAddUrl?.text!)!]
                    self.arrlinks.append(dict)
                }else{
                    OBJCOM.setAlert(_title: "", message: "Please enter valid url or link.")
                }
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateTextMessage(){
        if txtTemplatename.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter template name to update template.")
            OBJCOM.hideLoader()
            return
        }else if lblTxtMessage.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter text message.")
            OBJCOM.hideLoader()
            return
        }else if self.isImmediate == "3" {
            if self.txtRepeatWeek.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                OBJCOM.hideLoader()
                return
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                OBJCOM.hideLoader()
                return
            }
        }
        
        if self.isImmediate == "1" || self.isImmediate == "2" {
            self.repeatWeeks = ""
            self.repeatOn = ""
            self.repeatEnd = ""
        }else{
            if self.arrSelectedDays.count > 0 {
                self.repeatOn = self.arrSelectedDays.joined(separator: ",")
            }
            self.repeatWeeks = txtRepeatWeek.text ?? "1"
            self.repeatEnd = self.stepperRepeatOccurance.countLabel.text ?? "1"
        }
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":self.templateId,
                         "txtTemplateCampId":self.CampaignId,
                         "txtTemplateTitle":txtTemplatename.text!,
                         "txtTemplateMsg": lblTxtMessage.text!,
                         "txtTemplateInterval":self.txtRepeatWeek.text!,
                         "txtTemplateIntervalType":self.timeIntervalType,
                         "addLinkUrl" : self.arrlinks,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatWeek.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
                NotificationCenter.default.post(name: Notification.Name("UpdateTextTemplateVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionSetInterval(_ sender:UIButton){
        selectIntervalType()
    }
    
    @IBAction func actionAddFiles(_ sender:UIButton){
        self.selectAttachFiles()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        print("import result : \(myURL)")
//        if self.arrFile.count == 0 {
//            self.vwAttachFiles.removeAllTags()
//        }
        self.vwAttachFiles.addTag(myURL.lastPathComponent)
        self.vwAttachFiles.enableRemoveButton = true
        self.arrFile.append(myURL)
        self.arrFileName.append(myURL.lastPathComponent)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.downloadfile(URL: myURL as NSURL)
        }
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                DispatchQueue.main.async(execute: {
                    self.uploadDocument(data!, filename: URL.lastPathComponent!)
                })
            } else {
                // Failure
                print("Failure: %@", error!.localizedDescription)
                OBJCOM.setAlert(_title: "", message: error!.localizedDescription)
                OBJCOM.hideLoader()
                self.updateTextMessage()
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "txtCampAttachTempId":self.templateId]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadTxtMsgAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                        let success:String = JsonDict["IsSuccess"] as! String
                        if success == "true"{
                            let result = JsonDict["result"] as! [String:Any]
                            let attachId = result["txtCampAttachTempId"] as? String ?? ""
                            self.arrAttachFileId.append(attachId)
                            OBJCOM.hideLoader()
                           
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            OBJCOM.hideLoader()
                        }
                    }else {
                        //error hanlding
                        OBJCOM.hideLoader()
                    }
                    
                }
            case .failure(_):
                OBJCOM.hideLoader()
                break
            }
        })
    }
    
    
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender == self.vwAddUrls {
            let linkurl = tagView.titleLabel?.text!
            guard let index = self.arrlinks.index(where: {
                guard let indx = $0["link"] else { return false }
                return indx == linkurl
            }) else {
                return
            }
            self.arrlinks.remove(at: index)
            print(self.arrlinks)
            sender.removeTagView(tagView)
        }else{
            let fname = tagView.titleLabel?.text!
            if  self.arrAttachSaved.contains(fname!) {
                let index = self.arrAttachSaved.index(of: fname!)
                self.arrAttachSaved.remove(at: index!)
                let delId = self.arrAttachSavedFileId[index!]
                self.actionDeleteDocs(delId)
                sender.removeTagView(tagView)
                self.arrAttachSavedFileId.remove(at: index!)
            }else{
                if self.arrFile.count>0{
                    let index = self.arrFileName.index(of: fname!)
                    self.arrFileName.remove(at: index!)
                    self.arrFile.remove(at: index!)
                    let delId = self.arrAttachFileId[index!]
                    self.actionDeleteDocs(delId)
                    sender.removeTagView(tagView)
                    self.arrAttachFileId.remove(at: index!)
                }
            }
        }
    }
    
    
    func selectAttachFiles() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionFromDevice = UIAlertAction(title: "From Device", style: .default)
        {
            UIAlertAction in
            let importMenu = UIDocumentMenuViewController(documentTypes: ["public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        actionFromDevice.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionFromSavedDoc = UIAlertAction(title: "From Saved Documents", style: .default)
        {
            UIAlertAction in
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.editFilesFromDocuments),
                name: NSNotification.Name(rawValue: "EDITTEXTMSG"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "Document", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idDocumentListVC") as! DocumentListVC
            vc.className = "EditTextMessage"
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
            
        }
        actionFromSavedDoc.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionFromDevice)
        alert.addAction(actionFromSavedDoc)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editFilesFromDocuments(notification: NSNotification){
        
        print(notification.object!)
        let fileData = notification.object as! [AnyObject]
//        if fileData.count > 0 && self.arrFile.count == 0{
//            self.vwAttachFiles.removeAllTags()
//        }
        for obj in fileData {
            let fileOri = obj["fileOri"] as? String ?? ""
            let filePath = obj["filePath"] as? String ?? ""
            
            let url = URL(string: filePath)
            self.vwAttachFiles.addTag((url?.lastPathComponent)!)
            self.vwAttachFiles.enableRemoveButton = true
            self.arrAttachSaved.append(fileOri)
            self.arrAttachUrlSaved.append(url!)
            
            if self.arrAttachSaved.count > 0 {
                if self.arrAttachSaved.count > 0 {
                    for fileOri in self.arrAttachSaved {
                        self.actionUploadSavedDocs(fileOri)
                    }
                }
            }
        }
    }
    
    func actionUploadSavedDocs(_ filename:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "txtCampAttachTempId":self.templateId,
                         "fileOri": filename]
        
        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "uploadtxtMsgFromSaveDocument", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! [String:Any]
                let attachId = result["txtCampAttachTempId"] as? String ?? ""
                self.arrAttachSavedFileId.append(attachId)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func actionDeleteDocs(_ attachId:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "txtCampAttachId":attachId]
        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteTxtMsgAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                OBJCOM.setAlert(_title: "", message: result)
//                if self.arrAttachFileId.count == 0 && self.arrAttachSavedFileId.count == 0 {
//                    self.vwAttachFiles.enableRemoveButton = false
//                    self.vwAttachFiles.addTag("No attachment added yet.")
//                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension EditTextCampTemplate {
    @IBAction func actionImmediate(_ sender : UIButton){
        btnImmediate.isSelected = true
        btnSchedule.isSelected = false
        btnReapeat.isSelected = false
        self.isImmediate = "1"
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSchedule(_ sender : UIButton){
        btnImmediate.isSelected = false
        btnSchedule.isSelected = true
        btnReapeat.isSelected = false
        self.isImmediate = "2"
        //        self.repeatWeeks = ""
        //        self.repeatOn = ""
        //        self.repeatEnd = ""
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 50.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionRepeat(_ sender : UIButton){
        btnImmediate.isSelected = false
        btnSchedule.isSelected = false
        btnReapeat.isSelected = true
        self.isImmediate = "3"
        self.view.layoutIfNeeded()
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 150.0
        viewReapeat.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func actionSetWeekDaysForRepeat(_ sender : UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case 1:
            if self.arrSelectedDays.contains("Sun") == false {
                self.arrSelectedDays.append("Sun")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sun")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 2:
            if self.arrSelectedDays.contains("Mon") == false {
                self.arrSelectedDays.append("Mon")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Mon")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 3:
            if self.arrSelectedDays.contains("Tue") == false {
                self.arrSelectedDays.append("Tue")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Tue")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 4:
            if self.arrSelectedDays.contains("Wed") == false {
                self.arrSelectedDays.append("Wed")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Wed")
                self.arrSelectedDays.remove(at: index!)
                sender.setTitleColor(.black, for: .normal)
                
            }
            break
        case 5:
            if self.arrSelectedDays.contains("Thu") == false {
                self.arrSelectedDays.append("Thu")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Thu")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 6:
            if self.arrSelectedDays.contains("Fri") == false {
                self.arrSelectedDays.append("Fri")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Fri")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        case 7:
            if self.arrSelectedDays.contains("Sat") == false {
                self.arrSelectedDays.append("Sat")
                sender.backgroundColor = APPORANGECOLOR
                sender.setTitleColor(.white, for: .normal)
            }else{
                let index = self.arrSelectedDays.index(of: "Sat")
                self.arrSelectedDays.remove(at: index!)
                sender.backgroundColor = .white
                sender.setTitleColor(.black, for: .normal)
            }
            break
        default:
            break
        }
        
        print(self.arrSelectedDays)
    }
    
    func selectIntervalType() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionDay = UIAlertAction(title: "hours", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "hours"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionDay.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionWeek = UIAlertAction(title: "days", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "days"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionWeek.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionMonth = UIAlertAction(title: "weeks", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "week"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionMonth.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Dismiss", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionDay)
        alert.addAction(actionWeek)
        alert.addAction(actionMonth)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtInterval {
            if txtInterval.text == "" {
                self.timeIntervalValue = "0"
                self.timeIntervalType = "hours"
                self.txtInterval.text = timeIntervalValue
                self.btnIntervalType.setTitle(timeIntervalType, for: .normal)
            }else{
                self.timeIntervalValue = txtInterval.text!
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtRepeatWeek {
            OBJCOM.setRepeateWeeks(txtRepeatWeek)
            return false
        }
        return true
    }
}





