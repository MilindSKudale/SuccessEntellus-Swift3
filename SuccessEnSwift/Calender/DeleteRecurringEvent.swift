//
//  DeleteRecurringEvent.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 12/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class DeleteRecurringEvent: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let scopes = [kGTLRAuthScopeCalendar]
    let service = GTLRCalendarService()
    
    @IBOutlet var btnOnlyThisEvent : UIButton!
    @IBOutlet var btnFollowingEvents : UIButton!
    @IBOutlet var btnAllEvents : UIButton!
    
    var eventData : [String:String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().scopes = self.scopes
        GIDSignIn.sharedInstance().signInSilently()
        print(eventData)
    }
    
    func designUI(){
        btnOnlyThisEvent.layer.cornerRadius = 5.0
        btnOnlyThisEvent.layer.borderColor = APPGRAYCOLOR.cgColor
        btnOnlyThisEvent.layer.borderWidth = 1.0
        btnOnlyThisEvent.clipsToBounds = true
        
        btnFollowingEvents.layer.cornerRadius = 5.0
        btnFollowingEvents.layer.borderColor = APPGRAYCOLOR.cgColor
        btnFollowingEvents.layer.borderWidth = 1.0
        btnFollowingEvents.clipsToBounds = true
        
        btnAllEvents.layer.cornerRadius = 5.0
        btnAllEvents.layer.borderColor = APPGRAYCOLOR.cgColor
        btnAllEvents.layer.borderWidth = 1.0
        btnAllEvents.clipsToBounds = true
    }
    
    @IBAction func actionBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDeleteThisEvent(_ sender: UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.deleteRecurringEvents(deleteFlag: "1")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionDeleteFollowingEvent(_ sender: UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.deleteRecurringEvents(deleteFlag: "2")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionDeleteAllEvent(_ sender: UIButton) {
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.deleteRecurringEvents(deleteFlag: "3")
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func deleteRecurringEvents(deleteFlag : String){
      
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "eventEditId":eventData["eventEditId"],
                         "googleEventFlag":eventData["googleEventFlag"],
                         "recurringEventId":eventData["recurringEventId"],
                         "randomNumberValue":eventData["RandomNumberValue"],
                         "deleteFlag":deleteFlag]
        
        OBJCOM.modalAPICall(Action: "deleteAllEventOption", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                OBJCOM.setAlert(_title: "", message: result)
                NotificationCenter.default.post(name: Notification.Name("EditTaskList"), object: nil)
                
                self.deleteEvents(eventId: self.eventData["googleCalEventId"]!)
                self.dismiss(animated: true, completion: nil)
                
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if error != nil {
            //OBJCOM.setAlert(_title: "Authentication Error", message: error.localizedDescription)
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()

        }
    }
    
    
    func deleteEvents(eventId : String) {
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)
        
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(deleteGoogleEvents(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func deleteGoogleEvents(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if error != nil {
          //  OBJCOM.setAlert(_title: "Error", message:"\(error?.localizedDescription ?? "")" )
        }
       
    }
    

}
