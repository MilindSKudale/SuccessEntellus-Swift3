//
//  WeeklyGraphVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import Parchment

var user = ""

class WeeklyGraphVC: SliderVC {
    
    fileprivate let vcTitles = [
        "Weekly Goals",
        "Weekly Score Graph"
    ]

    var user_id = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == "cft"{
            user_id = selectedCFTUser
        }else{
            user_id = userID
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.title = "Weekly Graph"
        
        let storyboard = UIStoryboard(name: "WeeklyTracking", bundle: nil)
        let WeeklyGoals = storyboard.instantiateViewController(withIdentifier: "idWeeklyGoalsVC") as! WeeklyGoalsVC
        WeeklyGoals.title = "Weekly Goals"
        WeeklyGoals.userId = user_id
        
        let WeeklyScoreGraph = storyboard.instantiateViewController(withIdentifier: "idWeeklyScoreGraphVC") as! WeeklyScoreGraphVC
        WeeklyScoreGraph.title = "Weekly Score Graph"
        WeeklyScoreGraph.userId = user_id
    
        let pagingViewController = FixedPagingViewController(viewControllers: [
            WeeklyGoals,
            WeeklyScoreGraph
            ])
       
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        
        pagingViewController.didMove(toParentViewController: self)
    }
}
