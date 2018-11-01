//
//  ViewController.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import EAIntroView

class ViewController: SliderVC , TabLayoutDelegate, EAIntroDelegate {
    
    @IBOutlet var tabLayout: TabLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tabLayout.fixedMode = true;
        tabLayout.layer.borderColor = UIColor.black.cgColor;
        tabLayout.layer.borderWidth = 0.5;
        tabLayout.layer.cornerRadius = 0;
        tabLayout.isScrollEnabled = false
        //tabLayout.indicatorColor = UIColor.darkGray;
        tabLayout.clipsToBounds = true
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let dailyCheckList = mainStoryboard.instantiateViewController(withIdentifier: "idDailyChecklistView") as! DailyChecklistView
        
        let dailyScoreGraph = mainStoryboard.instantiateViewController(withIdentifier: "idDailyScoreGraphView") as! DailyScoreGraphView
        
        let weeklyScoreCard = mainStoryboard.instantiateViewController(withIdentifier: "idWeeklyScoreCardView") as! WeeklyScoreCardView
        
        
        tabLayout.addTabs(tabs: [
            ("Daily CheckList", nil, dailyCheckList),
            ("Daily Score Graph", nil, dailyScoreGraph),
            ("Weekly Score Card", nil, weeklyScoreCard)
            ])
        tabLayout.tabLayoutDelegate = self
        
        
    }
    
    func createIntroductionView(){
        let ingropage1 = EAIntroPage.init(customViewFromNibNamed: "page1")
        let ingropage2 = EAIntroPage.init(customViewFromNibNamed: "page2")
        let ingropage3 = EAIntroPage.init(customViewFromNibNamed: "page3")
        let ingropage4 = EAIntroPage.init(customViewFromNibNamed: "page4")
        //let ingropage5 = EAIntroPage.init(customViewFromNibNamed: "page5")
        
        let introView = EAIntroView.init(frame: self.view.bounds, andPages: [ingropage1!,ingropage2!,ingropage3!,ingropage4!])
        introView?.delegate = self
        
        introView?.show(in: self.view)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
    }
    
    func tabLayout(tabLayout: TabLayout, index: Int) {
       
       
    }
}

