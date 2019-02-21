//
//  CreateTextMessageVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import McPicker
import Alamofire
import SwiftyJSON
import RichEditorView

class CreateTextMessageVC: UIViewController, TagListViewDelegate, UITextViewDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var txtCampaignTitle : SkyFloatingLabelTextField!
  //  @IBOutlet var txtMessage : UITextView!
  //  @IBOutlet var btnSetInterval : UIButton!
    @IBOutlet var btnAddFiles : UIButton!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var viewAttachFiles : UIView!
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var btnSetPlainText : UIButton!
    @IBOutlet var btnSetFormattedText : UIButton!
    @IBOutlet var btnIntervalType: UIButton!
    @IBOutlet var txtInterval: UITextField!
    var timeIntervalValue = "0"
    var timeIntervalType = ""
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    var htmlString = ""
    var htmlTextToSend = ""
    var isPlainText = "1"
    
    let picker = UIImagePickerController()
    var pickedImagePath = ""
    var arrImages = [UIImage]()
    
//    @IBOutlet var btnAddUrls : UIButton!
//    @IBOutlet var vwAddUrls : TagListView!
//    var txtAddUrl: UITextField?
    
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
    
    @IBOutlet var rdoButtonFooterYes: UIButton!
    @IBOutlet var rdoButtonFooterNo: UIButton!
    @IBOutlet var rdoButtonSignYes: UIButton!
    @IBOutlet var rdoButtonSignNo: UIButton!
    var isFooterShow = "1"
    var isSignShow = "0"
   
    var arrSelectedDays = [String]()

    var campaignId = ""
    var arrAttachUrl = [URL]()
    var arrAttachUrlSaved = [String]()
    var arrAttachFileId = [String]()
    var arrAttachSavedFileId = [String]()
    var arrAttachFilename = [String]()
    var arrlinks = [[String:String]]()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDoneOption.doneBtn
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrAttachFileId = []
        arrAttachSavedFileId = []
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        
        btnAdd.layer.cornerRadius = 5.0
        btnAdd.clipsToBounds = true
        
        btnAddFiles.layer.cornerRadius = 5.0
        btnAddFiles.layer.borderColor = APPGRAYCOLOR.cgColor
        btnAddFiles.layer.borderWidth = 0.75
        btnAddFiles.clipsToBounds = true
    
        btnIntervalType.layer.cornerRadius = 5.0
        btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        btnIntervalType.layer.borderWidth = 0.5
        btnIntervalType.clipsToBounds = true
        
        editorView.layer.cornerRadius = 5.0
        editorView.clipsToBounds = true
        editorView.layer.borderColor = APPGRAYCOLOR.cgColor
        editorView.layer.borderWidth = 0.5
        
        toolbar.options = RichEditorDoneOption.doneBtn
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
       
        
        btnSetPlainText.isSelected = true
        btnSetFormattedText.isSelected = false
        self.isPlainText = "1"
        toolbar.delegate = self
        toolbar.editor = editorView
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
        vwAttachFiles.alignment = .left
        viewAttachFiles.isHidden = true
        
//        vwAddUrls.delegate = self
//        vwAddUrls.textFont = UIFont.systemFont(ofSize: 13)
//        vwAddUrls.alignment = .left
//        vwAddUrls.enableRemoveButton = false
        
        btnImmediate.isSelected = true
        btnSchedule.isSelected = false
        btnReapeat.isSelected = false
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        OBJCOM.setStepperValues(stepper: stepperRepeatOccurance, min: 1, max: 100)
        
        arrSelectedDays = []
        let weekday = Date().dayOfTheWeek()
        for btn in btnDaysCollection {
            
            if weekday == btn.titleLabel?.text {
                btn.backgroundColor = APPORANGECOLOR
                btn.setTitleColor(.white, for: .normal)
                self.arrSelectedDays.append(btn.titleLabel!.text!)
            }
            btn.layer.cornerRadius = 5.0
            btn.layer.borderColor = APPGRAYCOLOR.cgColor
            btn.layer.borderWidth = 0.5
            btn.clipsToBounds = true
        }
        
        self.isImmediate = "1"
        self.repeatWeeks = ""
        self.repeatOn = ""
        self.repeatEnd = ""
        self.timeIntervalValue = "1"
        self.timeIntervalType = "hours"
        self.txtRepeatWeek.text = "1"
        self.txtRepeatWeek.delegate = self
        self.txtInterval.text = timeIntervalValue
        self.btnIntervalType.setTitle("hours", for: .normal)
        
        self.rdoButtonFooterYes.isSelected = true
        self.rdoButtonFooterNo.isSelected = false
        self.isFooterShow = "1"
        self.rdoButtonSignNo.isSelected = true
        self.rdoButtonSignYes.isSelected = false
        self.isSignShow = "0"
       
    }
    
    
    @IBAction func actionSetPlainText(_ sender:UIButton){
        toolbar.options = RichEditorDoneOption.doneBtn
        toolbar.delegate = self
        toolbar.editor = editorView
        btnSetPlainText.isSelected = true
        btnSetFormattedText.isSelected = false
        viewAttachFiles.isHidden = true
        self.isPlainText = "1"
        toolbar.editor?.becomeFirstResponder()
    }
    
    @IBAction func actionSetFormattedText(_ sender:UIButton){
        toolbar.options = RichEditorDefaultOption.all
        toolbar.delegate = self
        toolbar.editor = editorView
        btnSetPlainText.isSelected = false
        btnSetFormattedText.isSelected = true
        viewAttachFiles.isHidden = false
        self.isPlainText = "2"
        toolbar.editor?.becomeFirstResponder()
    }
   
    @IBAction func actionCustomToolTip(_ sender:UIButton){
        OBJCOM.popUp(context: self, msg: "By using custom message, you can create formatted text with adding images, links and attachments.")
    }
   
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionAddTextMessage(_ sender:UIButton){
        if validate() == true {
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
                    self.addTextMessageAPI()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
        }
    }
    
    @IBAction func actionSetInterval(_ sender:UIButton){
        txtCampaignTitle.resignFirstResponder()
        self.selectIntervalType()
    }
    
    @IBAction func actionAddFiles(_ sender:UIButton){
        selectAttachFiles()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        print("import result : \(myURL)")
        self.vwAttachFiles.addTag(myURL.lastPathComponent)
        self.vwAttachFiles.enableRemoveButton = true
        self.arrAttachUrl.append(myURL)
        self.arrAttachFilename.append(myURL.lastPathComponent)
        
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
                selector: #selector(self.addFilesFromDocuments),
                name: NSNotification.Name(rawValue: "ADDTEXTMSG"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "Document", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idDocumentListVC") as! DocumentListVC
            vc.className = "AddTextMessage"
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
    
    @objc func addFilesFromDocuments(notification: NSNotification){
        print(notification.object!)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            let fileData = notification.object as! [AnyObject]
            for obj in fileData {
                let fileOri = obj["fileOri"] as? String ?? ""
                let filePath = obj["filePath"] as? String ?? ""
                
                let url = URL(string: filePath)
                self.vwAttachFiles.addTag((url?.lastPathComponent)!)
                self.vwAttachFiles.enableRemoveButton = true
                self.arrAttachUrlSaved.append(fileOri)
                self.actionUploadSavedDocs(fileOri)
            }
        }
    }
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                DispatchQueue.main.async(execute: {
                    self.uploadDocument(data!, filename: URL.lastPathComponent!)
                })
            } else {
                print("Failure: %@", error!.localizedDescription)
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
      
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "txtCampAttachTempId":"0"]
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
                            self.addTextMessageAPI()
                            OBJCOM.hideLoader()
                        }
                    }else {
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_):
                OBJCOM.hideLoader()
                break
            }
        })
    }
    
    func actionUploadSavedDocs(_ filename:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "txtCampAttachTempId":"0",
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

    
    // MARK: TagListViewDelegate
//    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
//        if sender == self.vwAddUrls {
//            if tagView.titleLabel?.text == "" {
//                return
//            }
//
//            guard let requestUrl = NSURL(string: (tagView.titleLabel?.text)!) else {
//                return
//            }
//
//            UIApplication.shared.open(requestUrl as URL, options: [:], completionHandler: { (status) in
//
//            })
//        }
//    }
//
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
//
//        if sender == self.vwAddUrls {
//            let linkurl = tagView.titleLabel?.text!
//            guard let index = self.arrlinks.index(where: {
//                guard let indx = $0["link"] else { return false }
//                return indx == linkurl
//            }) else {
//                return
//            }
//            self.arrlinks.remove(at: index)
//            print(self.arrlinks)
//            sender.removeTagView(tagView)
//        }else{
            let fname = tagView.titleLabel?.text!
            if  self.arrAttachUrlSaved.contains(fname!) {
                let index = self.arrAttachUrlSaved.index(of: fname!)
                self.arrAttachUrlSaved.remove(at: index!)
                let delId = self.arrAttachSavedFileId[index!]
                self.actionDeleteDocs(delId)
                sender.removeTagView(tagView)
                self.arrAttachSavedFileId.remove(at: index!)
            }else{
                if self.arrAttachUrl.count>0{
                    let index = self.arrAttachFilename.index(of: fname!)
                    self.arrAttachFilename.remove(at: index!)
                    self.arrAttachUrl.remove(at: index!)
                    let delId = self.arrAttachFileId[index!]
                    self.actionDeleteDocs(delId)
                    sender.removeTagView(tagView)
                    self.arrAttachFileId.remove(at: index!)
                }
            }
//        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = "Enter text message"
            textView.textColor = UIColor.lightGray
        }
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
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == txtRepeatWeek {
//            OBJCOM.setRepeateWeeks(txtRepeatWeek)
//        }
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtRepeatWeek {
            //textField.resignFirstResponder()
            OBJCOM.setRepeateWeeks(txtRepeatWeek)
            return false
        }
        return true
    }
}

extension CreateTextMessageVC: RichEditorDelegate, RichEditorToolbarDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlString = ""
        } else {
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



extension CreateTextMessageVC {
    func addTextMessageAPI(){
        //addTextMessage
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
                         "txtTemplateCampId":self.campaignId,
                         "txtTemplateTitle":self.txtCampaignTitle.text!,
                         "txtTemplateMsg":strMessageText,
                         "txtTemplateInterval": self.txtInterval.text!,
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
        OBJCOM.modalAPICall(Action: "addTextMessage", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! String
    
                OBJCOM.hideLoader()
                OBJCOM.setAlert(_title: "", message: result)
                NotificationCenter.default.post(name: Notification.Name("UpdateTextCampaignVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    func validate() -> Bool {
        if txtCampaignTitle.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter text message title")
            return false
        } else if htmlString == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter text message.")
            return false
        }
        else if self.isImmediate == "3" {
            if self.txtRepeatWeek.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                return false
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                return false
            }
        }else if self.isImmediate == "2" && self.timeIntervalType == "" {
            OBJCOM.setAlert(_title: "", message: "Please select interval type.")
            return false
        }
        return true
    }
    
    func actionCheckMemberAssignedOrNot() {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "txtCampId":self.campaignId,
                         "stepId":"0"]
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
                            self.addTextMessageAPI()
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
                        self.addTextMessageAPI()
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
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension CreateTextMessageVC {
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
                sender.backgroundColor = .white
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
    
}

extension Date {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
}
