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
        "FAQ",
        "Contact Support",
        "Send Feedback"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Load each of the view controllers you want to embed
        // from the storyboard.
        let storyboard = UIStoryboard(name: "CMS", bundle: nil)
        let faq = storyboard.instantiateViewController(withIdentifier: "idFaq")
        faq.title = "FAQ"
        let support = storyboard.instantiateViewController(withIdentifier: "idSupport")
        support.title = "Contact Support"
        let feedback = storyboard.instantiateViewController(withIdentifier: "idFeedback")
        feedback.title = "Send Feedback"
        
        //
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        let pagingViewController = FixedPagingViewController(viewControllers: [
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
}
