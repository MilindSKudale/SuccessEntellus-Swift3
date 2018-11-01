//
//  GoogleCalenderVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 29/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
//import GoogleAPIClient
import GTMOAuth2

class GoogleCalenderVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    private let scopes = [kGTLRAuthScopeCalendarReadonly]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
   // let output = UITextView()
    @IBOutlet var uiView : UIView!
    
    var createdDate : GTLRDateTime!
    var updatedDate : GTLRDateTime!
    var startDate : GTLRDateTime!
    var endDate : GTLRDateTime!
    var user : GIDGoogleUser!
    
    let kKeychainItemName = "Success Entellus Plus"
    let kClientID = "624666392300-p7i1itm3t1ong5nk8oqqn04546f1ku71.apps.googleusercontent.com"
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName: kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }

        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = self.scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        
        self.uiView.addSubview(self.signInButton)
        
        // Add a UITextView to display output.
//        self.output.frame = self.view.bounds
//        self.output.isEditable = false
//        self.output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
//        self.output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.output.isHidden = true
//        self.view.addSubview(self.output);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
            DispatchQueue.main.async {
                self.fetchEvents()
            }
            
        } else {
            DispatchQueue.main.async {
                self.present(
                    self.createAuthController(),
                    animated: true,
                    completion: nil
                )
            }
           
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    @IBAction func actionBtnSignIn(sender: UIButton) {
        if sender.titleLabel?.text == "SIGN OUT"{
            sender.titleLabel?.text = "SIGN IN"
            GIDSignIn.sharedInstance().signOut()
        }else{
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().scopes = self.scopes
            GIDSignIn.sharedInstance().signIn()
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
            sender.titleLabel?.text = "SIGN OUT"
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Display the start dates and event summaries in the UITextView
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let events = response.items, !events.isEmpty {
            
            for event in events {
                
                self.createdDate = event.created
                self.updatedDate = event.updated
                self.startDate = event.start?.dateTime
                self.endDate = event.end?.dateTime
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let strStartDate = self.dateToString(dt: startDate.date)
                let strEndDate = self.dateToString(dt: endDate.date)
                let strCreated = self.dateToString(dt: createdDate.date)
                let strUpdated = self.dateToString(dt: updatedDate.date)
                
                var dictGoogleData = [String : Any]()
                dictGoogleData["id"] = event.identifier ?? ""
                dictGoogleData["organizer"] = event.organizer?.email ?? ""
                dictGoogleData["location"] = event.location  ?? ""
                dictGoogleData["iCalUID"] = event.iCalUID  ?? ""
                dictGoogleData["description"] = event.description
                dictGoogleData["htmlLink"] = event.htmlLink ?? ""
                dictGoogleData["hangoutLink"] = event.hangoutLink  ?? ""
                dictGoogleData["sequence"] = "0"
                dictGoogleData["end"] = ["dateTime":strEndDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["start"] = ["dateTime":strStartDate,"timeZone":"Asia/Kolkata"]
                dictGoogleData["summary"] = event.summary!
                dictGoogleData["creator"] = event.organizer?.email!
                dictGoogleData["kind"] = event.kind ?? ""
                dictGoogleData["reminders"] = "useDefault" as String
                dictGoogleData["created"] = strCreated
                dictGoogleData["updated"] = strUpdated
                dictGoogleData["status"] = "confirmed"
                dictGoogleData["calenderGoogle"] = "1"
                
                print("dictGoogleData >>> ", dictGoogleData)
            }
        }
    }
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joined(separator: " ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
        finishedSelector:#selector(viewController(vc:finishedWithAuth:error:))
        )
    }

    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    @objc func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            return
        }
        service.authorizer = authResult
        dismiss(animated: true, completion: nil)
    }

    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: dt)
    }
}
