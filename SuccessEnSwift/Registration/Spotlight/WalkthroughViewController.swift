//
//  WalkthroughViewController.swift
//  Walkthrough
//
//  Created by Ömer Faruk Öztürk on 29/09/2016.
//  Copyright © 2016 omerfarukozturk. All rights reserved.
//

import UIKit
import ContactsUI
import SKActivityIndicatorView

class WalkthroughViewController: UIViewController {
    
    var showNextPage: Bool = true
    var isImport: Bool = false
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    var itemsToBeHighlighted : [WalkthroughItemType] = []
    
    @IBOutlet weak var desctiptionTitleLabel: UILabel!
    @IBOutlet weak var desctiptionLabel: UILabel!
    
    @IBOutlet weak var descriptionTitleTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionToTitleTopMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var desctiptionTitleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelWidthContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.desctiptionLabel.layer.zPosition = 1
        self.desctiptionTitleLabel.layer.zPosition = 1
        self.closeButton.layer.zPosition = 1
        self.continueButton.layer.zPosition = 1
        
        self.desctiptionTitleWidthConstraint.constant = UIScreen.main.bounds.width - 30.0
        self.descriptionLabelWidthContraint.constant = UIScreen.main.bounds.width - 30.0
        
        self.descriptionTitleTopMarginConstraint.constant = UIScreen.main.bounds.height / 2
        self.descriptionToTitleTopMarginConstraint.constant = 0.0
        
        self.desctiptionTitleLabel.isHidden = true
        self.desctiptionLabel.isHidden = true
        
        self.closeButton.isHidden = true
        self.continueButton.isHidden = true
        
        self.continueButton.setTitle("Next", for: .normal)
        
    }
    
    func setNewValueShowNextPage(value: Bool) {
        self.showNextPage = value
    }
    
    override func viewDidAppear(_ animated : Bool){
        super.viewDidAppear(animated)
        if self.showNextPage {
            self.nextHighlighAction()
        } else {
            self.showNextPage = true
        }
    }
    
    func highlightView(item: WalkthroughItemType){
        
        if let previousMaskView = self.view.viewWithTag(99) {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                previousMaskView.layer.opacity = 0.0
                }, completion: { (completed) -> Void in
                    previousMaskView.removeFromSuperview()
            })
        }
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.tag = 99
        
        let circleWidth = item.width * 2.5
        let circleHeight = item.height * 2.5
        
        let circleImageView = UIImageView(image: #imageLiteral(resourceName: "wt_circle"))
        circleImageView.frame = CGRect(x: item.point.x - circleWidth * 0.3, y: item.point.y - circleHeight * 0.3 , width: circleWidth, height: circleHeight)
        maskView.addSubview(circleImageView)
        
        let backRect1 = UIImageView(image: #imageLiteral(resourceName: "wt_bg"))
        backRect1.frame = CGRect(x: 0, y: 0, width: circleImageView.frame.origin.x + circleImageView.frame.width, height: circleImageView.frame.origin.y)
        maskView.addSubview(backRect1)
        
        let backRect2 = UIImageView(image: #imageLiteral(resourceName: "wt_bg"))
        backRect2.frame = CGRect(x: 0, y: circleImageView.frame.origin.y , width: circleImageView.frame.origin.x, height: UIScreen.main.bounds.height - circleImageView.frame.origin.y)
        maskView.addSubview(backRect2)
        
        let backRect3 = UIImageView(image: #imageLiteral(resourceName: "wt_bg"))
        backRect3.frame = CGRect(x: circleImageView.frame.origin.x, y: circleImageView.frame.origin.y + circleImageView.frame.height, width: UIScreen.main.bounds.width - circleImageView.frame.origin.x, height: UIScreen.main.bounds.height - circleImageView.frame.origin.y - circleImageView.frame.height)
        maskView.addSubview(backRect3)
        
        let backRect4 = UIImageView(image: #imageLiteral(resourceName: "wt_bg"))
        backRect4.frame = CGRect(x: circleImageView.frame.origin.x + circleImageView.frame.width, y: 0, width: UIScreen.main.bounds.width - circleImageView.frame.origin.x - circleImageView.frame.width, height: circleImageView.frame.origin.y + circleImageView.frame.height)
        maskView.addSubview(backRect4)
        maskView.layer.opacity = 0.5
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            maskView.layer.opacity = 1.0
            self.closeButton.isHidden = false
            self.continueButton.isHidden = false
            
            
            }, completion: { (completed) -> Void in
        })
        
        self.view.insertSubview(maskView, at: 0)
    }
    
    func dismissDescriptionLabels(toYCoordinate : CGFloat){
        self.desctiptionTitleLabel.isHidden = true
        self.desctiptionLabel.isHidden = true
        self.desctiptionTitleLabel.frame.origin = CGPoint(x: -UIScreen.main.bounds.width, y: toYCoordinate)
        self.desctiptionLabel.frame.origin = CGPoint(x: -UIScreen.main.bounds.width, y: toYCoordinate + self.desctiptionTitleLabel.frame.height)
    }
    
    func showHighlightDescription(item: WalkthroughItemType){
        
        // define y coordinate of description label
        let yCoordinate : CGFloat = item.point.y > UIScreen.main.bounds.height / 2 ? UIScreen.main.bounds.height * 0.20 : UIScreen.main.bounds.height * 0.50
        
        self.dismissDescriptionLabels(toYCoordinate: yCoordinate)
        
        // reset & initialize title
        self.desctiptionTitleLabel.layer.opacity = 0.0
        self.descriptionTitleTopMarginConstraint.constant = yCoordinate
        self.desctiptionTitleLabel.frame.origin = CGPoint(x: -UIScreen.main.bounds.width, y: yCoordinate)
        self.desctiptionTitleLabel.text = item.title
        
        // reset & initialize description
        self.desctiptionLabel.layer.opacity = 0.0
        self.desctiptionLabel.frame.origin = CGPoint(x: -UIScreen.main.bounds.width, y: yCoordinate + self.desctiptionTitleLabel.frame.height)
        self.desctiptionLabel.text = item.description
        
        
        self.desctiptionTitleLabel.isHidden = false
        self.desctiptionLabel.isHidden = false
        
        if item.title == "Import Phone Contacts" {
            self.continueButton.setTitle("Import", for: .normal)
            isImport = true
        } else if whichView == "TextCampaign" {
            self.continueButton.setTitle("Get Started", for: .normal)
            isImport = false
        } else {
            self.continueButton.setTitle("Next", for: .normal)
           // isImport = false
        }
        
        // animate title
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.desctiptionTitleLabel.frame.origin = CGPoint(x: 20.0, y: yCoordinate)
            self.desctiptionTitleLabel.layer.opacity = 1.0
        })
        
        // animate description
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.desctiptionLabel.frame.origin = CGPoint(x: 20.0, y: yCoordinate + self.desctiptionTitleLabel.frame.height)
            self.desctiptionLabel.layer.opacity = 1.0
        })
        
    }
    
    func nextHighlighAction(){
        
        if itemsToBeHighlighted.count > 0 {
            self.highlightView(item: itemsToBeHighlighted[0])
            self.showHighlightDescription(item: itemsToBeHighlighted[0])
            
            // remove highlighted item from list
            self.itemsToBeHighlighted.remove(at: 0)
            
            if self.itemsToBeHighlighted.count == 0 {
                //self.continueButton.isHidden = true
               // self.continueButton.setTitle("", for: .normal)
            }
        }
    }
    
    @IBAction func closeButtonAction(sender: AnyObject) {
        self.presentingViewController?.view.layer.mask = nil
       // if whichView == "TextCampaign" {
            isOnboarding = false
            isOnboard = "true"
            AppDelegate.shared.setRootVC()
       // }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonAction(sender: AnyObject) {
        if whichView == "UploadContacts" {
            setLoader() 
            importDeviceContacts()
            
        }else if whichView == "CFTLocator"{
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idEmailCampaignView") as! EmailCampaignView
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
            
        }else if whichView == "EmailCampaign"{
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idTextCampaignView") as! TextCampaignView
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
            
        }else if whichView == "TextCampaign" {
            isOnboarding = false
            isOnboard = "true"
            AppDelegate.shared.setRootVC()
            
        }else{
            self.nextHighlighAction()
        }
    }
    
    func importDeviceContacts(){
        let contactStore = CNContactStore()
        var contacts = [[String:Any]]()
        let keys = [CNContactNamePrefixKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactOrganizationNameKey as CNKeyDescriptor,
                    CNContactBirthdayKey as CNKeyDescriptor,
                    CNContactImageDataKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor,
                    CNContactImageDataAvailableKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactUrlAddressesKey as CNKeyDescriptor,
                    CNContactNoteKey as CNKeyDescriptor,
                    CNContactMiddleNameKey as CNKeyDescriptor,
                    CNContactPostalAddressesKey as CNKeyDescriptor,
                    CNContactInstantMessageAddressesKey as CNKeyDescriptor,
                    CNContactSocialProfilesKey as CNKeyDescriptor,
                    CNSocialProfileServiceTwitter as CNKeyDescriptor,
                    CNSocialProfileServiceFacebook as CNKeyDescriptor,
                    CNSocialProfileServiceLinkedIn as CNKeyDescriptor, CNContactViewController.descriptorForRequiredKeys()] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                
                
//                var arrEmail = [String]()
//                for obj in contact.emailAddresses {
//                    arrEmail.append(obj.value as String )
//                }
//                var arrPh = [String]()
//                for obj in contact.phoneNumbers {
//                    arrPh.append(obj.value.stringValue as String)
//                }
//                var arrAddrs = ["street":"",
//                                "city":"",
//                                "state":"",
//                                "country":"",
//                                "zipCode":""]
//                for obj in contact.postalAddresses {
//                    arrAddrs = ["street":obj.value.street,
//                                "city":obj.value.city,
//                                "state":obj.value.state,
//                                "country":obj.value.country,
//                                "zipCode":obj.value.postalCode]
//                }
//                let arrSocial = ["Facebook": "",
//                                 "Twitter": "",
//                                 "LinkedIn": ""]
//                var bdayStr = ""
//                if contact.birthday != nil {
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd"
//                    bdayStr = formatter.string(from: (contact.birthday?.date)!)
//                }
//                let contactArray = ["firstName":contact.givenName,
//                                    "middleName":contact.middleName,
//                                    "lastName":contact.familyName,
//                                    "organisationName":contact.organizationName,
//                                    "email":arrEmail,
//                                    "phone":arrPh,
//                                    "birthDay":bdayStr,
//                                    "address":arrAddrs,
//                                    "SocialMediaProfiles":arrSocial,
//                                    "SkypeLink":"",
//                                    "Description":contact.note] as [String : Any]
                
                var arrEmail = ["em1":"",
                                "em2":"",
                                "em3":""]
                if contact.emailAddresses.count == 1 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":"",
                                "em3":""]
                }else if contact.emailAddresses.count == 2 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":contact.emailAddresses[1].value as String,
                                "em3":""]
                }else if contact.emailAddresses.count > 2 {
                    arrEmail = ["em1":contact.emailAddresses[0].value as String,
                                "em2":contact.emailAddresses[1].value as String,
                                "em3":contact.emailAddresses[2].value as String,]
                }else{
                    arrEmail = ["em1":"",
                                "em2":"",
                                "em3":""]
                }
                
                var arrPh = ["ph1":"",
                             "ph2":"",
                             "ph3":""]
                if contact.phoneNumbers.count == 1 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":"",
                             "ph3":""]
                }else if contact.phoneNumbers.count == 2 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":contact.phoneNumbers[1].value.stringValue as String,
                             "ph3":""]
                }else if contact.phoneNumbers.count > 2 {
                    arrPh = ["ph1":contact.phoneNumbers[0].value.stringValue as String,
                             "ph2":contact.phoneNumbers[1].value.stringValue as String,
                             "ph3":contact.phoneNumbers[2].value.stringValue as String,]
                }else{
                    arrPh = ["ph1":"",
                             "ph2":"",
                             "ph3":""]
                }
                var arrAddrs = ["street":"",
                                "city":"",
                                "state":"",
                                "country":"",
                                "zipCode":""]
                for obj in contact.postalAddresses {
                    arrAddrs = ["street":obj.value.street,
                                "city":obj.value.city,
                                "state":obj.value.state,
                                "country":obj.value.country,
                                "zipCode":obj.value.postalCode]
                }
                
                var username    = "\(contact.givenName) \(contact.familyName)"
                var companyName = contact.organizationName
                
                if username.trimmingCharacters(in: .whitespacesAndNewlines) == "" && companyName != ""{
                    username        = companyName
                    companyName     = ""
                }
                
                var contactArray = [String : String]()
                let udata = UserDefaults.standard.value(forKey: "USERINFO") as? [String:Any]
                if udata == nil {return}
                let uid = udata!["zo_user_id"] as! String
                print(uid)
                contactArray["contact_users_id"] = uid
                contactArray["contact_flag"] = "1"
                contactArray["contact_platform"] = "3"
                contactArray["contact_fname"] = contact.givenName
                contactArray["contact_lname"] = contact.familyName
                contactArray["contact_company_name"] = contact.organizationName
                contactArray["contact_email"] = arrEmail["em1"]
                contactArray["contact_work_email"] = arrEmail["em2"]
                contactArray["contact_other_email"] = arrEmail["em3"]
                contactArray["contact_phone"] = arrPh["ph1"]
                contactArray["contact_work_phone"] = arrPh["ph2"]
                contactArray["contact_other_phone"] = arrPh["ph3"]
                contactArray["contact_skype_id"] = ""
                contactArray["contact_twitter_name"] = ""
                contactArray["contact_facebookurl"] = ""
                contactArray["contact_linkedinurl"] = ""
                contactArray["contact_description"] = contact.note
                contactArray["contact_address"] = arrAddrs["street"]
                contactArray["contact_city"] = arrAddrs["city"]
                contactArray["contact_state"] = arrAddrs["state"]
                contactArray["contact_country"] = arrAddrs["country"]
                contactArray["contact_zip"] = arrAddrs["zipCode"]
                
                print(contactArray)
                contacts.append(contactArray)
                //OBJCOM.hideLoader()
            }
            
            DispatchQueue.main.async {
                self.extractDeviceContacts(items:contacts)
            }
            print(contacts)
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    func extractDeviceContacts(items:[[String:Any]]){
        var arrForImport = [AnyObject]()
        for item in items {
            arrForImport.append(item as AnyObject)
        }
        if arrForImport.count > 0 {
            print("----------------------------------")
            let dictParam = ["userId": userID,
                             "platform":"3",
                             "contact_details":arrForImport] as [String : Any]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let dictParamTemp = ["param":jsonString];
            
            typealias JSONDictionary = [String:Any]
            OBJCOM.modalAPICall(Action: "importCrmWithoutValidation", param:dictParamTemp as [String : AnyObject],  vcObject: self){
                JsonDict, staus in
                OBJCOM.hideLoader()
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.removeDuplicateContacts()
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
            };
        }
    }
    
    func setLoader() {
        SKActivityIndicator.spinnerColor(APPORANGECOLOR)
        SKActivityIndicator.statusTextColor(APPGRAYCOLOR)
        SKActivityIndicator.statusLabelFont(UIFont.boldSystemFont (ofSize: 15.0))
        SKActivityIndicator.spinnerStyle(.spinningCircle)
        SKActivityIndicator.show("Importing your phone contacts...", userInteractionStatus: false)
    }
    
    func removeDuplicateContacts(){
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "crmFlag":"1"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteDuplicateCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
//            let success:String = JsonDict!["IsSuccess"] as! String
//            if success == "true"{
//                let result = JsonDict!["result"] as AnyObject
//                OBJCOM.hideLoader()
//                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "idCFTMapView") as! CFTMapView
//                let navVC = UINavigationController(rootViewController:vc)
//                navVC.modalPresentationStyle = .custom
//                navVC.modalTransitionStyle = .crossDissolve
//                self.present(navVC, animated: true, completion: nil)
//            }else{
//                print("result:",JsonDict ?? "")
//                let result = JsonDict!["result"] as AnyObject
//                OBJCOM.setAlert(_title: "", message: result as! String)
//                OBJCOM.hideLoader()
//            }
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idCFTMapView") as! CFTMapView
            let navVC = UINavigationController(rootViewController:vc)
            navVC.modalPresentationStyle = .custom
            navVC.modalTransitionStyle = .crossDissolve
            self.present(navVC, animated: true, completion: nil)
        };
        
    }
}

typealias WalkthroughItemType = (point: CGPoint, height: CGFloat, width: CGFloat, title: String, description: String)

func showWalkthroughView(currentViewController: UIViewController, itemsToBeHighlighted: [WalkthroughItemType]) {
    
    let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
    let walkthroughVC = storyBoard.instantiateViewController(withIdentifier: "walkthroughVC") as! WalkthroughViewController
    walkthroughVC.itemsToBeHighlighted = itemsToBeHighlighted
    
    if #available(iOS 8.0, *) {
        walkthroughVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        currentViewController.present(walkthroughVC, animated: true, completion: nil)
    } else {
        // Fallback on earlier versions
        currentViewController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        currentViewController.navigationController?.modalPresentationStyle = UIModalPresentationStyle.currentContext
        currentViewController.present(walkthroughVC, animated: false, completion: nil)
    }
    
}
