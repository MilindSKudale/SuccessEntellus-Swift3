//
//  TextTemplatePreviewVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TextTemplatePreviewVC: UIViewController, TagListViewDelegate  {
    
    @IBOutlet var txtTemplatename : SkyFloatingLabelTextField!
    @IBOutlet var lblTxtMessage : UILabel!
    @IBOutlet var lblTxtTimeInterval : UILabel!
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var vwAddUrls : TagListView!
    
    var templateData = [String:Any]()
    var arrFileName = [String]()
    var arrFile = [String]()
    var arrlinks = [String]()
    
    var templateId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    
        txtTemplatename.isUserInteractionEnabled = false

        lblAttachFiles.text = "Attached files :"
        lblAttachFiles.addImageWith(image: #imageLiteral(resourceName: "ic_attach"), behindText: false)
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
        vwAttachFiles.alignment = .left
        vwAttachFiles.enableRemoveButton = false
        
        vwAddUrls.delegate = self
        vwAddUrls.textFont = UIFont.systemFont(ofSize: 13)
        vwAddUrls.alignment = .left
        vwAddUrls.enableRemoveButton = false
       
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
                self.txtTemplatename.text = result["txtTemplateTitle"] as? String ?? ""
               // self.lblTxtMessage.text = result["txtTemplateMsg"] as? String ?? ""
                let isPredefine = result["txtTemplateFeature"] as? String ?? ""
                let html = result["txtTemplateMsg"] as? String ?? ""
                
                if isPredefine == "1" {
                    let dataHtml = Data(html.utf8)
                    if let attributedString = try? NSAttributedString(data: dataHtml, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                        self.lblTxtMessage.attributedText = attributedString
                    }
                }else{
                    self.lblTxtMessage.text = html
                }
                
               
                self.arrlinks = result["links"] as! [String]
                
                for obj in  self.arrlinks {
                    self.vwAddUrls.addTag(obj)
                }
                
                self.arrFile = []
                self.arrFileName = []
                for file in arrAttachments {
                    let filePath = file["filePath"] as? String ?? ""
                    if filePath != "" {
                        let filename = filePath.components(separatedBy: "/")
                        self.arrFileName.append(filename.last!)
                        self.arrFile.append(filePath)
                    }
                }
                if self.arrFileName.count > 0 {
                    for i in 0 ..< self.arrFileName.count {
                        self.vwAttachFiles.addTag(self.arrFileName[i])
                        self.vwAttachFiles.viewWithTag(i)
                    }
                }else{
                    self.vwAttachFiles.addTag("No attachment added yet.")
                }
                
                let reminderType = result["txtTemplateRepeat"] as? String ?? "0"
                let repeatWeeks = result["txtempRepeatWeeks"] as? String ?? "1"
                let repeatOn = result["txtempRepeatDays"] as? String ?? ""
                let repeatEnd = result["txtempRepeatEndOccurrence"] as? String ?? "0"
                let timeInterval = result["txtTemplateInterval"] as? String ?? "0"
                if reminderType == "1" {
                    self.lblTxtTimeInterval.text = "Repeat : every \(repeatWeeks) week(s)\nRepeat On : \(repeatOn)\nEnds : after \(repeatEnd) occurrence"
                }else if reminderType == "1" && timeInterval == "0" {
                    self.lblTxtTimeInterval.text = "0 hours"
                }else{
                    let timeIntervalType = result["txtTemplateIntervalType"] as? String ?? "hour"
                    self.lblTxtTimeInterval.text = "\(timeInterval) \(timeIntervalType)"
                }
                
                OBJCOM.hideLoader()
            }else{
//                let result = JsonDict!["result"] as! String
//                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
    }
    
    
}



extension UILabel {
    func addImageWith(image: UIImage, behindText: Bool) {
        let attachment = NSTextAttachment()
        attachment.image = image
        let attachmentString = NSAttributedString(attachment: attachment)
        guard let txt = self.text else {
            return
        }
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    
}

