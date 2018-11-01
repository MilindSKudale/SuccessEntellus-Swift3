//
//  ViewNotificationVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ViewNotificationVC: UIViewController {

    @IBOutlet weak var viewNote : UIView!
    @IBOutlet weak var lblCreatedDate : UILabel!
    @IBOutlet weak var lblReminderDate : UILabel!
    @IBOutlet weak var txtNoteText : UITextView!
    @IBOutlet weak var btnDismiss : UIButton!
    
    var noteData = [String : AnyObject]()
    var noteId = ""
    //var popUpDelegate: PopupProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        print(noteData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.assignDataToFields(noteData as AnyObject)
    }
    
    func designUI(){
        viewNote.layer.cornerRadius = 10.0
        viewNote.layer.borderWidth = 0.3
        viewNote.layer.borderColor = UIColor.darkGray.cgColor
        viewNote.clipsToBounds = true
        txtNoteText.isUserInteractionEnabled = true
        btnDismiss.layer.cornerRadius = btnDismiss.frame.height/2
        btnDismiss.clipsToBounds = true
    }
    
    
    @IBAction func actionDismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
//        popUpDelegate?.dismiss()
    }
    
    
    func assignDataToFields(_ data: AnyObject){
        lblCreatedDate.text = "Created on : \(data["scratchNoteCreatedDate"] as? String ?? "")"
        lblReminderDate.text = data["scratchNoteReminderDate"] as? String ?? ""
        let str = data["scratchNoteText"] as? String ?? ""
        txtNoteText.text = str.htmlToString
    }
    
}
