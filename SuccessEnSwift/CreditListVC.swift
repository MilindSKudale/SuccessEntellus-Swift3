//
//  CreditListVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 19/12/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CreditListVC: UIViewController {
    
    @IBOutlet var tblCreditList : UITableView!
    @IBOutlet var lblCreditTotal : UILabel!
    @IBOutlet var noDateView : UIView!

    var arrName = [String]()
    var arrEmail = [String]()
    var arrDate = [String]()
    var arrAmount = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.tblCreditList.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getReferralDetails()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getReferralDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getReferralList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrName = []
            self.arrEmail = []
            self.arrDate = []
            self.arrAmount = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [String:AnyObject]
                let refrenceDetails = result["refrenceDetails"] as! [AnyObject]
                let totalCreditAmt = "\(result["totalCreditAmt"]!)"
                self.lblCreditTotal.text = "Credit Total : $\(totalCreditAmt)"
                if refrenceDetails.count > 0 {
                    
                    self.arrName = refrenceDetails.compactMap { $0["name"] as? String }
                    self.arrEmail = refrenceDetails.compactMap { $0["email"] as? String }
                    self.arrDate = refrenceDetails.compactMap { $0["cretedDate"] as? String }
                    self.arrAmount = refrenceDetails.compactMap { $0["referCreditAmt"] as? String }
                    
                }
                if refrenceDetails.count > 0 {
                    self.noDateView.isHidden = true
                }else{
                    self.noDateView.isHidden = false
                }
                self.tblCreditList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.noDateView.isHidden = false
                self.tblCreditList.reloadData()
                OBJCOM.hideLoader()
            }
        };
    }


}

extension CreditListVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblCreditList.dequeueReusableCell(withIdentifier: "PhoneCell") as! PhoneCell
        cell.lblName.text = self.arrName[indexPath.row]
        cell.lblEmail.text = "Email : \(self.arrEmail[indexPath.row])"
        cell.lblDate.text = "Date : \(self.arrDate[indexPath.row])"
        cell.lblCreditAmount.text = "$\(self.arrAmount[indexPath.row])"
        return cell
    }
}
