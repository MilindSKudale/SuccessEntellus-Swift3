//
//  DailyTopTenVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class DailyTopTenVC: SliderVC, UITextFieldDelegate {
    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet var viewSearch : UIView!
    @IBOutlet var lblTitle : UILabel!
    
    var arrScoreData = [AnyObject]()
    var arrFirstName = [String]()
    var arrProfileImg = [String]()
    var arrScore = [String]()
    
    var arrFirstNameSearch = [String]()
    var arrProfileImgSearch = [String]()
    var arrScoreSearch = [String]()
    
    var isFilter = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Top 10 Score"
        
        self.tblList.tableFooterView = UIView()
        
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
        
        
        let yesterday = Date().yesterday
        let format = DateFormatter()
        format.dateFormat = "MMM-dd-yyyy"
        let strYesterday = format.string(from: yesterday)
        
        
        self.lblTitle.text = "Daily Top 10 Score - \(strYesterday)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDailyScoreData()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionMenu(_ sender:AnyObject) {
    
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionWeeklyArchive = UIAlertAction(title: "Weekly Archive", style: .default)
        {
            UIAlertAction in
            
            let storyboard = UIStoryboard(name: "DailyTopTen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idWeeklyArchiveVC") as! WeeklyArchiveVC
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
        }
        actionWeeklyArchive.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionWeeklyArchive)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
       
    }
}

extension DailyTopTenVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.arrFirstNameSearch.count
        }else {
            return self.arrFirstName.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTopTenCell
        if isFilter {
            cell.lblRecruitName.text = self.arrFirstNameSearch[indexPath.row]
            cell.lblScore.text = self.arrScoreSearch[indexPath.row]
//            let pic = self.arrProfileImgSearch[indexPath.row]
//            if pic != "" || pic != "https://successentellus.com/assets/uploads/profile/" {
//                cell.imgProfile.imageFromServerURL(urlString: pic)
//            }else{
//                cell.imgProfile.image = #imageLiteral(resourceName: "profile")
//            }
        }else{
            cell.lblRecruitName.text = self.arrFirstName[indexPath.row]
            cell.lblScore.text = self.arrScore[indexPath.row]
//            let pic = self.arrProfileImg[indexPath.row]
//            if pic != "" || pic != "https://successentellus.com/assets/uploads/profile/" {
//                cell.imgProfile.imageFromServerURL(urlString: pic)
//            }else{
//                cell.imgProfile.image = #imageLiteral(resourceName: "profile")
//            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

extension DailyTopTenVC {
    func getDailyScoreData(){
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "type":"today",
                         "scoreDate":""]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "dailyTopTenScore", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                self.arrFirstName = []
                self.arrProfileImg = []
                self.arrScore = []
                
                self.arrScoreData = JsonDict!["result"] as! [AnyObject]
                
                if self.arrScoreData.count > 0 {
                    self.arrFirstName = self.arrScoreData.flatMap { $0["recruitUserName"] as? String }
                    self.arrProfileImg = self.arrScoreData.flatMap { $0["profile_pic"] as? String }
                    self.arrScore = self.arrScoreData.flatMap { $0["recruitUserScoreValue"] as? String }
                }
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        }
    }
}

extension DailyTopTenVC {
    //Search code
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.txtSearch.addTarget(self, action: #selector(self.searchRecordsAsPerText(_ :)), for: .editingChanged)
        isFilter = true
        return isFilter
    }
    
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        arrFirstNameSearch.removeAll()
        arrProfileImgSearch.removeAll()
        arrScoreSearch.removeAll()
        
        if textfield.text?.count != 0 {
            for i in 0 ..< arrScoreData.count {
                let strfName = arrFirstName[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                let strScore = arrScore[i].lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                if strfName != nil || strScore != nil {
                    arrFirstNameSearch.append(arrFirstName[i])
                    arrProfileImgSearch.append(arrProfileImg[i])
                    arrScoreSearch.append(arrScore[i])
                }
            }
        } else {
            isFilter = false
        }
        tblList.reloadData()
    }
}


extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
