//
//  GroupDetailsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class GroupDetailsVC: UIViewController, TagListViewDelegate {
    
    @IBOutlet var txtGroupName : SkyFloatingLabelTextField!
    @IBOutlet var grMembersContact : TagListView!
    @IBOutlet var grMembersProspect : TagListView!
    @IBOutlet var grMembersCustomert : TagListView!
    @IBOutlet var grMembersRecruit : TagListView!
    @IBOutlet var tagAssignedCamp : TagListView!
    
    var arrGroupData = [String:AnyObject]()
    var arrGroupProspect = [String]()
    var arrGroupContact = [String]()
    var arrGroupCustomer = [String]()
    var arrGroupRecruit = [String]()
    var arrAssignedCamp = [String]()
    
    var groupId = ""
    var isCalled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtGroupName.isUserInteractionEnabled = false

        grMembersContact.delegate = self
        grMembersContact.textFont = UIFont.systemFont(ofSize: 15)
        grMembersContact.alignment = .left
        grMembersContact.tagBackgroundColor = .white
        grMembersContact.textColor = .black
        
        grMembersProspect.delegate = self
        grMembersProspect.textFont = UIFont.systemFont(ofSize: 15)
        grMembersProspect.alignment = .left
        grMembersProspect.tagBackgroundColor = .white
        grMembersProspect.textColor = .black
        
        grMembersCustomert.delegate = self
        grMembersCustomert.textFont = UIFont.systemFont(ofSize: 15)
        grMembersCustomert.alignment = .left
        grMembersCustomert.tagBackgroundColor = .white
        grMembersCustomert.textColor = .black
        
        grMembersRecruit.delegate = self
        grMembersRecruit.textFont = UIFont.systemFont(ofSize: 15)
        grMembersRecruit.alignment = .left
        grMembersRecruit.tagBackgroundColor = .white
        grMembersRecruit.textColor = .black
        
        tagAssignedCamp.delegate = self
        tagAssignedCamp.textFont = UIFont.systemFont(ofSize: 15)
        tagAssignedCamp.alignment = .left
        tagAssignedCamp.tagBackgroundColor = .white
        tagAssignedCamp.textColor = .black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            isCalled = true
            self.getGroupDetails()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getGroupDetails(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "groupId":groupId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getDetailGroup", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true" && self.isCalled == true {
                self.isCalled = false
                self.arrGroupData = JsonDict!["result"] as! [String:AnyObject]
                self.arrAssignedCamp = []
                self.arrGroupContact = []
                self.arrGroupCustomer = []
                self.arrGroupProspect = []
                self.arrGroupRecruit = []
                self.txtGroupName.text = self.arrGroupData["group_name"] as? String ?? ""
                self.arrGroupContact = self.arrGroupData["contact"]!["name"] as! [String]
                self.arrGroupCustomer = self.arrGroupData["customer"]!["name"] as! [String]
                self.arrGroupProspect = self.arrGroupData["prospect"]!["name"] as! [String]
                self.arrGroupRecruit = self.arrGroupData["recruit"]!["name"] as! [String]
                self.arrAssignedCamp = self.arrGroupData["campName"] as! [String]
                
                let ContactsStr = NSMutableAttributedString()
                ContactsStr
                    .bold("My Contacts :")
                let CustomersStr = NSMutableAttributedString()
                CustomersStr
                    .bold("My Customers :")
                let ProspectsStr = NSMutableAttributedString()
                ProspectsStr
                    .bold("My Prospects :")
                let RecruitsStr = NSMutableAttributedString()
                RecruitsStr
                    .bold("My Recruits :")
            
                self.grMembersContact.addTag(ContactsStr.string)
                self.grMembersProspect.addTag(ProspectsStr.string)
                self.grMembersCustomert.addTag(CustomersStr.string)
                self.grMembersRecruit.addTag(RecruitsStr.string)
                if self.arrGroupContact.count > 0 {
//                    self.grMembersContact.addTags(self.arrGroupContact)
                    for obj in self.arrGroupContact {
                        if obj != self.arrGroupContact.last {
                            self.grMembersContact.addTag("\(obj),")
                        }else{
                            self.grMembersContact.addTag("\(obj)")
                        }
                    }
                   
                }else{
                    self.grMembersContact.addTag("No contacts added yet.")
                }
                
                if self.arrGroupCustomer.count > 0 {
                    for obj in self.arrGroupCustomer {
                        if obj != self.arrGroupCustomer.last {
                            self.grMembersCustomert.addTag("\(obj),")
                        }else{
                            self.grMembersCustomert.addTag("\(obj)")
                        }
                    }
//                    self.grMembersCustomert.addTags(self.arrGroupCustomer)
                }else{
                    self.grMembersCustomert.addTag("No customers added yet.")
                }
                
                if self.arrGroupProspect.count > 0 {
                    for obj in self.arrGroupProspect {
                        if obj != self.arrGroupProspect.last {
                            self.grMembersProspect.addTag("\(obj),")
                        }else{
                            self.grMembersProspect.addTag("\(obj)")
                        }
                    }
//                    self.grMembersProspect.addTags(self.arrGroupProspect)
                }else{
                    self.grMembersProspect.addTag("No prospects added yet.")
                }
                
                if self.arrGroupRecruit.count > 0 {
                    for obj in self.arrGroupRecruit {
                        if obj != self.arrGroupRecruit.last {
                            self.grMembersRecruit.addTag("\(obj),")
                        }else{
                            self.grMembersRecruit.addTag("\(obj)")
                        }
                    }
                }else{
                    self.grMembersRecruit.addTag("No recruits added yet.")
                }
                
                if self.arrAssignedCamp.count > 0 {
                    self.tagAssignedCamp.addTags(self.arrAssignedCamp )
                }else{
                    self.tagAssignedCamp.addTag("No campaign assigned yet.")
                }
                
                OBJCOM.hideLoader()
            }else{
                self.isCalled = true
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionEditGroup(_ sender: UIButton) {
        // idEditGroupVC
        let storyboard = UIStoryboard(name: "CRM", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idEditGroupVC") as! EditGroupVC
        vc.groupId = groupId
        vc.isEdit = false
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        //tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
       // sender.removeTagView(tagView)
    }
}
