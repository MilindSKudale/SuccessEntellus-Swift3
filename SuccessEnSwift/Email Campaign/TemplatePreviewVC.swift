//
//  TemplatePreviewVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire

class TemplatePreviewVC: UIViewController, UITextViewDelegate, UIDocumentInteractionControllerDelegate, TagListViewDelegate {

    @IBOutlet var lblEmailSubject: UILabel!
    @IBOutlet var viewTempPrev: UIView!
    @IBOutlet var lblTemplateName: UILabel!
    @IBOutlet var txtViewTempPrev: UITextView!
    @IBOutlet var htmlString : String!
    @IBOutlet var templateName : String!
    @IBOutlet var btnEditCampaign : UIButton!
    @IBOutlet var tempFooterView : UIView!
    @IBOutlet var tempFooterLbl : UILabel!
    @IBOutlet var heightTempFooterView : NSLayoutConstraint!
    
    var bgColor = UIColor()
    var isCustomCampaign : Bool!
    var dictData = [String : Any]()
    
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    var arrFileName = [String]()
    var arrFile = [String]()
    var editFlag = ""
    var isFooterView = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dictData)
        
        txtViewTempPrev.layer.cornerRadius = 5.0
        txtViewTempPrev.clipsToBounds = true
        txtViewTempPrev.layer.borderColor = APPGRAYCOLOR.cgColor
        txtViewTempPrev.layer.borderWidth = 0.5

        btnEditCampaign.layer.cornerRadius = 5.0
        btnEditCampaign.clipsToBounds = true
        
        vwAttachFiles.delegate = self
        vwAttachFiles.textFont = UIFont.systemFont(ofSize: 15)
        vwAttachFiles.alignment = .left
        vwAttachFiles.tagBackgroundColor = .groupTableViewBackground
        vwAttachFiles.textColor = .black
        
        
        
        let str = "Success Entellus respects your privacy. For more information, please review our privacy policy"
        let attributedString = NSMutableAttributedString(string: str)
        var foundRange = attributedString.mutableString.range(of: "Terms of use")
        foundRange = attributedString.mutableString.range(of: "privacy policy")
        attributedString.addAttribute(.link, value: "https://successentellus.com/home/privacyPolicy", range: foundRange)
        
        tempFooterLbl.attributedText = attributedString
        let tapAction = UITapGestureRecognizer(target: self, action:#selector(tapLabel(_:)))
        tempFooterLbl?.isUserInteractionEnabled = true
        tempFooterLbl?.addGestureRecognizer(tapAction)
        
        if isFooterView == "1" {
            tempFooterView.isHidden = false
            heightTempFooterView.constant = 100
        }else{
            tempFooterView.isHidden = true
            heightTempFooterView.constant = 0
        }

        
        if isCustomCampaign {
            
            if templateName == "Self Reminder" {
                btnEditCampaign.isHidden = true
                btnEditCampaign.setTitle(" Edit Self Reminder ", for: .normal)
                lblAttachFiles.isHidden = true
                vwAttachFiles.isHidden = true
                editFlag = "Self Reminder"
            }else{
                btnEditCampaign.isHidden = false
                btnEditCampaign.setTitle(" Edit Template ", for: .normal)
                lblAttachFiles.isHidden = false
                vwAttachFiles.isHidden = false
                editFlag = "Template"
            }
            
            self.arrFile = []
            self.arrFileName = []
            let arrAttachment = self.dictData["attachments"] as! [AnyObject]
            for file in arrAttachment {
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
        }else{
            btnEditCampaign.isHidden = true
        }
        
        lblEmailSubject.text = self.dictData["emailHeading"] as? String ?? "Follow up."
        lblTemplateName.text = self.dictData["emailSubject"] as? String ?? ""
        let data = htmlString.data(using: String.Encoding.unicode)!
        let attrStr = try? NSAttributedString(
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        txtViewTempPrev.attributedText = attrStr
        
        
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnEditTemplate(sender: UIButton) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.ReloadTempData),
            name: NSNotification.Name(rawValue: "ReloadTempPrev"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditTemplateVC") as! EditTemplateVC
        vc.arrAttachments         = self.dictData["attachments"] as! [AnyObject]
        vc.timeIntervalValue      = self.dictData["timeIntervalValue"] as! String
        vc.timeIntervalType       = self.dictData["timeIntervalType"] as! String
        vc.emailSubject           = self.dictData["emailSubject"] as! String
        vc.emailHeading           = self.dictData["emailHeading"] as! String
        vc.templateId             = self.dictData["templateId"] as! String
        vc.campaignId             = self.dictData["campaignId"] as! String
        vc.htmlString             = self.dictData["htmlString"] as! String
        vc.isTempPrev = true
        vc.editFlag = self.editFlag
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle   = .crossDissolve
        vc.view.backgroundColor   = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func ReloadTempData(notification: NSNotification){
        NotificationCenter.default.post(name: Notification.Name("ReloadTempData"), object: nil)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
