//
//  AddCustomTagPopup.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 05/02/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class AddCustomTagPopup: UIViewController {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var txtAddTag : UITextField!
    @IBOutlet var btnAdd : UIButton!
    @IBOutlet var tblTagList : UITableView!
    
    var arrTagName = [String]()
    var arrTagId = [String]()
    var arrTagIdPredefine = [String]()
    
    var contact_id = ""
    var crmFlag = ""
    var tagName = ""
    var tagId = ""
    var isUpdate = false

    override func viewDidLoad() {
        super.viewDidLoad()
         designUI()
    }
    
    func designUI(){
        bgView.layer.cornerRadius = 10.0
        btnAdd.layer.cornerRadius = 5.0
        bgView.clipsToBounds = true
        btnAdd.clipsToBounds = true
        tblTagList.tableFooterView = UIView()
        isUpdate = false
        self.btnAdd.setTitle("Add", for: .normal)
        getCategoryList()
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddTag(_ sender:UIButton){
        if isUpdate == false {
            if self.txtAddTag.text != ""{
                let tagName = ["tagName":self.txtAddTag.text!,
                               "contact_id":contact_id]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ADDCUSTOMTAG"), object: nil, userInfo: tagName)
                self.dismiss(animated: true, completion: nil)
            }else{
                OBJCOM.setAlert(_title: "", message: "Please add your custom tag name.")
            }
        }else{
            if self.txtAddTag.text != "" {
                self.updateTag(tagName: self.txtAddTag.text!, tagId: tagId)
            } else{
                OBJCOM.setAlert(_title: "", message: "Please add your custom tag name.")
            }
        }
        
        
    }
}

extension AddCustomTagPopup : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTagName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblTagList.dequeueReusableCell(withIdentifier: "CustomTagCell", for: indexPath) as! CustomTagCell
        cell.lblTagName.text = self.arrTagName[indexPath.row]
        cell.btnRemove.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(removeCustomTag(_:)), for: .touchUpInside)
        cell.btnEdit.addTarget(self, action: #selector(editCustomTag(_:)), for: .touchUpInside)
//        if self.arrTagIdPredefine[indexPath.row] == "-1" {
//            cell.btnRemove.isHidden = true
//            cell.btnEdit.isHidden = true
//        }else{
//            cell.btnRemove.isHidden = false
//            cell.btnEdit.isHidden = false
//        }
        return cell
    }
    
    
    @objc func editCustomTag(_ sender:UIButton) {
        self.isUpdate = true
        self.btnAdd.setTitle("Update", for: .normal)
        tagName = self.arrTagName[sender.tag]
        tagId = self.arrTagId[sender.tag]
        self.txtAddTag.text = tagName
    }
    
    func updateTag(tagName:String, tagId:String){
        let dictParam = ["contact_users_id": userID,
                         "userTagId":tagId,
                         "tagName":tagName,
                         "contact_platform":"3"]
        
       
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "updateCustomTag", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: dictJsonData)
                self.txtAddTag.text = ""
                self.tagName = ""
                self.tagId = ""
                self.isUpdate = false
                self.btnAdd.setTitle("Add", for: .normal)
                self.getCategoryList()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                
            }
            self.tblTagList.reloadData()
        };
    }
    
    @objc func removeCustomTag(_ sender:UIButton) {
        print(sender.tag)
        
        let alertController = UIAlertController(title: "", message: "Are you sure you want to remove this tag? If assigned to other records will also get removed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let tagId = self.arrTagId[sender.tag]
            let dictParam = ["contact_users_id": userID,
                             "userTagId":tagId]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "removeCustomTag", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                
                let success:String = JsonDict!["IsSuccess"] as! String
                if success == "true"{
                    let dictJsonData = JsonDict!["result"] as? String ?? ""
                    OBJCOM.setAlert(_title: "", message: dictJsonData)
                    OBJCOM.hideLoader()
                }else{
                    print("result:",JsonDict ?? "")
                    OBJCOM.hideLoader()
                    
                }
                self.tblTagList.reloadData()
            };
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func getCategoryList(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":crmFlag]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "fillDropDownCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                if dictJsonData.count > 0 {
                    self.arrTagName = []
                    self.arrTagId = []
                    let arrTag = dictJsonData.value(forKey: "contact_category") as! [AnyObject]
                    for tag in arrTag {
                        let isPredefined = "\(tag["userTagUserId"] as? String ?? "")"
                        if isPredefined != "-1"{
                            self.arrTagName.append("\(tag["userTagName"] as? String ?? "")")
                            self.arrTagId.append("\(tag["userTagId"] as? String ?? "")")
//           self.arrTagIdPredefine.append("\(tag["userTagUserId"] as? String ?? "")")
                        }
                    }
                    
                }
                
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
                
            }
            self.tblTagList.reloadData()
        };
        
    }
}
