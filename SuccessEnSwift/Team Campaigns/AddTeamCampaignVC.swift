//
//  AddTeamCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddTeamCampaignVC: UIViewController {

    @IBOutlet weak var txtCampaignName : UITextField!
    @IBOutlet weak var txtCampaignSummery : UITextView!
    @IBOutlet weak var btnAddCampaign : UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var uiView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designUI()
    }
    
    func designUI(){
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        uiView.backgroundColor = .white
        
        txtCampaignName.layer.cornerRadius = 10.0
        txtCampaignName.layer.borderColor = UIColor.lightGray.cgColor
        txtCampaignName.layer.borderWidth = 0.3
        txtCampaignName.clipsToBounds = true
        
        txtCampaignSummery.layer.cornerRadius = 10.0
        txtCampaignSummery.layer.borderColor = UIColor.lightGray.cgColor
        txtCampaignSummery.layer.borderWidth = 0.3
        txtCampaignSummery.clipsToBounds = true
        
        btnAddCampaign.layer.cornerRadius = btnAddCampaign.frame.height/2
        btnAddCampaign.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.height/2
        btnCancel.clipsToBounds = true
        
    }
    
    @IBAction func actionCancel(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddTeamCampaign(_ sender:UIButton){
        
        if validate() == true {
            
            let dictParam = ["userId":userID,
                             "platform":"3",
                             "teamCampaignTitle":txtCampaignName.text!,
                             "teamCampaignContent":txtCampaignSummery.text!] as [String : Any]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "addTeamCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
                JsonDict, staus in
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                    NotificationCenter.default.post(name: Notification.Name("UpdateTeamCampaignVC"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }else{
                    let result = JsonDict!["result"] as! String
                    OBJCOM.setAlert(_title: "", message: result)
                    OBJCOM.hideLoader()
                }
            }
        }
    }
    
    func validate() -> Bool {
        
        if txtCampaignName.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter campaign name.")
            return false
        }
        
        return true
    }
}
