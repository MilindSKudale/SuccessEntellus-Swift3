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
import RichEditorView

class EditTextCampTemplate: UIViewController, TagListViewDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var txtTemplatename : SkyFloatingLabelTextField!
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var btnSetPlainText : UIButton!
    @IBOutlet var btnSetFormattedText : UIButton!
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var viewAttachFiles : UIView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var btnAddFiles : UIButton!
    //@IBOutlet var btnSetInterval : UIButton!'
    
    @IBOutlet var rdoButtonFooterYes: UIButton!
    @IBOutlet var rdoButtonFooterNo: UIButton!
    @IBOutlet var rdoButtonSignYes: UIButton!
    @IBOutlet var rdoButtonSignNo: UIButton!
    var isFooterShow = "1"
    var isSignShow = "0"
    var templateType = "1"
    
//    @IBOutlet var btnAddUrls : UIButton!
//    @IBOutlet var vwAddUrls : TagListView!
//    var txtAddUrl: UITextField?

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

    var timeIntervalValue = "1"
    var timeIntervalType = "hours"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    var htmlString = ""
    var htmlText = ""
    var isPlainText = "1"
    
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
    let picker = UIImagePickerController()
    var pickedImagePath = ""
    var arrImages = [UIImage]()
    
    
    var arrSelectedDays = [String]()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDoneOption.doneBtn
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        lblAttachFiles.text = "Attach files :"
        lblAttachFiles.addImageWith(image: #imageLiteral(resourceName: "ic_attach"), behindText: false)
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        
        btnUpdate.layer.cornerRadius = 5.0
        btnUpdate.clipsToBounds = true
        
        editorView.layer.cornerRadius = 5.0
        editorView.clipsToBounds = true
        editorView.layer.borderColor = APPGRAYCOLOR.cgColor
        editorView.layer.borderWidth = 0.5
        
        toolbar.options = RichEditorDoneOption.doneBtn
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type text here.."
        toolbar.delegate = self
        toolbar.editor = editorView
        
        btnAddFiles.layer.cornerRadius = 5.0
        btnAddFiles.layer.borderColor = APPGRAYCOLOR.cgColor
        btnAddFiles.layer.borderWidth = 0.75
        btnAddFiles.clipsToBounds = true
        
//        btnAddUrls.layer.cornerRadius = 5.0
//        btnAddUrls.layer.borderColor = APPGRAYCOLOR.cgColor
//        btnAddUrls.layer.borderWidth = 0.75
//        btnAddUrls.clipsToBounds = true
//
//        vwAddUrls.delegate = self
//        vwAddUrls.textFont = UIFont.systemFont(ofSize: 13)
//        vwAddUrls.alignment = .left
//        vwAddUrls.enableRemoveButton = false
        
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
             
                self.timeIntervalValue = result["txtTemplateInterval"] as? String ?? "1"
                self.timeIntervalType = result["txtTemplateIntervalType"] as? String ?? "hours"
                
                self.isFooterShow = result["txtTemplateFooterFlag"] as? String ?? "0"
                if self.isFooterShow == "1" {
                    self.rdoButtonFooterYes.isSelected = true
                    self.rdoButtonFooterNo.isSelected = false
                }else{
                    self.rdoButtonFooterYes.isSelected = false
                    self.rdoButtonFooterNo.isSelected = true
                }
                
                self.isSignShow = result["txtTemplateAddSignature"] as? String ?? "0"
                if self.isSignShow == "0"{
                    self.rdoButtonSignNo.isSelected = true
                    self.rdoButtonSignYes.isSelected = false
                }else{
                    self.rdoButtonSignNo.isSelected = false
                    self.rdoButtonSignYes.isSelected = true
                }
               // self.htmlString = result["txtTemplateMsg"] as? String ?? ""
                var strMessageText = result["txtTemplateMsg"] as? String ?? ""
                if self.isPlainText == "1" {
                    strMessageText = strMessageText.replacingOccurrences(of: "\n", with: "<br>")
                    if strMessageText == "<br>" {
                        strMessageText = ""
                    }
                    self.htmlString = strMessageText
                    self.editorView.html = strMessageText
                    self.htmlText = self.htmlString
                } else {
                    self.editorView.html = strMessageText
                    self.htmlText = self.htmlString
                }
                

                self.templateType = result["txtTemplateType"] as? String ?? "1"
                if self.templateType == "2" {
                    self.btnSetPlainText.isSelected = false
                    self.btnSetFormattedText.isSelected = true
                    self.toolbar.options = RichEditorDefaultOption.all
                    self.toolbar.delegate = self
                    self.toolbar.editor = self.editorView
                    self.editorView.delegate = self
                    self.isPlainText = "2"
                    self.viewAttachFiles.isHidden = false
                }else{
                    self.btnSetPlainText.isSelected = true
                    self.btnSetFormattedText.isSelected = false
                    self.toolbar.options = RichEditorDoneOption.doneBtn
                    self.toolbar.delegate = self
                    self.toolbar.editor = self.editorView
                    self.isPlainText = "1"
                    self.viewAttachFiles.isHidden = true
                    self.editorView.delegate = self
                }
                
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
                    
                    self.timeIntervalValue = "1"
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
                        self.timeIntervalValue = "1"
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
                }
                
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionSetPlainText(_ sender:UIButton){
        
        self.btnSetPlainText.isSelected = true
        self.btnSetFormattedText.isSelected = false
        self.viewAttachFiles.isHidden = true
        
        self.toolbar.options = RichEditorDoneOption.doneBtn
        self.toolbar.delegate = self
        self.toolbar.editor = self.editorView
        self.isPlainText = "1"
        self.editorView.delegate = self
        
        
        self.isPlainText = "1"
        if self.templateType == "2" {
        
            self.editorView.html = " "
        }else{
            self.editorView.html = self.htmlText
        }
//        toolbar.options = RichEditorDoneOption.doneBtn
//        toolbar.delegate = self
//        toolbar.editor = self.editorView
//        editorView.inputAccessoryView = toolbar
//        editorView.delegate = self
    }
    
    @IBAction func actionSetFormattedText(_ sender:UIButton){
        toolbar.options = RichEditorDefaultOption.all
        toolbar.delegate = self
        toolbar.editor = editorView
        editorView.delegate = self
        btnSetPlainText.isSelected = false
        btnSetFormattedText.isSelected = true
        
        editorView.inputAccessoryView = toolbar
        self.viewAttachFiles.isHidden = false
        self.isPlainText = "2"
       // if self.templateType == "1" {
            self.editorView.html = self.htmlText
//        }else{
//            self.editorView.html = self.htmlString
//        }
    }
    
    @IBAction func actionCustomToolTip(_ sender:UIButton){
        OBJCOM.popUp(context: self, msg: "By using custom message, you can create formatted text with adding images, links and attachments.")
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateTextTemplateVC"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdate(_ sender:UIButton){
        if txtTemplatename.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter template name to update template.")
            OBJCOM.hideLoader()
            return
        }else if htmlString == "" || htmlString == "<br>" || htmlString == " " {
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
        }else{
            if self.isImmediate == "1" {
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.actionCheckMemberAssignedOrNot()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }else{
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.updateTextMessage()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
        }
        
    }
    
    func updateTextMessage(){
        
        
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
        
        var strMessageText = ""
        if isPlainText == "1" {
            strMessageText = htmlString.htmlToString
        }else{
            strMessageText = htmlString
        }
        print(strMessageText)
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "txtTemplateId":self.templateId,
                         "txtTemplateCampId":self.CampaignId,
                         "txtTemplateTitle":txtTemplatename.text!,
                         "txtTemplateMsg": strMessageText,
                         "txtTemplateInterval":self.timeIntervalValue,
                         "txtTemplateIntervalType":self.timeIntervalType,
                         "addLinkUrl" : self.arrlinks,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatWeek.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd,
                         "txtTemplateFooterFlag":self.isFooterShow,
                         "txtTemplateAddSignature":self.isSignShow,
                         "txtTemplateType":self.isPlainText] as [String : Any]
        
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
        controller.dismiss(animated: true, completion: nil)
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
//
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
//        }
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
            if txtInterval.text == "" || txtInterval.text == "0"{
                self.timeIntervalValue = "1"
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
    
    @IBAction func actionIsFooterYes(_ sender : UIButton){
        self.rdoButtonFooterYes.isSelected = true
        self.rdoButtonFooterNo.isSelected = false
        self.isFooterShow = "1"
    }
    @IBAction func actionIsFooterNo(_ sender : UIButton){
        self.rdoButtonFooterYes.isSelected = false
        self.rdoButtonFooterNo.isSelected = true
        self.isFooterShow = "0"
    }
    
    @IBAction func actionIsSignYes(_ sender : UIButton){
        self.rdoButtonSignYes.isSelected = true
        self.rdoButtonSignNo.isSelected = false
        self.isSignShow = "1"
    }
    @IBAction func actionIsSignNo(_ sender : UIButton){
        self.rdoButtonSignYes.isSelected = false
        self.rdoButtonSignNo.isSelected = true
        self.isSignShow = "0"
    }
    
    func actionCheckMemberAssignedOrNot() {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "txtCampId":self.CampaignId,
                         "stepId":self.templateId]
        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "checkMemberAssignedOrNot", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as AnyObject
                
                
                if "\(result)" != "0" {
                    let alert = UIAlertController(title: nil, message: "Members are assinged with this campaign. Text message will send to that member 'Immediately'. Do you want to proceed?", preferredStyle: .alert)
                    
                    let actionOk = UIAlertAction(title: "Proceed", style: .default)
                    {
                        UIAlertAction in
                        if OBJCOM.isConnectedToNetwork(){
                            OBJCOM.setLoader()
                            self.updateTextMessage()
                        }else{
                            OBJCOM.NoInternetConnectionCall()
                        }
                    }
                    actionOk.setValue(UIColor.black, forKey: "titleTextColor")
                    let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
                    {
                        UIAlertAction in
                    }
                    actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
                    
                    alert.addAction(actionOk)
                    alert.addAction(actionCancel)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.updateTextMessage()
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                }
    
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension EditTextCampTemplate : RichEditorDelegate, RichEditorToolbarDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content == "" {
            htmlString = ""
        } else if content == "Type text here.." {
            htmlString = ""
        }else{
            htmlString = content
        }
    }
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            let alert:UIAlertController=UIAlertController(title: "Insert Link", message: "Ex.'http://www.successentellus.com'", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter link"
            })
            
            let insertAction = UIAlertAction(title: "Insert", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                
                let strlnk = alert.textFields![0].text ?? ""
                
                if strlnk != "" {
                    if OBJCOM.verifyUrl(urlString:strlnk) {
                        toolbar.editor?.insertLink(strlnk, title: strlnk)
                    } else {
                        OBJCOM.setAlert(_title: "", message: "Please insert valid link.")
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Please insert link.")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
            }
            alert.addAction(insertAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }else{
            OBJCOM.setAlert(_title: "Warning", message: "You don't have camera")
        }
    }
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("\(info)")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let filename = userID + "/\(NSUUID().uuidString)" + ".png"
            let image = self.resizeImage(image: pickedImage, targetSize: CGSize(width: 200.0, height: 200.0))
              self.uploadImage(filename: filename, image: image)
            self.picker.dismiss(animated: true, completion: nil)
            
        } else {
            self.picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        print("picker cancel.")
    }
    
    func uploadImage(filename:String, image:UIImage) {
        
        let param = ["userId" : userID]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "editorImage", fileName: filename, mimeType: "image/png")
            for (key, value) in param {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: SITEURL+"uploadCkEditorImage")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    print(progress)
                })
                
                upload.responseJSON { response in
                    //print response.result
                    
                    print(response.value as AnyObject)
                    //                    let success:String = response["IsSuccess"] as! String
                    let data = response.value as AnyObject
                    let success = data["IsSuccess"] as! String
                    if success == "true" {
                        OBJCOM.hideLoader()
                        let result = data["result"] as! String
                        self.toolbar.editor?.insertImage(result,alt: "image")
                    }else{
                        print("result:",response)
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension NSAttributedString {
    var attributedStringToHtml: String? {
        do {
            let htmlData = try self.data(from:NSMakeRange(0, self.length), documentAttributes:[.documentType: NSAttributedString.DocumentType.html]);
            return String.init(data: htmlData, encoding: String.Encoding.utf8)
        } catch {
            print("error:", error)
            return nil
        }
    }
}
