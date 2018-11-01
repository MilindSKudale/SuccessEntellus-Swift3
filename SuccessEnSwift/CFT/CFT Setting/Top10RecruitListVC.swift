//
//  Top10RecruitListVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class Top10RecruitListVC: UIViewController {
    
    @IBOutlet var tblList : UITableView!
    @IBOutlet var tblListHeight : NSLayoutConstraint!
    @IBOutlet var btnViewAll : UIButton!
    
    var arrAccessId = [String]()
    var arrImg = [String]()
    var arrName = [String]()
    var arrCount = [String]()
    
    var allFlag = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        btnViewAll.layer.cornerRadius = 5.0
        btnViewAll.clipsToBounds = true
        self.tblListHeight.constant = 54.0
        self.tblList.tableFooterView = UIView()
        self.btnViewAll.setTitle("View All", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDataFromServer(limit: "10")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDataFromServer(limit : String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "limit":limit]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "showUserTopScore", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrAccessId = []
            self.arrName = []
            self.arrCount = []
            self.arrImg = []
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let data = JsonDict!["result"] as! [AnyObject]
               
                for i in 0..<data.count {
                    self.arrAccessId.append(data[i]["recruitUserId"] as? String ?? "")
                    self.arrName.append(data[i]["recruitUserName"] as? String ?? "")
                    self.arrCount.append(data[i]["recruitUserScoreValue"] as? String ?? "")
                    self.arrImg.append(data[i]["recruitUserImgPath"] as? String ?? "")
                }
                
                if data.count > 10 {
                    self.tblListHeight.constant = 54*10
                }else if data.count == 0 {
                    self.tblListHeight.constant = 54.0
                }else{
                    self.tblListHeight.constant = CGFloat(54*data.count)
                }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
            self.tblList.reloadData()
        };
    }
    
    @IBAction func actionViewAll(_ sender:UIButton){
        if btnViewAll.titleLabel?.text == "View All" {
            self.btnViewAll.setTitle("View Top-10", for: .normal)
            self.getDataFromServer(limit: "")
        }else{
            self.btnViewAll.setTitle("View All", for: .normal)
            self.getDataFromServer(limit: "10")
        }
    }
}

extension Top10RecruitListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrName.count == 0 {
            return 1
        }else{
            return arrName.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! TopRecruitCell
        
        if self.arrName.count == 0 {
            cell.lblName.isHidden = true
            cell.lblCount.isHidden = true
            cell.imgView.isHidden = true
            cell.lblNoRecord.isHidden = false
        }else{
            cell.lblName.isHidden = false
            cell.lblCount.isHidden = false
            cell.imgView.isHidden = false
            cell.lblNoRecord.isHidden = true
            
            cell.lblName.text = self.arrName[indexPath.row]
            cell.lblCount.text = self.arrCount[indexPath.row]
            
            let pic = self.arrImg[indexPath.row]
            if pic != "" {
                cell.imgView.imageFromServerURL(urlString: pic)
            }else{
                cell.imgView.image = #imageLiteral(resourceName: "noImg")
            }
            
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrName.count > 0 {
            
        }
    }
    
}
