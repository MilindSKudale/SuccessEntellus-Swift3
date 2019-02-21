//
//  PredefineCampPreview.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 04/12/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PredefineCampPreview: UIViewController {
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var btnDismiss : UIButton!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet var tempFooterLbl : UILabel!
    
    var templateId = ""
    var campaignName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        
        btnDismiss.layer.cornerRadius = 5.0
        btnDismiss.clipsToBounds = true

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
        
        lblTitle.text = self.campaignName
    }
    
    @IBAction func actionDismiss(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func designUI(){
        
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
                self.lblTitle.text = result["txtTemplateTitle"] as? String ?? ""
               
                let html = result["txtTemplateMsg"] as? String ?? ""
                let dataHtml = Data(html.utf8)
                if let attributedString = try? NSAttributedString(data: dataHtml, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    self.lblMessage.attributedText = attributedString
                }
                let colorObj = result["txtTemplateColor"] as? String ?? ""
                 if colorObj != "" {
                     let colorObjArr = colorObj.components(separatedBy: ",")
                     if colorObjArr.count > 0 {
                     let redColor = colorObjArr[0]
                     let blueColor = colorObjArr[2]
                     let greenColor = colorObjArr[1]
                     
                     self.bgView.backgroundColor = UIColor.init(red: Int(redColor) ?? 0, green: Int(greenColor) ?? 0, blue: Int(blueColor) ?? 0)
                     self.bgView.layer.cornerRadius = 5.0;
                 }
                 }else{
                    self.bgView.backgroundColor = .white
                 }
                
                OBJCOM.hideLoader()
            }else{
                //                let result = JsonDict!["result"] as! String
                //                OBJCOM.setAlert(_title: "", message: result)
                OBJCOM.hideLoader()
            }
        }
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
