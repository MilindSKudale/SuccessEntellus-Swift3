//
//  AddTemplateVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RichEditorView

class AddTemplateForTC: UIViewController, UIImagePickerControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, TagListViewDelegate {
    
    @IBOutlet var txtEmailSubject : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailHeading : SkyFloatingLabelTextField!
    @IBOutlet var btnIntervalType: UIButton!
    @IBOutlet var txtInterval: UITextField!
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var btnAttachFiles: UIButton!
    
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
    var arrSelectedDays = [String]()
    
    var timeIntervalValue = "0"
    var timeIntervalType = ""
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""
    
    let picker = UIImagePickerController()
    var pickedImagePath = ""
    var arrImages = [UIImage]()
    
    var templateId = ""
    var campaignId = ""
    var emailSubject = ""
    var emailHeading = ""
    var htmlString = ""
    var htmlTextToSend = ""
    
    var attachFileUrl : URL!
    var arrAttachUrl = [URL]()
    var arrAttachFilename = [String]()
    var arrAttachUrlSaved = [String]()
    var arrAttachFileId = [String]()
    var arrAttachSavedFileId = [String]()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrAttachFileId = []
        arrAttachSavedFileId = []
        
        btnIntervalType.layer.cornerRadius = 5.0
        btnIntervalType.clipsToBounds = true
        btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        btnIntervalType.layer.borderWidth = 0.3
        txtInterval.text = "0"
        txtRepeatWeek.text = "1"
        txtRepeatWeek.delegate = self
        
        btnIntervalType.setTitle("Select", for: .normal)
        txtEmailSubject.text = ""
        txtEmailHeading.text = ""
        
        editorView.layer.cornerRadius = 5.0
        editorView.clipsToBounds = true
        editorView.layer.borderColor = APPGRAYCOLOR.cgColor
        editorView.layer.borderWidth = 0.5
        
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        editorView.html = ""
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
        vwAttachFiles.alignment = .left
        vwAttachFiles.addTag("No attachment added yet.")
        vwAttachFiles.enableRemoveButton = false
        
        toolbar.delegate = self
        toolbar.editor = editorView
        picker.delegate  = self
        
        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }
        
        var options = toolbar.options
        options.append(item)
        toolbar.options = options
        
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
        self.timeIntervalValue = "0"
        self.timeIntervalType = ""
        
        self.txtInterval.text = timeIntervalValue
        txtInterval.delegate = self
    }
    
    @IBAction func actionClose(_ sender : UIButton){
        self.presentingViewController?.presentingViewController?.dismiss( animated: true, completion: nil)
    }
    
    @IBAction func actionAttachFiles(_ sender : UIButton){
        self.selectAttachFiles()
    }
    
    @IBAction func actionAddTemplate(_ sender : UIButton){
        
        if txtEmailSubject.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email subject.")
            return
        }else{
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.actionAddTemplateAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
}

extension AddTemplateForTC : UITextFieldDelegate {
    
    func selectAttachFiles() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionFromDevice = UIAlertAction(title: "From Device", style: .default)
        {
            UIAlertAction in
            self.AddAttachmentFilesFromDevice()
        }
        actionFromDevice.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionFromSavedDoc = UIAlertAction(title: "From Saved Documents", style: .default)
        {
            UIAlertAction in
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.addFilesFromDocuments),
                name: NSNotification.Name(rawValue: "ADDFILES"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "Document", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idDocumentListVC") as! DocumentListVC
            vc.className = "AddEmailTemplate"
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
            if fileData.count > 0 && self.arrAttachUrl.count == 0{
                self.vwAttachFiles.removeAllTags()
            }
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
    
    @IBAction func actionSetIntervalType(_ sender : UIButton){
        selectIntervalType()
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
    
    func AddAttachmentFilesFromDevice() {
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        
        print("import result : \(myURL)")
        if self.arrAttachUrl.count == 0 {
            self.vwAttachFiles.removeAllTags()
        }
        
        self.vwAttachFiles.addTag(myURL.lastPathComponent)
        self.vwAttachFiles.enableRemoveButton = true
        self.arrAttachUrl.append(myURL)
        self.arrAttachFilename.append(myURL.lastPathComponent)
        // self.attachFileUrl =  myURL
        
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
                self.uploadDocument(data!, filename: URL.lastPathComponent!)
            }
            else {
                // Failure
                print("Failure: %@", error!.localizedDescription)
                OBJCOM.setAlert(_title: "", message: error!.localizedDescription)
                OBJCOM.hideLoader()
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "campaignId":self.campaignId]
        
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                            OBJCOM.hideLoader()
                            let result = JsonDict["result"] as! [String:Any]
                            let attachId = result["attachmentId"] as? String ?? ""
                            self.arrAttachFileId.append(attachId)
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "Failed to upload attachment.")
                break
            }
        })
    }
}

extension AddTemplateForTC {
    
    func actionAddTemplateAPI() {
        
        let attrStr = htmlTextToSend
        // print(attrStr)
        
        if self.isImmediate == "3" {
            if self.txtRepeatWeek.text == "" {
                OBJCOM.setAlert(_title: "", message: "Please enter week(s) count.")
                OBJCOM.hideLoader()
                return
            }else if self.arrSelectedDays.count == 0 {
                OBJCOM.setAlert(_title: "", message: "Please select weekdays.")
                OBJCOM.hideLoader()
                return
            }
        }else if self.isImmediate == "2" {
            if self.timeIntervalType == "" {
                OBJCOM.setAlert(_title: "", message: "Please select interval type.")
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
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignStepCamId":campaignId,
                         "campaignStepSubject":txtEmailSubject.text!,
                         "campaignStepTitle":txtEmailHeading.text!,
                         "campaignStepContent":attrStr,
                         "campaignStepSendInterval":self.timeIntervalValue,
                         "campaignStepSendIntervalType":self.timeIntervalType,
                         "selectType": self.isImmediate,
                         "repeat_every_weeks":self.txtRepeatWeek.text!,
                         "repeat_on":self.repeatOn,
                         "repeat_ends_after":self.repeatEnd] as [String : Any]
        
        print(dictParam)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    
                    // Post notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddTemplate"), object: nil)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func actionUploadSavedDocs(_ filename:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "campaignId":self.campaignId,
                         "fileOri": filename]
        
        print(dictParam)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "uploadFromSaveDocument", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! [String:Any]
                print(result)
                let attachId = result["attachmentId"] as? String ?? ""
                self.arrAttachSavedFileId.append(attachId)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
}

extension AddTemplateForTC: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextToSend = ""
        } else {
            htmlTextToSend = content
        }
    }
}

extension AddTemplateForTC: RichEditorToolbarDelegate {
    
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
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertView()
            alert.title = "Warning"
            alert.message = "Your device not supports to camera."
            alert.addButton(withTitle: "OK")
            alert.show()
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
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
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
    }
    
    func actionDeleteDocs(_ attachId:String) {
        
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "attachmentId":attachId]
        print(dictParam)
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                OBJCOM.setAlert(_title: "", message: result)
                if self.arrAttachFileId.count == 0 && self.arrAttachSavedFileId.count == 0 {
                    self.vwAttachFiles.enableRemoveButton = false
                    self.vwAttachFiles.addTag("No attachment added yet.")
                }
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension AddTemplateForTC  {
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
        
        print(self.arrSelectedDays)
    }
    
    func selectIntervalType() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionDay = UIAlertAction(title: "days", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "days"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionDay.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionWeek = UIAlertAction(title: "weeks", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "week"
            self.btnIntervalType.setTitle(self.timeIntervalType, for: .normal)
        }
        actionWeek.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionMonth = UIAlertAction(title: "months", style: .default)
        {
            UIAlertAction in
            self.timeIntervalType = "month"
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
}
