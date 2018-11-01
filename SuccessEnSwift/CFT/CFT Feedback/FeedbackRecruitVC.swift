//
//  FeedbackRecruitVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class FeedbackRecruitVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tblRecruitList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    var arrRecruitName = [String]()
    var arrRecruitImage = [String]()
    var arrAccessDate = [String]()
    var arrRecruitId = [String]()
    var arrMsgCount = [String]()
    
    var arrRecruitNameSearch = [String]()
    var arrRecruitIdSearch = [String]()
    var arrRecruitImageSearch = [String]()
    var arrRecruitAccessDateSearch = [String]()
    var arrMsgCountSearch = [String]()
    
    var isFilter = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblRecruitList.tableFooterView = UIView()
        
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
            name: NSNotification.Name(rawValue: "UpdateUIRecruits"),
            object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getRecruitList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @objc func UpdateUI(notification: NSNotification){
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getRecruitList()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getRecruitList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getRecruitListWithCount", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrRecruitName = []
            self.arrRecruitImage = []
            self.arrAccessDate = []
            self.arrRecruitId = []
            self.arrMsgCount = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let arrRecruitData = JsonDict!["result"] as! [AnyObject]
                print(arrRecruitData)
                
                for i in 0..<arrRecruitData.count {
                    self.arrRecruitName.append(arrRecruitData[i]["fullName"] as? String ?? "")
                    self.arrRecruitImage.append(arrRecruitData[i]["imgPath"] as? String ?? "")
                    self.arrAccessDate.append(arrRecruitData[i]["addDateFeedback"] as? String ?? "")
                    self.arrRecruitId.append(arrRecruitData[i]["cftAccessUserId"] as? String ?? "")
                    self.arrMsgCount.append(arrRecruitData[i]["feedbackCount"] as? String ?? "")
                }
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblRecruitList.reloadData()
        };
    }
}

extension FeedbackRecruitVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return arrRecruitNameSearch.count
        }else{
            return arrRecruitName.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblRecruitList.dequeueReusableCell(withIdentifier: "MentorCell") as! MentorCell
        cell.selectionStyle = .none
        
        if isFilter == true {
            cell.lblName.text = self.arrRecruitNameSearch[indexPath.row]
            cell.lblCount.text = self.arrMsgCountSearch[indexPath.row]
            if self.arrMsgCount[indexPath.row] == "0" {
                cell.lblCount.isHidden = true
            }else{
                cell.lblCount.isHidden = false
            }
            let avatarImg =  self.arrRecruitImageSearch[indexPath.row]
            if avatarImg != "" {
                cell.imgMentor.imageFromServerURL(urlString: avatarImg)
            }else{
                cell.imgMentor.image = #imageLiteral(resourceName: "profile")
            }
        }else{
            cell.lblName.text = self.arrRecruitName[indexPath.row]
            cell.lblCount.text = self.arrMsgCount[indexPath.row]
            if self.arrMsgCount[indexPath.row] == "0" {
                cell.lblCount.isHidden = true
            }else{
                cell.lblCount.isHidden = false
            }
            let avatarImg =  self.arrRecruitImage[indexPath.row]
            if avatarImg != "" {
                cell.imgMentor.imageFromServerURL(urlString: avatarImg)
            }else{
                cell.imgMentor.image = #imageLiteral(resourceName: "profile")
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = RecruitConversationVC()
        if isFilter {
            chatView.receiverName = self.arrRecruitNameSearch[indexPath.row]
            chatView.avatarImage  =  self.arrRecruitImageSearch[indexPath.row]
            chatView.cftAccessUserId = self.arrRecruitIdSearch[indexPath.row]
        }else{
            chatView.receiverName = self.arrRecruitName[indexPath.row]
            chatView.avatarImage  =  self.arrRecruitImage[indexPath.row]
            chatView.cftAccessUserId = self.arrRecruitId[indexPath.row]
        }
        let chatNavigationController = UINavigationController(rootViewController: chatView)
        present(chatNavigationController, animated: true, completion: nil)
    }
}
extension FeedbackRecruitVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        self.arrRecruitNameSearch.removeAll()
        self.arrRecruitIdSearch.removeAll()
        self.arrRecruitImageSearch.removeAll()
        self.arrRecruitAccessDateSearch.removeAll()
        self.arrMsgCountSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< self.arrRecruitName.count {
                let strGName = self.arrRecruitName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                if strGName != nil {
                    self.arrRecruitNameSearch.append(self.arrRecruitName[i])
                    self.arrRecruitIdSearch.append(arrRecruitId[i])
                    self.arrRecruitImageSearch.append(self.arrRecruitImage[i])
                    self.arrRecruitAccessDateSearch.append(arrAccessDate[i])
                    self.arrMsgCountSearch.append(self.arrMsgCount[i])
                }
            }
        } else {
            isFilter = false
        }
        tblRecruitList.reloadData()
    }
}

