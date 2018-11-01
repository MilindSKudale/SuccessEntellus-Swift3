//
//  UploadContactsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class UploadContactsVC: UIViewController {
    
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnImportDeviceContacts: UIButton!
    @IBOutlet weak var btnImportCSV: UIButton!
    @IBOutlet weak var btnExportCSV: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiView.layer.cornerRadius = 5.0
        uiView.clipsToBounds = true
        
        btnImportDeviceContacts.layer.cornerRadius = 5.0
        btnImportDeviceContacts.layer.borderWidth = 0.5
        btnImportDeviceContacts.layer.borderColor = APPGRAYCOLOR.cgColor
        btnImportDeviceContacts.clipsToBounds = true
        
        btnImportCSV.layer.cornerRadius = 5.0
        btnImportCSV.layer.borderWidth = 0.5
        btnImportCSV.layer.borderColor = APPGRAYCOLOR.cgColor
        btnImportCSV.clipsToBounds = true
        
        btnExportCSV.layer.cornerRadius = 5.0
        btnExportCSV.layer.borderWidth = 0.5
        btnExportCSV.layer.borderColor = APPGRAYCOLOR.cgColor
        btnExportCSV.clipsToBounds = true
        
        whichView = "UploadContacts"
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.createSpotlight()
    }
    
    func createSpotlight(){
        
        let labeltitlePoint = self.lblTitle.getGlobalPoint(toView: self.view)
        let btnImportPoint = self.btnImportDeviceContacts.getGlobalPoint(toView: self.view)
        
        let itemsToBeHighlighted : [WalkthroughItemType] = [
            (point: labeltitlePoint,
             height: self.lblTitle.frame.height,
             width: self.lblTitle.frame.width,
             title: "Import Contacts",
             description: "Please click on 'Next' to import your contacts with Success Entellus."),
            
            (point: btnImportPoint,
             height: self.btnImportDeviceContacts.frame.height,
             width: self.btnImportDeviceContacts.frame.width,
             title: "Import Phone Contacts",
             description: "Please click on 'Import' to import your phone contacts with Success Entellus. Do not click again, otherwise contact(s) will be added repeatedly."),
            ]
        
        showWalkthroughView(currentViewController: self, itemsToBeHighlighted: itemsToBeHighlighted)
      
        
    }
    
    
}
