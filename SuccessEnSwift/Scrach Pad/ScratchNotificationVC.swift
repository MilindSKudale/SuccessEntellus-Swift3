//
//  ScratchNotificationVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ScratchNotificationVC: UIViewController {
    
    
    
    @IBOutlet weak var tblNotification : UITableView!
    @IBOutlet weak var uiView : UIView!
    
    
    var arrTodaysNotiData = [AnyObject]()
    var arrUpcomingNotiData = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        uiView.layer.cornerRadius = 10
        uiView.clipsToBounds = true
        
        self.tblNotification.tableFooterView = UIView()
        //DispatchQueue.main.sync {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.getDataFromServer()
                self.updateNoteCount()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        //}
    }
    
    @IBAction func actionClose(_ sender: UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateScratchPadList"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ScratchNotificationVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if arrTodaysNotiData.count > 0 {
                return arrTodaysNotiData.count
            }else{
                return 1
            }
            
        }else if section == 1 {
            
            if arrUpcomingNotiData.count > 0 {
                return arrUpcomingNotiData.count
            }else{
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblNotification.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScratchNotificationCell
        
        cell.lblNoNotes.isHidden = false
        cell.lblNotesText.isHidden = false
        cell.lblCreatedDate.isHidden = false
        cell.lblReminderDate.isHidden = false
        
        if indexPath.section == 0 {
            
            if arrTodaysNotiData.count > 0 {
                cell.lblNoNotes.isHidden = true
                cell.lblNotesText.isHidden = false
                cell.lblCreatedDate.isHidden = false
                cell.lblReminderDate.isHidden = false
                let str = arrTodaysNotiData[indexPath.row]["scratchNoteText"] as? String ?? ""
                cell.lblNotesText.text = str.htmlToString
                
                cell.lblCreatedDate.text = "Created on \(arrTodaysNotiData[indexPath.row]["scratchNoteCreatedDate"] as? String ?? "")"
                cell.lblReminderDate.text = "This is note on \(arrTodaysNotiData[indexPath.row]["scratchNoteReminderDate"] as? String ?? "")"
                
                let bgColor = arrTodaysNotiData[indexPath.row]["scratchNoteColor"] as? String ?? ""
                if bgColor == "" || bgColor == "white" {
                    cell.viewNotes.layer.borderWidth = 0.3
                    cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
                }
                cell.viewNotes.backgroundColor = getColor(bgColor)
                
            }else{
                cell.lblNoNotes.text = "  No today's notes available."
                cell.lblNoNotes.isHidden = false
                cell.lblNotesText.isHidden = true
                cell.lblCreatedDate.isHidden = true
                cell.lblReminderDate.isHidden = true
            }
            
            
        }else if indexPath.section == 1 {
            if arrUpcomingNotiData.count > 0 {
                cell.lblNoNotes.isHidden = true
                cell.lblNotesText.isHidden = false
                cell.lblCreatedDate.isHidden = false
                cell.lblReminderDate.isHidden = false
                let str = arrUpcomingNotiData[indexPath.row]["scratchNoteText"] as? String ?? ""
                cell.lblNotesText.text = str.htmlToString
                cell.lblCreatedDate.text = "Created on \(arrUpcomingNotiData[indexPath.row]["scratchNoteCreatedDate"] as? String ?? "")"
                cell.lblReminderDate.text = "This is note on \(arrUpcomingNotiData[indexPath.row]["scratchNoteReminderDate"] as? String ?? "")"
                
                let bgColor = arrUpcomingNotiData[indexPath.row]["scratchNoteColor"] as? String ?? ""
                if bgColor == "" || bgColor == "white" {
                    cell.viewNotes.layer.borderWidth = 0.3
                    cell.viewNotes.layer.borderColor = UIColor.lightGray.cgColor
                }
                cell.viewNotes.backgroundColor = getColor(bgColor)
                
            }else{
                cell.lblNoNotes.text = "  No upcoming notes available."
                cell.lblNoNotes.isHidden = false
                cell.lblNotesText.isHidden = true
                cell.lblCreatedDate.isHidden = true
                cell.lblReminderDate.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Scrachpad", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idViewNotificationVC") as! ViewNotificationVC
        if indexPath.section == 0 {
            if arrTodaysNotiData.count > 0 {
                vc.noteData = arrTodaysNotiData[indexPath.row] as! [String : AnyObject]
            }
        }else if indexPath.section == 1 {
            if arrUpcomingNotiData.count > 0 {
                vc.noteData = arrUpcomingNotiData[indexPath.row] as! [String : AnyObject]
            }
        }
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: true, completion: nil)
    }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let img = UIImageView()
        img.frame = CGRect.init(x: 5, y: 5, width: 25, height: 25)
        img.image = #imageLiteral(resourceName: "cft_feedback")
        img.contentMode = .center
        
        let label = UILabel()
        label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-40, height: 25)
        
        if section == 0 {
            label.text = "Today's Notes"
        }else if section == 1 {
            label.text = "Upcoming Notes"
        }
        
        headerView.backgroundColor = UIColor.groupTableViewBackground
        headerView.addSubview(img)
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
}

extension ScratchNotificationVC {
    func getDataFromServer(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getScratchNotification", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            
            self.arrTodaysNotiData = []
            self.arrUpcomingNotiData = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrTodaysNotiData = JsonDict!["todayNotes"] as! [AnyObject]
                self.arrUpcomingNotiData = JsonDict!["upcomingNotes"] as! [AnyObject]
                self.tblNotification.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblNotification.reloadData()
                OBJCOM.hideLoader()
            }
            
        };
    }
    
    func updateNoteCount(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateNotificationCount", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
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
