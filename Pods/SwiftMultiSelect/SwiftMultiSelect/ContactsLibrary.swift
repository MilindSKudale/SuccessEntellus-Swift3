//
//  ContactsLibrary.swift
//  frind
//
//  Created by Spike on 26/11/15.
//  Copyright © 2015 brokenice. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI


/// Class to manage Contacts
public class ContactsLibrary{
    
    //Contacts store
    public static var contactStore  = CNContactStore()
    
    
    /// Function to request access for PhoneBook
    ///
    /// - Parameter completionHandler: <#completionHandler description#>
    class func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            print("\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings.")
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    
    /// Function to get contacts from device
    ///
    /// - Parameters:
    ///   - keys: array of keys to get
    ///   - completionHandler: callback function, contains contacts array as parameter
    public class func getContacts(_ keys:[CNKeyDescriptor] = [CNContactNamePrefixKey as CNKeyDescriptor,
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
        CNSocialProfileServiceLinkedIn as CNKeyDescriptor, CNContactViewController.descriptorForRequiredKeys()],completionHandler: @escaping (_ success:Bool, _ contacts: [SwiftMultiSelectItem]?) -> Void){
        
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                
                
                var contactsArray = [SwiftMultiSelectItem]()
                
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
                
                do {
                    var row = 0
                    try self.contactStore.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                        
                      //  var arrEmail = [Any]()
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
                        
                        let item_contact = SwiftMultiSelectItem(row: row, title: username, description: companyName, image: nil, imageURL: nil, color: nil, userInfo: contactArray as AnyObject)
                        if arrEmail.count != 0 || arrPh.count != 0 {
                            contactsArray.append(item_contact)
                        }
                        row += 1
                        
                    })
                    completionHandler(true, contactsArray)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }else{
                completionHandler(false, nil)
            }
        }
        
    }
    
   
    
    
    /// Get allowed keys
    ///
    /// - Returns: array
    class func allowedContactKeys() -> [CNKeyDescriptor]{
        
        return [
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactNameSuffixKey as CNKeyDescriptor,
            //CNContactNicknameKey,
            //CNContactPhoneticGivenNameKey,
            //CNContactPhoneticMiddleNameKey,
            //CNContactPhoneticFamilyNameKey,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactDepartmentNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            //CNContactNonGregorianBirthdayKey,
            CNContactNoteKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            //CNContactTypeKey,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactDatesKey as CNKeyDescriptor,
            CNContactUrlAddressesKey as CNKeyDescriptor,
            //CNContactRelationsKey,
            CNContactSocialProfilesKey as CNKeyDescriptor,
            CNContactInstantMessageAddressesKey as CNKeyDescriptor
    
        ]
        
    }

}

