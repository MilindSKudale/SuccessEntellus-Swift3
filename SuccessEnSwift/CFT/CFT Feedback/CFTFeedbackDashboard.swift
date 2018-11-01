//
//  CFTFeedbackDashboard.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Parchment

class CFTFeedbackDashboard: UIViewController {
    
    

    fileprivate let vcTitles = [
        "CFT/Mentor's Feedback",
        "Feedback For Recruits"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "CFT", bundle: nil)
        let feedbackM = storyboard.instantiateViewController(withIdentifier: "idFeedbackMentorVC")
        feedbackM.title = "CFT/Mentor's Feedback"
        let feedbackR = storyboard.instantiateViewController(withIdentifier: "idFeedbackRecruitVC")
        feedbackR.title = "Feedback For Recruits"
        
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            feedbackM,
            feedbackR
            ])
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParentViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func actionClose(_ sender:Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
