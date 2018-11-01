//
//  FeedbackMentorVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class FeedbackMentorVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tblMentorList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    var arrMentorName = [String]()
    var arrMentorImage = [String]()
    var arrAccessDate = [String]()
    var arrMentorId = [String]()
    var arrMsgCount = [String]()
    
    var arrMentorNameSearch = [String]()
    var arrMentorIdSearch = [String]()
    var arrMentorImageSearch = [String]()
    var arrMentorAccessDateSearch = [String]()
    var arrMsgCountSearch = [String]()
    
    var isFilter = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMentorList.tableFooterView = UIView()
        
        txtSearch.leftViewMode = UITextFieldViewMode.always
        txtSearch.layer.cornerRadius = txtSearch.frame.size.height/2
        txtSearch.layer.borderColor = APPGRAYCOLOR.cgColor
        txtSearch.layer.borderWidth = 1.0
        txtSearch.clipsToBounds = true
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        let image = #imageLiteral(resourceName: "icons8-search")
        
        imageView.image = image
        uiView.addSubview(imageView)
        txtSearch.leftView = uiView
        self.txtSearch.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.UpdateUI),
            name: NSNotification.Name(rawValue: "UpdateUIMentor"),
            object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getMentorList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateUI(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getMentorList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getMentorList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getMentorListWithCount", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrMentorName = []
            self.arrMentorImage = []
            self.arrAccessDate = []
            self.arrMentorId = []
            self.arrMsgCount = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrMentorData = JsonDict!["result"] as! [AnyObject]
                print(arrMentorData)
                
                for i in 0..<arrMentorData.count {
                    self.arrMentorName.append(arrMentorData[i]["fullName"] as? String ?? "")
                    self.arrMentorImage.append(arrMentorData[i]["imgPath"] as? String ?? "")
                    self.arrAccessDate.append(arrMentorData[i]["addDateFeedback"] as? String ?? "")
                    self.arrMentorId.append(arrMentorData[i]["cftAccessUserId"] as? String ?? "")
                    self.arrMsgCount.append(arrMentorData[i]["feedbackCount"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblMentorList.reloadData()
        };
    }
}

extension FeedbackMentorVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return arrMentorNameSearch.count
        }else{
            return arrMentorName.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblMentorList.dequeueReusableCell(withIdentifier: "MentorCell") as! MentorCell
        cell.selectionStyle = .none
        
        if isFilter == true {
            cell.lblName.text = self.arrMentorNameSearch[indexPath.row]
            cell.lblCount.text = self.arrMsgCountSearch[indexPath.row]
            if self.arrMsgCount[indexPath.row] == "0" {
                cell.lblCount.isHidden = true
            }else{
                cell.lblCount.isHidden = false
            }
            let avatarImg =  self.arrMentorImageSearch[indexPath.row]
            if avatarImg != "" {
                cell.imgMentor.imageFromServerURL(urlString: avatarImg)
            }else{
                cell.imgMentor.image = #imageLiteral(resourceName: "profile")
            }
        }else{
            cell.lblName.text = self.arrMentorName[indexPath.row]
            cell.lblCount.text = self.arrMsgCount[indexPath.row]
            if self.arrMsgCount[indexPath.row] == "0" {
                cell.lblCount.isHidden = true
            }else{
                cell.lblCount.isHidden = false
            }
            let avatarImg =  self.arrMentorImage[indexPath.row]
            if avatarImg != "" {
                cell.imgMentor.imageFromServerURL(urlString: avatarImg)
            }else{
                cell.imgMentor.image = #imageLiteral(resourceName: "profile")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFilter {
            let chatView = MentorConversationVC()
            chatView.receiverName = self.arrMentorNameSearch[indexPath.row]
            chatView.avatarImage  =  self.arrMentorImageSearch[indexPath.row]
            chatView.cftAccessUserId = self.arrMentorIdSearch[indexPath.row]
            let chatNavigationController = UINavigationController(rootViewController: chatView)
            present(chatNavigationController, animated: true, completion: nil)
        }else{
            let chatView = MentorConversationVC()
            chatView.receiverName = self.arrMentorName[indexPath.row]
            chatView.avatarImage =  self.arrMentorImage[indexPath.row]
            chatView.cftAccessUserId = self.arrMentorId[indexPath.row]
            let chatNavigationController = UINavigationController(rootViewController: chatView)
            present(chatNavigationController, animated: true, completion: nil)
        }
    }
}
extension FeedbackMentorVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        self.arrMentorNameSearch.removeAll()
        self.arrMentorIdSearch.removeAll()
        self.arrMentorImageSearch.removeAll()
        self.arrMentorAccessDateSearch.removeAll()
        self.arrMsgCountSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< self.arrMentorName.count {
                let strGName = self.arrMentorName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if strGName != nil {
                    self.arrMentorNameSearch.append(self.arrMentorName[i])
                    self.arrMentorIdSearch.append(arrMentorId[i])
                    self.arrMentorImageSearch.append(self.arrMentorImage[i])
                    self.arrMentorAccessDateSearch.append(arrAccessDate[i])
                    self.arrMsgCountSearch.append(self.arrMsgCount[i])
                }
            }
        } else {
            isFilter = false
        }
        tblMentorList.reloadData()
    }
}
