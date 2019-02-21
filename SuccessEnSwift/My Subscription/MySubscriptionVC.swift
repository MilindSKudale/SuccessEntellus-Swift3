//
//  MySubscriptionVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 04/01/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class MySubscriptionVC : SliderVC {
    @IBOutlet var bgView : UIView!
    @IBOutlet var lblPlanName : UILabel!
    @IBOutlet var lblStartDate : UILabel!
    @IBOutlet var lblEndDate : UILabel!
    @IBOutlet var lblSubInstruction : UILabel!
    @IBOutlet var lblFooterLine : UILabel!
    @IBOutlet var lblCustomPackageNames : UILabel!
    @IBOutlet var lblNextMonthCycleDate : UILabel!
    @IBOutlet var lblMonthlySubRenewalDate : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.layer.cornerRadius = 10.0
        
        self.lblFooterLine.isHidden = true
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDataFromServer(){
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMySubscription", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let result = JsonDict! as [String : AnyObject]
            print(result)
            let planName = result["subscribePlanName"] as! String
            let planAmnt = result["subscribePlanAmt"] as? String ?? "0"
            let planDuration = result["planDuation"] as! String
            let planStartDt = result["subscriptionStartDate"] as! String
            let planEndDt = result["subscriptionEndDate"] as! String
            let planMonthlySubRenewalDate = result["monthlySubRenewalDate"] as! String
            let planNextMonthlyCycleDate = result["nextMonthlyCycleDate"] as! String
            let upgradeMessage = result["upgradeMessage"] as! String
            let customPack = result["customPackageNames"] as! String
            
            let plan = "\(planName) - $\(planAmnt)/\(planDuration)"
            self.lblPlanName.text = plan.uppercased()
            if customPack == "" {
                self.lblCustomPackageNames.text = ""
            }else{
                self.lblCustomPackageNames.text = customPack
            }
            
            self.lblStartDate.text = "Subscription start date : \(planStartDt)"
            
            if planEndDt == "" {
                self.lblEndDate.text = ""
            }else{
                if planDuration == "12 Months" {
                    self.lblEndDate.text = "Subscription end date : \(planEndDt)"
                }else{
                    self.lblEndDate.text = ""
                }
            }
            
            if planMonthlySubRenewalDate == "" {
                self.lblMonthlySubRenewalDate.text = ""
            }else{
                self.lblMonthlySubRenewalDate.text = "Next monthly subscription renewal date : \(planMonthlySubRenewalDate)"
            }
            
            if planNextMonthlyCycleDate == "" {
                self.lblNextMonthCycleDate.text = ""
            }else{
                self.lblNextMonthCycleDate.text = "Next monthly cycle : \(planNextMonthlyCycleDate)"
            }
            
            
            if upgradeMessage == "" {
                self.lblSubInstruction.text = ""
                self.lblFooterLine.isHidden = true
            }else{
                self.lblFooterLine.isHidden = false
                self.lblSubInstruction.text = upgradeMessage
            }
            OBJCOM.hideLoader()
        }
    }

}
