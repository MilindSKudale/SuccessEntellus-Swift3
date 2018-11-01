//
//  CreateNoteView.swift
//  ScrachPadDemo
//
//  Created by Milind Kudale on 12/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var arrNotesColor = [UIColor(red:1.00, green:0.76, blue:0.86, alpha:1.0), UIColor(red:0.62, green:0.88, blue:0.99, alpha:1.0), UIColor(red:0.85, green:1.00, blue:0.83, alpha:1.0), UIColor(red:1.00, green:0.84, blue:0.76, alpha:1.0), UIColor(red:0.87, green:0.85, blue:1.00, alpha:1.0), UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)]

class CreateNoteView: UIViewController {
    
    @IBOutlet weak var viewNote : UIView!
    @IBOutlet weak var txtTitle : UITextField!
    @IBOutlet weak var txtViewNote : GrowingTextView!
    @IBOutlet weak var viewNoteOptions : UIView!
    @IBOutlet weak var btnAddNote : UIButton!
    
    @IBOutlet weak var btnSetDate : UIButton!
    @IBOutlet weak var btnSetTime : UIButton!
    @IBOutlet weak var btnSetColor : UIButton!
    
     @IBOutlet var stackBtn : UIStackView!
     @IBOutlet var stackBtnR : UIButton!
     @IBOutlet var stackBtnB : UIButton!
     @IBOutlet var stackBtnG : UIButton!
     @IBOutlet var stackBtnV : UIButton!
     @IBOutlet var stackBtnO : UIButton!
    // @IBOutlet var stackBtnBlack : UIButton!
     @IBOutlet var stackBtnWhite : UIButton!
    
    var setDate = ""
    var setTime = ""
    var setColor = ""
    var arrStackBtn = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI(){
        viewNote.layer.cornerRadius = 10.0
        viewNote.layer.borderWidth = 0.3
        viewNote.layer.borderColor = UIColor.darkGray.cgColor
        viewNote.clipsToBounds = true
        
        btnSetDate.layer.cornerRadius = 5.0
        btnSetDate.layer.borderWidth = 0.3
        btnSetDate.layer.borderColor = UIColor.darkGray.cgColor
        btnSetDate.clipsToBounds = true
        
        btnSetTime.layer.cornerRadius = 5.0
        btnSetTime.layer.borderWidth = 0.3
        btnSetTime.layer.borderColor = UIColor.darkGray.cgColor
        btnSetTime.clipsToBounds = true

        btnAddNote.layer.cornerRadius = btnAddNote.frame.height/2
        btnAddNote.clipsToBounds = true
        
        txtViewNote.minHeight = self.view.frame.height - 280
        
        arrStackBtn = [stackBtnR, stackBtnB, stackBtnG, stackBtnO, stackBtnV, stackBtnWhite]
        
        for i in 0 ..< arrStackBtn.count {
            arrStackBtn[i].backgroundColor = arrNotesColor[i]
            arrStackBtn[i].layer.cornerRadius = arrStackBtn[i].frame.height/2
            arrStackBtn[i].layer.borderColor = UIColor.lightGray.cgColor
            arrStackBtn[i].layer.borderWidth = 0.3
            
            arrStackBtn[i].clipsToBounds = true
            if i == arrStackBtn.count - 1 {
                arrStackBtn[i].isSelected = true
                
            }else{
                arrStackBtn[i].isSelected = false
            }
            
        }
        let dt = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        setDate = formatter.string(from: dt)
        formatter.dateFormat = "hh:mm a"
        setTime = formatter.string(from: dt)
        
        self.btnSetDate.setTitle(setDate, for: .normal)
        self.btnSetTime.setTitle(setTime, for: .normal)
        self.setColor = ""
    }
    
    
    
    @IBAction func actionSetDate(_ sender:UIButton){
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setDate = formatter.string(from: dt)
            }
        }
       
    }
    
    @IBAction func actionSetTime(_ sender:UIButton){
        
        DatePickerDialog().show("", doneButtonTitle: "Set", cancelButtonTitle: "Cancel", minimumDate: Date(), maximumDate: nil, datePickerMode: .time) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm:ss a"
                sender.setTitle(formatter.string(from: dt), for: .normal)
                self.setTime = formatter.string(from: dt)
            }
        }
        
    }
    
    @IBAction func actionSetColorRed(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "pink"
    }
    
    @IBAction func actionSetColorBlue(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "blue"
    }
    
    @IBAction func actionSetColorGreen(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "green"
    }
    
    @IBAction func actionSetColorOrange(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "orange"
    }
    
    @IBAction func actionSetColorViolet(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "violet"
    }
    
    @IBAction func actionSetColorDefault(_ sender:UIButton){
        updateButton(sender)
        self.setColor = "white"
    }
    
    
    func updateButton(_ sender: UIButton){
        arrStackBtn.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddNote(_ sender:UIButton){
        if txtViewNote.text != "" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                actionAddNoteAPI()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }else{
            OBJCOM.setAlert(_title: "", message: "Please write contents in note.")
        }
    }
    
}

extension CreateNoteView {
    func actionAddNoteAPI(){
        
        print(txtViewNote.text)
        print(String(txtViewNote.text))
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "scratchNoteText":String(txtViewNote.text).withoutHtmlTags,
                         "scratchNoteColor":setColor,
                         "scratchNoteReminderDate":setDate,
                         "scratchNoteReminderTime":setTime] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addScratchNote", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["IsSuccess"] as AnyObject
                print(result)
                NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
                self.dismiss(animated: true, completion: nil)
                
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.hideLoader()
            }
            
        };
    }
}

extension String {
    var withoutHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
