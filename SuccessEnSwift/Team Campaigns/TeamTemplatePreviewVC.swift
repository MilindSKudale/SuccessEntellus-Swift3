//
//  TeamTemplatePreviewVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TeamTemplatePreviewVC: UIViewController, UITextViewDelegate, UIDocumentInteractionControllerDelegate, TagListViewDelegate {
    
    @IBOutlet var lblEmailSubject: UILabel!
    @IBOutlet var viewTempPrev: UIView!
    @IBOutlet var lblTemplateName: UILabel!
    @IBOutlet var txtViewTempPrev: UITextView!
    @IBOutlet var htmlString : String!
    @IBOutlet var templateName : String!
    @IBOutlet var btnEditCampaign : UIButton!
    var bgColor = UIColor()
    var isCustomCampaign : Bool!
    var dictData = [String : Any]()
    
    @IBOutlet var lblAttachFiles : UILabel!
    @IBOutlet var vwAttachFiles : TagListView!
    var arrFileName = [String]()
    var arrFile = [String]()
    var editFlag = ""
    
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
        
        if isCustomCampaign {
            btnEditCampaign.isHidden = false
            //if templateName == "Self Reminder" {
            //    btnEditCampaign.setTitle(" Edit Self Reminder ", for: .normal)
            //    lblAttachFiles.isHidden = true
            //    vwAttachFiles.isHidden = true
            //    editFlag = "Self Reminder"
            //}else{
                btnEditCampaign.setTitle(" Edit Template ", for: .normal)
                lblAttachFiles.isHidden = false
                vwAttachFiles.isHidden = false
                editFlag = "Template"
           // }
            
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
            name: NSNotification.Name(rawValue: "ReloadTeamTempPrev"),
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
        NotificationCenter.default.post(name: Notification.Name("ReloadTempData1"), object: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}

