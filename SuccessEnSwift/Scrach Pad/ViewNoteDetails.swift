//
//  ViewNoteDetails.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ViewNoteDetails: UIViewController {
    
    @IBOutlet weak var viewNote : UIView!
    @IBOutlet weak var lblCreatedDate : UILabel!
    @IBOutlet weak var lblReminderDate : UILabel!
    @IBOutlet weak var txtNoteText : UITextView!
    @IBOutlet weak var btnDismiss : UIButton!
    @IBOutlet weak var btnEdit : UIButton!
    
    var noteData = [String : AnyObject]()
    var noteId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        print(noteData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getScratchnoteById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func designUI(){
        viewNote.layer.cornerRadius = 10.0
        viewNote.layer.borderWidth = 0.3
        viewNote.layer.borderColor = UIColor.darkGray.cgColor
        viewNote.clipsToBounds = true
        txtNoteText.isUserInteractionEnabled = true
        btnDismiss.layer.cornerRadius = btnDismiss.frame.height/2
        btnDismiss.clipsToBounds = true
        btnEdit.layer.cornerRadius = btnEdit.frame.height/2
        btnEdit.clipsToBounds = true
    }
   

    @IBAction func actionEdit(_ sender:UIButton){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateScratchPadList),
            name: NSNotification.Name(rawValue: "UpdateScratchPadList1"),
            object: nil)
        
        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditNoteDetailsVC") as! EditNoteDetailsVC
        vc.noteId = noteData["scratchNoteId"] as? String ?? ""
        vc.isView = true
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionDismiss(_ sender:UIButton){
       
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func UpdateScratchPadList(notification: NSNotification){
         NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
    }

    
    func assignDataToFields(_ data: AnyObject){
        lblCreatedDate.text = "Created on : \(data["scratchNoteCreatedDate"] as? String ?? "")"
        lblReminderDate.text = data["scratchNoteReminderDate"] as? String ?? ""
        let str = data["scratchNoteText"] as? String ?? ""
        txtNoteText.text = str.htmlToString
    }
    
    func getScratchnoteById(){
        
        if noteId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteId":noteId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.assignDataToFields(result)
                self.noteData = result as! [String : AnyObject]
                OBJCOM.hideLoader()
            }else{
                self.noteData = [:]
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
}
