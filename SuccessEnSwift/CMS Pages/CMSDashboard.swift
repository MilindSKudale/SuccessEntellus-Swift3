//
//  CMSDashboard.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 14/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Parchment

class CMSDashboard : SliderVC {
    
    fileprivate let vcTitles = [
        "Step-By-Step Guides",
        "FAQ",
        "Contact Support",
        "Feedback"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Load each of the view controllers you want to embed
        // from the storyboard.
        let storyboard = UIStoryboard(name: "CMS", bundle: nil)
        let guide = storyboard.instantiateViewController(withIdentifier: "idHelpGuideVC")
        guide.title = "Step-By-Step Guides"
        let faq = storyboard.instantiateViewController(withIdentifier: "idFaq")
        faq.title = "FAQ"
        let support = storyboard.instantiateViewController(withIdentifier: "idSupport")
        support.title = "Contact Support"
        let feedback = storyboard.instantiateViewController(withIdentifier: "idFeedback")
        feedback.title = "Feedback"
        
        //
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        let pagingViewController = FixedPagingViewController(viewControllers: [
            guide,
            faq,
            support,
            feedback
            ])
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParentViewController: self)
    }
    
    @IBAction func actionPrivacyPolicy(_ sender:AnyObject){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionPP = UIAlertAction(title: "Privacy Policy", style: .default)
        { UIAlertAction in
            if let url = URL(string: "https://successentellus.com/home/privacyPolicy") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        actionPP.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        { UIAlertAction in }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(actionPP)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
