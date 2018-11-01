
import UIKit
import Alamofire
import SwiftyJSON
import RichEditorView

class EditTemplateVC: UIViewController, UIImagePickerControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, TagListViewDelegate {

    @IBOutlet var txtEmailSubject : SkyFloatingLabelTextField!
    @IBOutlet var txtEmailHeading : SkyFloatingLabelTextField!
    @IBOutlet var btnIntervalType: UIButton!
    @IBOutlet var txtInterval: UITextField!
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var btnAttachFiles: UIButton!
    @IBOutlet var lblBtnAttachFiles: UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    
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
    var timeIntervalType = "days"
    var isImmediate = "1"
    var repeatWeeks = ""
    var repeatOn = ""
    var repeatEnd = ""

    let picker = UIImagePickerController()
    var pickedImagePath = ""
    var templateId = ""
    var campaignId = ""
    var emailSubject = ""
    var emailHeading = ""
    var htmlString = ""
    var htmlTextToSend = ""
    var editFlag = ""
    var arrAttachments = [AnyObject]()
    var templateData = [AnyObject]()
    var isTempPrev = false
    
    var arrAttachUrlSaved = [URL]()
    var arrAttachSaved = [String]()
    var arrAttachFileId = [String]()
    
    var arrFileName = [String]()
    var arrFile = [URL]()
    var arrFileId = [String]()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrFile = []
        self.arrFileName = []
        
        //getEmailTemplateById
        txtInterval.text = "0"
        btnIntervalType.setTitle("days", for: .normal)
        txtRepeatWeek.text = "1"
        txtRepeatWeek.delegate = self
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.designUI()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        txtEmailSubject.text = emailSubject
        txtEmailHeading.text = emailHeading
        
        editorView.layer.cornerRadius = 5.0
        editorView.clipsToBounds = true
        editorView.layer.borderColor = APPGRAYCOLOR.cgColor
        editorView.layer.borderWidth = 0.5
        
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        editorView.html = htmlString

        toolbar.delegate = self
        toolbar.editor = editorView
        picker.delegate  = self
    
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }
        var options = toolbar.options
        options.append(item)
        toolbar.options = options
        
        btnIntervalType.layer.cornerRadius = 5.0
        btnIntervalType.clipsToBounds = true
        btnIntervalType.layer.borderColor = APPGRAYCOLOR.cgColor
        btnIntervalType.layer.borderWidth = 0.5
       
 
        viewScheduleHeight.constant = 0.0
        viewReapeatHeight.constant = 0.0
        viewReapeat.isHidden = true
        OBJCOM.setStepperValues(stepper: stepperRepeatOccurance, min: 0, max: 100)
        
        for btn in btnDaysCollection {
            btn.layer.cornerRadius = 5.0
            btn.layer.borderColor = APPGRAYCOLOR.cgColor
            btn.layer.borderWidth = 0.5
            btn.clipsToBounds = true
        }
        arrSelectedDays = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        txtInterval.delegate = self
    }
    
    func designUI(){
        
        // let templateId = templateData["txtTemplateId"] as? String ?? ""
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "stepId":self.templateId] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getEmailTemplateById", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
                let result  = data[0]
                self.timeIntervalValue = result["campaignStepSendInterval"] as? String ?? "0"
                self.timeIntervalType = result["campaignStepSendIntervalType"] as? String ?? "days"
                self.txtRepeatWeek.text = result["campRepeatWeeks"] as? String ?? "0"
                let reminderType = result["campaignStepRepeat"] as? String ?? "0"
                
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
                    
                    self.repeatWeeks = result["campRepeatWeeks"] as? String ?? "1"
                    self.repeatOn = result["campRepeatDays"] as? String ?? ""
                    self.repeatEnd = result["campRepeatEndOccurrence"] as? String ?? "0"
                    
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
                    self.timeIntervalType = "days"
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
                        self.timeIntervalType = "days"
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
                
                if self.editFlag == "Self Reminder" {
                    self.vwAttachFiles.isHidden = true
                    self.btnAttachFiles.isHidden = true
                    self.lblBtnAttachFiles.isHidden = true
                }else{
                    
                    if self.arrAttachments.count > 0 {
                        for file in self.arrAttachments {
                            let filePath = file["filePath"] as? String ?? ""
                            if filePath != "" {
                                let filename = filePath.components(separatedBy: "/")
                                let fileId = file["attachmentId"] as? String ?? ""
                                self.arrFileName.append(filename.last!)
                                let url = URL(string: filePath)
                                self.arrFile.append(url!)
                                self.arrFileId.append(fileId)
                            }
                        }
                        if self.arrFile.count > 0 {
                            for i in 0 ..< self.arrFileName.count {
                                self.vwAttachFiles.addTag(self.arrFileName[i])
                                self.vwAttachFiles.enableRemoveButton = true
                            }
                        } else {
                            self.vwAttachFiles.enableRemoveButton = false
                            //   self.vwAttachFiles.addTag("No attachment added yet.")
                        }
                    } else {
                        self.vwAttachFiles.enableRemoveButton = false
                        // self.vwAttachFiles.addTag("No attachment added yet.")
                    }
                    self.vwAttachFiles.delegate = self
                    self.vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
                    self.vwAttachFiles.alignment = .left
                    self.vwAttachFiles.isHidden = false
                    self.btnAttachFiles.isHidden = false
                    self.lblBtnAttachFiles.isHidden = false
                }
                
                
                OBJCOM.hideLoader()
            }else{
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionClose(_ sender : UIButton){
        if self.isTempPrev == true {
            NotificationCenter.default.post(name: Notification.Name("ReloadTempPrev"), object: nil)
            
        }else{
            NotificationCenter.default.post(name: Notification.Name("ReloadTempData"), object: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAttachFiles(_ sender : UIButton){
        self.selectAttachFiles()
    }
    
    @IBAction func actionUpdateTemplate(_ sender : UIButton){
        if txtEmailSubject.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter email subject.")
            return
        }else if timeIntervalType == "Select" {
            OBJCOM.setAlert(_title: "", message: "Please select type interval type.")
            return
        }else{
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.actionUpdateTemplate()
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            
        }
    }
}

extension EditTemplateVC : UITextFieldDelegate {
    
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
                selector: #selector(self.editFilesFromDocuments),
                name: NSNotification.Name(rawValue: "EDITFILES"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "Document", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idDocumentListVC") as! DocumentListVC
            vc.className = "EditEmailTemplate"
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

    @IBAction func actionSetIntervalType(_ sender : UIButton){
        selectIntervalType()
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtInterval {
            if txtInterval.text == "" {
                self.timeIntervalValue = "0"
                self.timeIntervalType = "days"
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
        
        if self.arrFile.count == 0 {
            self.vwAttachFiles.removeAllTags()
        }
        self.vwAttachFiles.addTag(myURL.lastPathComponent)
        self.vwAttachFiles.enableRemoveButton = true
        self.vwAttachFiles.removeButtonIndex = 100
        self.arrFile.append(myURL)
        self.downloadfile(URL: myURL as NSURL)
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
                          "campaignId":self.campaignId,
                          "campaignStepId" :self.templateId]
        
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
                    if let JsonDict = response.result.value as? [String : Any] {
                        print(JsonDict)
                        let success:String = JsonDict["IsSuccess"] as! String
                        if success == "true"{
                            OBJCOM.hideLoader()

                            let result = JsonDict["result"] as! [String : AnyObject]
                            let fileID = result["attachmentId"] as? String ?? ""
                            self.arrFileId.append(fileID)
                            
                            OBJCOM.setAlert(_title: "", message: "Attachment file uploaded successfully.")
                        }else{
                            OBJCOM.setAlert(_title: "", message: "File uploading failed because of internet interruption.")
                            OBJCOM.hideLoader()
                        }
                    }else {
                        OBJCOM.setAlert(_title: "", message: "File uploading failed because of internet interruption.")
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "File uploading failed because of internet interruption.")
                OBJCOM.hideLoader()
                break
            }
        })
    }
    
    func actionUploadSavedDocs(_ filename:String) {
    
        let dictParam = ["userId" : userID,
                         "platform": "3",
                         "campaignId":self.campaignId,
                         "campaignStepId":self.templateId,
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
                let result = JsonDict!["result"] as! [String : Any]
                print(result)
                OBJCOM.setAlert(_title: "", message: "Attachment file uploaded successfully.")
    
                let fileID = result["attachmentId"] as? String ?? ""
                self.arrAttachFileId.append(fileID)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.setAlert(_title: "", message: "Uploading failed because of internet interruption.")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension EditTemplateVC {
    
    func actionUpdateTemplate() {
        
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
                         "campaignStepId":templateId,
                         "campaignStepSubject":txtEmailSubject.text!,
                         "campaignStepTitle":txtEmailHeading.text!,
                         "campaignStepContent":htmlTextToSend,
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
        OBJCOM.modalAPICall(Action: "updateEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in

            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if self.isTempPrev == true {
                        NotificationCenter.default.post(name: Notification.Name("ReloadTempPrev"), object: nil)
                        
                    }else{
                        NotificationCenter.default.post(name: Notification.Name("ReloadTempData"), object: nil)
                       // self.dismiss(animated: true, completion: nil)
                    }
                self.presentingViewController?.presentingViewController?.dismiss (animated: true, completion: nil)
                    
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
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
                if self.arrFile.count == 0 && self.arrAttachSaved.count == 0 {
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

extension EditTemplateVC: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextToSend = ""
        } else {
            htmlTextToSend = content
        }
    }
}

extension EditTemplateVC: RichEditorToolbarDelegate {
    
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
            self .present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertView()
            alert.title = "Warning"
            alert.message = "Your device don't have camera"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
   
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
    
    @IBAction func actionAddAttachments(_ sender : UIButton){
        
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
                    print(progress)
                })
                
                upload.responseJSON { response in
                   
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

        if  self.arrAttachSaved.contains(fname!) {
            
            let index = self.arrAttachSaved.index(of: fname!)
            self.arrAttachSaved.remove(at: index!)
            let delId = self.arrAttachFileId[index!]
            
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                DispatchQueue.main.async {
                    self.actionDeleteDocs(delId)
                    sender.removeTagView(tagView)
                    self.arrAttachFileId.remove(at: index!)
                }
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
            
        }else{
            
            if self.arrFileName.contains(fname!) {
                
                let index = self.arrFileName.index(of: fname!)
                self.arrFileName.remove(at: index!)
              //  let fileUrl = self.arrFile[index!]
                self.arrFile.remove(at: index!)
                let delId = self.arrFileId[index!]
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    DispatchQueue.main.async {
                        self.actionDeleteDocs(delId)
                        sender.removeTagView(tagView)
                        self.arrFileId.remove(at: index!)
                    }
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            }
        }
        
    }
}

extension EditTemplateVC  {
    
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
    
}

