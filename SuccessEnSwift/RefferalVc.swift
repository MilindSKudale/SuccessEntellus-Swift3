//
//  RefferalVc.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 18/12/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import MessageUI
//import CTSlidingUpPanel

class RefferalVc: SliderVC, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
   
    @IBOutlet var bgView : UIView!
    @IBOutlet var lblLink : UILabel!
    @IBOutlet var btnShareReferalLink : UIButton!
    @IBOutlet var btnSendReferalLink : UIButton!
    @IBOutlet var btnSeeCredits : UIButton!
   // @IBOutlet var tblInput : UITableView!
    
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPhone : UITextField!
    
    var sharableLink = ""
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblLink.text = ""
        self.sharableLink = ""
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        btnShareReferalLink.layer.cornerRadius = 5.0
        btnShareReferalLink.clipsToBounds = true
        btnSendReferalLink.layer.cornerRadius = 5.0
        btnSendReferalLink.clipsToBounds = true
        txtEmail.layer.cornerRadius = 5.0
        txtEmail.layer.borderColor = APPGRAYCOLOR.cgColor
        txtEmail.layer.borderWidth = 0.5
        txtEmail.clipsToBounds = true
        txtPhone.layer.cornerRadius = 5.0
        txtPhone.layer.borderColor = APPGRAYCOLOR.cgColor
        txtPhone.layer.borderWidth = 0.5
        txtPhone.clipsToBounds = true
        //self.tblInput.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getReferralLink()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionShareLink(_ sender: UIButton) {

        if self.sharableLink != "" {
            let objectsToShare:URL = URL(string: self.sharableLink)!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook,UIActivityType.postToTwitter,UIActivityType.mail]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func actionSendShareLink(_ sender: UIButton) {
//        if arrEmailKeys.count > 0 || arrPhoneKeys.count > 0 {
//            let emails = arrEmailKeys.joined(separator: ",")
//            let phones = arrPhoneKeys.joined(separator: ",")
//            if OBJCOM.isConnectedToNetwork(){
//                OBJCOM.setLoader()
//                self.sendReferralLink(emaiAddress: emails, phNum: phones)
//            }else{
//                OBJCOM.NoInternetConnectionCall()
//            }
//        }else{
//           OBJCOM.setAlert(_title: "", message: "Please enter email or phone number.")
//        }
        
        if validation() == true {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.sendReferralLink(emaiAddress: self.txtEmail.text!, phNum: self.txtPhone.text!)
            }else{
                OBJCOM.NoInternetConnectionCall()
            }

        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        let i = Int(arrEmailPhCount[textField.tag])
//        if arrEmailKeys.count > 0 {
//            arrEmailKeys.remove(at: i)
//        }
//        if arrPhoneKeys.count > 0 {
//            arrPhoneKeys.remove(at: i)
//        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        let i = Int(arrEmailPhCount[textField.tag])
//        let index = IndexPath(row: i, section: 0)
//        let cell = tblInput.cellForRow(at: index) as! EmailCell
//        if validation(cell: cell) == true {
//            arrEmailKeys.append(cell.txtEmail.text!)
//            arrPhoneKeys.append(cell.txtPhone.text!)
//        }
    }
    
    @IBAction func actionShowCredits(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Refferal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCreditListVC") as! CreditListVC
        
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated:true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}

//extension RefferalVc : UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return arrEmailPhCount.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tblInput.dequeueReusableCell(withIdentifier: "EmailCell") as! EmailCell
//
////        if arrEmailKeys.count > 0 || arrPhoneKeys.count > 0 {
////            cell.txtEmail.text = arrEmailPhCount[indexPath.row]
////            cell.txtPhone.text = arrEmailPhCount[indexPath.row]
////        }else{
//            cell.txtEmail.text = ""
//            cell.txtPhone.text = ""
////        }
//
//        cell.txtEmail.tag = indexPath.row
//        cell.txtPhone.tag = indexPath.row
//        cell.btnAddEmailField.tag = indexPath.row
//        cell.btnAddEmailField.addTarget(self, action: #selector(actionAddEmailFields(_:)), for: .touchUpInside)
//
//        return cell
//
//    }
//
//    @objc func actionAddEmailFields(_ sender : UIButton) {
//
//        var index = IndexPath()
//        var cell = EmailCell()
//        if arrEmailPhCount.count == 1 {
//            index = IndexPath(row:0, section: 0)
//            cell = tblInput.cellForRow(at: index) as! EmailCell
//        }else{
//            let i = Int(arrEmailPhCount[sender.tag])
//            index = IndexPath(row:i, section: 0)
//            cell = tblInput.cellForRow(at: index) as! EmailCell
//        }
//
//        if validation(cell : cell ) == true {
//            sender.isSelected = !sender.isSelected
//            if sender.isSelected {
//                //if !arrEmailKeys.contains(cell.txtEmail.text!) {
//                    arrEmailKeys.append(cell.txtEmail.text!)
//               // }
//
//                //if !arrPhoneKeys.contains(cell.txtPhone.text!) {
//                    arrPhoneKeys.append(cell.txtPhone.text!)
//               // }
//
//                //if !arrPhoneKeys.contains(cell.txtPhone.text!) {
//                    arrPhoneKeys.append(cell.txtPhone.text!)
//               // }
//
//                arrEmailPhCount.append(sender.tag + 1)
//                //cell.btnAddEmailField.tag = sender.tag+1
//                self.tblInput.beginUpdates()
//                let indexPath:IndexPath = IndexPath(row: arrEmailPhCount.count - 1, section: 0)
//                self.tblInput.insertRows(at: [indexPath], with: .right)
//                self.tblInput.endUpdates()
//                //self.tblInput.reloadData()
//            }else{
//                if arrEmailPhCount.count == 1 {
//                    sender.isSelected = false
//                    cell.txtEmail.text = ""
//                    cell.txtPhone.text = ""
//                    arrEmailKeys = []
//                    arrPhoneKeys = []
//                    tblInput.reloadData()
//                    return
//                }
//
//                arrEmailKeys.remove(at: sender.tag)
//                arrPhoneKeys.remove(at: sender.tag)
//                arrEmailPhCount.remove(at: sender.tag)
//
//                self.tblInput.beginUpdates()
//                let indexPath:IndexPath = IndexPath(row: sender.tag, section: 0)
//                self.tblInput.deleteRows(at: [indexPath], with: .left)
//                self.tblInput.endUpdates()
//               // self.tblInput.reloadData()
//            }
//        }
//        print(arrEmailKeys)
//        print(arrPhoneKeys)
//    }
//

//
//    @objc func actionAddPhoneFields(_ sender : UIButton) {
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//            arrPhoneKeys.append("")
//            self.tblInput.beginUpdates()
//            let indexPath:IndexPath = IndexPath(row: self.arrPhoneKeys.count-1, section: 1)
//            self.tblInput.insertRows(at: [indexPath], with: .right)
//            self.tblInput.endUpdates()
//        }else{
//            arrPhoneKeys.remove(at: sender.tag)
//            self.tblInput.beginUpdates()
//            let indexPath:IndexPath = IndexPath(row: sender.tag, section: 1)
//            self.tblInput.deleteRows(at: [indexPath], with: .left)
//            self.tblInput.endUpdates()
//        }
//    }
//}

extension RefferalVc {
    func getReferralLink(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getReferralLink", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.lblLink.text = result["link"] as? String ?? ""
                self.sharableLink = result["link"] as? String ?? ""
                
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func sendReferralLink(emaiAddress: String, phNum:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "emailReferral":emaiAddress,
                         "phoneReferral":phNum]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "addReferrals", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                OBJCOM.setAlert(_title: "", message: result as! String)
                self.txtEmail.text = ""
                self.txtPhone.text = ""
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func validation() -> Bool {
       // var valid = true
        
        if txtEmail.text!.isEmpty && txtPhone.text!.isEmpty {
            OBJCOM.setAlert(_title: "", message: "Enter email or phone number.")
            return false
        }else if !txtEmail.text!.isEmpty && txtPhone.text!.isEmpty {
            if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
                OBJCOM.setAlert(_title: "", message: "Enter valid email")
                return false
            }
        }else if txtEmail.text!.isEmpty && !txtPhone.text!.isEmpty {
            if txtPhone.text!.length < 5 || txtPhone.text!.length > 19 {
                OBJCOM.setAlert(_title: "", message: "Phone number should be grater than 5 digits and less than 19 digits.")
                return false
            }
        }else if !txtEmail.text!.isEmpty && !txtPhone.text!.isEmpty {
            if OBJCOM.validateEmail(uiObj: txtEmail.text!) == false {
                OBJCOM.setAlert(_title: "", message: "Enter valid email")
                return false
            }else if txtPhone.text!.length < 5 || txtPhone.text!.length > 19 {
                OBJCOM.setAlert(_title: "", message: "Phone number should be grater than 5 digits and less than 19 digits.")
                return false
            }
        }
        
        return true
    }
   
}
