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
    @IBOutlet weak var lblRepeat : UILabel!
    @IBOutlet weak var txtNoteText : UITextView!
    @IBOutlet weak var btnDismiss : UIButton!
    @IBOutlet weak var btnEdit : UIButton!
    
    var noteData = [String : AnyObject]()
    var noteId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
        print(noteData)
        txtNoteText.layer.borderColor = APPGRAYCOLOR.cgColor
        txtNoteText.layer.borderWidth = 0.3
        txtNoteText.layer.cornerRadius = 10
        txtNoteText.clipsToBounds = true
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
        
        let repeatFlag = data["scratchNoteReminderRepeat"] as? String ?? "0"
        var repeatVal = ""
        if repeatFlag == "0" {
            repeatVal = "Never"
        }else if repeatFlag == "1" {
            repeatVal = "Daily"
        }else if repeatFlag == "2" {
            repeatVal = "Weekly"
        }
        
        self.lblRepeat.text = "Repeat on - \(repeatVal)"
        
        let noteColor = data["scratchNoteColor"] as? String ?? "0"
        self.viewNote.backgroundColor = getColor(noteColor)
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
    
    func getColor(_ color:String) -> UIColor {
        
        if color == "blue" {
            return UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0)
        }else if color == "pink" {
            return UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0)
        }else if color == "green" {
            return UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0)
        }else if color == "orange" {
            return UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0)
        }else if color == "violet" {
            return UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0)
        }else if color == "white"{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }else{
            return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        }
    }
}
