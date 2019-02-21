//
//  TextTemplatePreviewVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TextTemplatePreviewVC: UIViewController, TagListViewDelegate  {
    
    @IBOutlet var lblCampName : UILabel!
    @IBOutlet var lblCampDate : UILabel!
    @IBOutlet var txtTemplatename : UILabel!
    @IBOutlet var lblTxtMessage : UITextView!
//    @IBOutlet var lblTxtTimeInterval : UILabel!
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    @IBOutlet var viewAttachFiles : UIView!
    @IBOutlet var btnCancel : UIButton!
  //  @IBOutlet var vwAddUrls : TagListView!
    @IBOutlet var bgView : UIView!
    @IBOutlet var tempFooterView : UIView!
    @IBOutlet var tempFooterLbl : UILabel!
    @IBOutlet var heightTempFooterView : NSLayoutConstraint!
    
    var templateData = [String:Any]()
    var arrFileName = [String]()
    var arrFile = [String]()
   // var arrlinks = [String]()
    
    var templateId = ""
    var campaignName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.bgView.backgroundColor = .white
        txtTemplatename.isUserInteractionEnabled = false

        lblAttachFiles.text = "Attached files :"
        lblAttachFiles.addImageWith(image: #imageLiteral(resourceName: "ic_attach"), behindText: false)
        
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.clipsToBounds = true
        
        lblTxtMessage.layer.cornerRadius = 5.0
        lblTxtMessage.layer.borderColor = APPGRAYCOLOR.cgColor
        lblTxtMessage.layer.borderWidth = 0.5
        lblTxtMessage.clipsToBounds = true
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 13)
        vwAttachFiles.alignment = .left
        vwAttachFiles.enableRemoveButton = false
        
        self.tempFooterView.isHidden = true
        self.heightTempFooterView.constant = 0
        
       // vwAddUrls.delegate = self
       // vwAddUrls.textFont = UIFont.systemFont(ofSize: 13)
       // vwAddUrls.alignment = .left
       // vwAddUrls.enableRemoveButton = false
        let str = "Success Entellus respects your privacy. For more information, please review our privacy policy"
        let attributedString = NSMutableAttributedString(string: str)
        var foundRange = attributedString.mutableString.range(of: "Terms of use")
        foundRange = attributedString.mutableString.range(of: "privacy policy")
        attributedString.addAttribute(.link, value: "https://successentellus.com/home/privacyPolicy", range: foundRange)
        
        tempFooterLbl.attributedText = attributedString
        let tapAction = UITapGestureRecognizer(target: self, action:#selector(tapLabel(_:)))
        tempFooterLbl?.isUserInteractionEnabled = true
        tempFooterLbl?.addGestureRecognizer(tapAction)
       
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.designUI()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        lblCampName.text = self.campaignName
        
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
                var html = result["txtTemplateMsg"] as? String ?? ""
                
                let tempDate = result["txtTemplateAddDate"] as? String ?? ""
                let arrDate = tempDate.components(separatedBy: " ")
                self.lblCampDate.text = "Campaign created on \(arrDate[0])"
                let templateType = result["txtTemplateType"] as? String ?? "1"
                
                if isPredefine == "1" {
                    let dataHtml = Data(html.utf8)
                    if let attributedString = try? NSAttributedString(data: dataHtml, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                        self.lblTxtMessage.attributedText = attributedString
                    }
                }else{
                    
                    if templateType == "2" {
                        html = html.replacingOccurrences(of: "\n", with: "<br>")
                        let data = html.data(using: String.Encoding.utf16)!
                        let attrStr = try? NSMutableAttributedString(
                            data: data,
                            options: [.documentType: NSAttributedString.DocumentType.html],
                            documentAttributes: nil)
                        attrStr!.beginEditing()
                        attrStr!.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, attrStr!.length), options: .init(rawValue: 0)) {
                            (value, range, stop) in
                            if let font = value as? UIFont {
                                let resizedFont = font.withSize(17.0)
                                attrStr!.addAttribute(NSAttributedStringKey.font, value: resizedFont, range: range)
                            }
                        }
                        attrStr!.endEditing()
                        self.lblTxtMessage.attributedText = attrStr
                        
                    }else{
                       // html = html.replacingOccurrences(of: "\n", with: "<br>")
                        self.lblTxtMessage.text = html
                    }
                }
                
                
//                var strMessageText = result["txtTemplateMsg"] as? String ?? ""
//
//                if self.isPlainText == "1" {
//                    strMessageText = strMessageText.replacingOccurrences(of: "\n", with: "<br>")
//                    self.editorView.html = strMessageText
//                } else{
//                    self.editorView.html = strMessageText
//                }
//
              //  self.arrlinks = result["links"] as! [String]
              //  for obj in  self.arrlinks {
              //      self.vwAddUrls.addTag(obj)
              //  }
                
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
                
                if templateType == "2" {
                    self.viewAttachFiles.isHidden = false
                }else{
                    self.viewAttachFiles.isHidden = true
                }
                
                let isFooterView = result["txtTemplateFooterFlag"] as? String ?? "0"
                if isFooterView == "1" {
                    self.tempFooterView.isHidden = false
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        self.heightTempFooterView.constant = 100
                        self.view.layoutIfNeeded()
                        
                    }, completion: nil)
                }else{
                    self.tempFooterView.isHidden = true
                    self.heightTempFooterView.constant = 0
                }
           
                
                OBJCOM.hideLoader()
            }else{
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
    
    @IBAction func tapLabel(_ gesture: UITapGestureRecognizer) {
        let text = (tempFooterLbl.text)!
        
        let privacyRange = (text as NSString).range(of: "privacy policy")
        
        if gesture.didTapAttributedTextInLabel(label: tempFooterLbl, inRange: privacyRange) {
            print("Tapped privacy")
            if let url = URL(string: "https://successentellus.com/home/privacyPolicy") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            print("Tapped none")
        }
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


