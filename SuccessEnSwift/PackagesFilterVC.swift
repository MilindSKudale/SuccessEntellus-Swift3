//
//  PackagesFilterVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 20/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

protocol PopupProtocol {
    func dismiss()
}

class PackagesFilterVC : SliderVC {
    
   // var PopupDelegate: popup?
//    @IBOutlet var btnUpgrade : UIButton!
   // @IBOutlet var btnCancel : UIButton!
    @IBOutlet var popupView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
//        btnUpgrade.layer.cornerRadius = btnUpgrade.frame.height/2
//        btnUpgrade.layer.borderColor = APPORANGECOLOR.cgColor
//        btnUpgrade.layer.borderWidth = 1.5
//        btnUpgrade.clipsToBounds = true
        
//        btnCancel.layer.cornerRadius = btnCancel.frame.height/2
//        btnCancel.layer.borderColor = APPORANGECOLOR.cgColor
//        btnCancel.layer.borderWidth = 1.5
//        btnCancel.clipsToBounds = true
        
        popupView.layer.cornerRadius = 10
        popupView.clipsToBounds = true

    }
    
//    @IBAction func actionSignUp(_ sender:UIButton){
//        if let url = URL(string: "https://successentellus.com/signup/register") {
//            UIApplication.shared.open(url, options: [:])
//        }
//    }
    
//    @IBAction func actionCancel(_ sender:UIButton){
//       
//       // self.actShowMenu(sender)
//        //self.dismissPopup(completion: nil)
//
//    }
}
