//
//  SupportVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 14/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class SupportVC: UIViewController {
    
    @IBOutlet var lblPhone : UILabel!
    @IBOutlet var lblMail : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblPhone.text = "1-408-641-8294"
        lblMail.text = "support@successentellus.com"
    }
    
    @IBAction func callToSupport(_ sender:UIButton){
        let alertController = UIAlertController(title: "", message: "Allow to make a call with Success Entellus team?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Allow", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.lblPhone.text?.makeAColl()
        }
        let cancelAction = UIAlertAction(title: "Deny", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func mailToSupport(_ sender:UIButton){
        
    }
    
    @IBAction func actionPrivacyPolicy(_ sender:UIButton){
        if let url = URL(string: "https://successentellus.com/home/privacyPolicy") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}
extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
