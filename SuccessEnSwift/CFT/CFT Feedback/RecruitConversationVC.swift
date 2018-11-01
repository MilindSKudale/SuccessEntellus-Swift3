//
//  RecruitConversationVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 31/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import Alamofire
import SwiftyJSON

class RecruitConversationVC : JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIDocumentMenuDelegate {
    
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var receiverName: String!
    var receiverImage: UIImage!
    var senderImage: UIImage!
    
    var avatarImage = ""
    
    let imagePicker = UIImagePickerController()
    let imageView = UIImageView(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
    var locationManager: CLLocationManager!
    
    var cftAccessUserId = String()
    var feedbackParentCft = String()
    var userName = String()
    //var currentLocation:CLLocation?
//    var latitudeToSend: CLLocationDegrees?
//    var longitudeToSend: CLLocationDegrees?
    var sendBtnPressed = false
    
    var arrName = [String]()
    var arrImage = [String]()
    var arrDate = [String]()
    var arrCftUser = [String]()
    var arrMsgContent = [String]()
    var arrAttachImage = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup navigation
        setupBackButton()
        imagePicker.delegate = self
        self.title = receiverName
        
        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        self.senderId = userID
        let userInfo = UserDefaults.standard.value(forKey: "USERINFO") as! [String:Any]
        self.senderDisplayName = userInfo["first_name"] as? String ?? ""
        let sImage = userInfo["profile_pic"] as? String ?? ""
        if sImage != "" {
            let url1 = URL(string: sImage)
            let data1 = try? Data(contentsOf: url1!)
            
            if let imageData = data1 {
                let image = UIImage(data: imageData)
                self.senderImage = image
            }
        }else{
            self.senderImage = #imageLiteral(resourceName: "profile")
        }
        
        
        let img = UIImageView()
        img.imageFromServerURL(urlString: avatarImage)
        receiverImage = img.image
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        self.collectionView?.collectionViewLayout.springinessEnabled = false
        self.automaticallyScrollsToMostRecentMessage = true
//        self.inputToolbar.contentView.textView.becomeFirstResponder()
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getConversationData()
            updateCounterFlag()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func updateCounterFlag(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftAccessUserId": cftAccessUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateReadFlagTo", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
            }else{
                OBJCOM.popUp(context: self, msg: "Failed to update message counter.")
                OBJCOM.hideLoader()
            }
        }
    }
    
    func getConversationData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "cftAccessUserId": cftAccessUserId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorFeedBack", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrName = []
            self.arrImage = []
            self.arrDate = []
            self.arrCftUser = []
            self.arrMsgContent = []
            self.arrAttachImage = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrData = JsonDict!["result"] as! [String : AnyObject]
                let arrFeedbackData = arrData["feedBack"] as! [AnyObject]
                
                for i in 0..<arrFeedbackData.count {
                    
                    let msg = self.decodeEmoji(arrFeedbackData[i]["feedbackCftContent"] as? String ?? "")
                    self.arrName.append(arrFeedbackData[i]["toName"] as? String ?? "")
                    self.arrImage.append(arrFeedbackData[i]["imgPathTo"] as? String ?? "")
                    self.arrDate.append(arrFeedbackData[i]["feedbackCftAddDate"] as? String ?? "")
                    self.arrCftUser.append(arrFeedbackData[i]["cftUser"] as? String ?? "")
                    self.arrMsgContent.append(msg ?? "")
                    self.arrAttachImage.append(arrFeedbackData[i]["attachImage"] as? String ?? "")
                }
                
                self.receiverName = arrData["fromName"] as! String
                self.feedbackParentCft = "\(arrData["feedbackParentCft"] ?? "" as AnyObject)"
                let rImage = arrData["imgPath"] as! String
                let url = URL(string: rImage)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self.receiverImage = image
                }
                self.messages = []
                for i in 0..<self.arrMsgContent.count {
                    
                    if self.arrAttachImage[i] == ""{
                        let message = JSQMessage(senderId: self.arrCftUser[i], senderDisplayName: self.arrName[i], date: Date(), text: self.arrMsgContent[i])!
                        self.messages.append(message)
                    }else{
                        
                        let img = self.arrAttachImage[i]
                        let url = URL(string: img)
                        let data = try? Data(contentsOf: url!)
                        
                        if let imageData = data {
                            let image = UIImage(data: imageData)
                            let photoItem = JSQPhotoMediaItem(image: image)
                            let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photoItem)
                            self.messages.append(message!)
                        }
                    }
                }
                
                self.finishSendingMessage(animated: true)
                self.collectionView?.collectionViewLayout.springinessEnabled = false
                self.automaticallyScrollsToMostRecentMessage = true
                self.collectionView?.reloadData()
                self.collectionView?.layoutIfNeeded()
                OBJCOM.hideLoader()
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    
    @objc func backButtonTapped() {
        NotificationCenter.default.post(name: Notification.Name("UpdateUIRecruits"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        self.messages.append(message)
        self.finishSendingMessage(animated: true)
        
        DispatchQueue.global(qos: .background).async {
            self.sendTextFeedback(message)
        }
    }
    
    func sendTextFeedback(_ message:JSQMessage){
        
        let msg = encodeEmoji(message.text!)
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "feedbackCftTo": cftAccessUserId,
                         "feedbackParentCft": feedbackParentCft,
                         "feedbackCftContent": msg,
                         "attachImage": ""]
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "sendMentorFeedBack", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                //let result = JsonDict!["result"] as! String
                //OBJCOM.setAlert(_title: "", message: result)
                DispatchQueue.global(qos: .background).async {
                    self.getConversationData()
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func sendImageFeedback(item:JSQPhotoMediaItem){
        
        if item.image == nil {
            OBJCOM.setAlert(_title: "", message: "Selected image is not proper format.")
            return
        }
        let imgData = UIImageJPEGRepresentation(item.image, 0.2)!
        
        let parameters = ["userId": userID,
                          "platform":"3",
                          "feedbackCftTo": cftAccessUserId,
                          "feedbackParentCft": feedbackParentCft,
                          "feedbackCftContent": ""]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "attachImage",fileName: "attachImage.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:SITEURL+"sendMentorFeedBack")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let  JSON : [String:Any]
                    if let json = response.result.value {
                        JSON = json as! [String : Any]
                        
                        let success:String = JSON["IsSuccess"] as! String
                        if success == "true"{
                            OBJCOM.hideLoader()
                        }else{
                            OBJCOM.hideLoader()
                        }
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
//        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
//            /**
//             *  Add fake video
//             */
//            
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .photoLibrary
//            self.imagePicker.mediaTypes = [kUTTypeMovie as String]
//            
//            self.present(self.imagePicker, animated: true, completion: nil)
//            
//            
//        }
        
        
        
        let docAction = UIAlertAction(title: "Send document", style: .default) { (action) in
            let importMenu = UIDocumentMenuViewController(documentTypes: ["public.text", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        //sheet.addAction(docAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
//    func buildVideoItem(videoURL: URL) -> JSQVideoMediaItem {
//        //        let videoURL = URL(fileURLWithPath: "file://")
//
//        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)!
//
//        return videoItem
//    }
    
//    func buildAudioItem() -> JSQAudioMediaItem {
//        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
//        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
//
//        let audioItem = JSQAudioMediaItem(data: audioData)
//
//        return audioItem
//    }
    
    func buildLocationItem(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: latitude, longitude: longitude)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)!
        self.messages.append(message)
        self.finishSendingMessage(animated: true)
        
    }
    
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        
        let message = messages[indexPath.item]
        let ids = message.senderId
        
        if ids == self.senderId {
            let userImage = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: self.senderImage, diameter: 20)!
            return userImage
        }else{
            let userImage = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: receiverImage, diameter: 20)!
            return userImage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        var imagee = #imageLiteral(resourceName: "kitten_avatar")
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if (mediaType == kUTTypeImage as String) {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                imagee = pickedImage
            } else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imagee = pickedImage
            }
            
            dismiss(animated: true, completion: {
                let photoItem = JSQPhotoMediaItem(image: imagee)
                self.addMedia(photoItem!)
                
                
                DispatchQueue.global(qos: .background).async {
                    self.sendImageFeedback(item: photoItem!)
                }
                
            })
        }
//        else if(mediaType == kUTTypeMovie as String){
//            let tempVideo = info[UIImagePickerControllerMediaURL] as! URL
//            DispatchQueue.main.async(){
//
//                self.dismiss(animated: true, completion: {
//                    let videoItem = self.buildVideoItem(videoURL: tempVideo)
//                    self.addMedia(videoItem)
//                })
//            }
//        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension RecruitConversationVC {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
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
            }
        })
        task.resume()
    }
    
    func uploadDocument(_ file: Data,filename : String) {
        
        let parameters = ["userId" : userID,
                          "platform": "3",
                          "feedbackCftId":cftAccessUserId]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)uploadCftAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
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
                            //self.addTextMessageAPI()
                            let result = JsonDict["result"] as? String ?? ""
                            let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), text: result)!
                            self.messages.append(message)
                            self.finishSendingMessage(animated: true)
                            OBJCOM.hideLoader()
                        }else{
                            
                            OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                            OBJCOM.hideLoader()
                        }
                    }else {
                        OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                        OBJCOM.hideLoader()
                    }
                }
            case .failure(_): break
                OBJCOM.setAlert(_title: "", message: "Unable to upload attachment. Please retry.")
                OBJCOM.hideLoader()
            }
        })
    }
    
    func encodeEmoji(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    func decodeEmoji(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}


