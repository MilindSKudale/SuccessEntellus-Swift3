//
//  NoInternetVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 07/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class NoInternetVC: UIViewController {

    @IBOutlet var btnRefresh : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRefresh.layer.cornerRadius = 5.0
        btnRefresh.layer.borderWidth = 1
        btnRefresh.layer.borderColor = APPGRAYCOLOR.cgColor
    }

    @IBAction func actionBtnRefresh(sender: UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.hideLoader()
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

}
