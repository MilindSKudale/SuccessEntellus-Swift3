//
//  WeeklyScoreGraphVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class WeeklyScoreGraphVC: UIViewController, LineChartDelegate  {
    
    @IBOutlet weak var graphView : LineChart!
    
    @IBOutlet weak var lblWeek : UILabel!
    @IBOutlet weak var lblAdminGoals : UILabel!
    @IBOutlet weak var lblUserGoals : UILabel!
    @IBOutlet weak var lblGoal : UILabel!
    @IBOutlet weak var viewLabels : UIView!
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weekly Score"
 
        if userID == userId {
            viewLabels.isHidden = false
        }else{
            viewLabels.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let xlabel = ["1","2","3","4","5","6","7","8","9","10","11","12"]
        
        if arrScore.count == 0 {
            
            self.graphView.animation.enabled = true
            self.graphView.animation.duration = 1.0
            self.graphView.area = false
            self.graphView.x.grid.visible = false
            self.graphView.y.grid.visible = false
            self.graphView.x.labels.values = xLabels
            self.graphView.y.labels.visible = true
            self.graphView.addLine([10000])
            self.graphView.translatesAutoresizingMaskIntoConstraints = false
            self.graphView.delegate = self
            return
        }
        if arrScore[0].count == 0 {
            return
        }
        let val = arrScore[0].allValues as! [CGFloat]
        let key = arrScore[0].allKeys as! [String]
        
        yLabelsScore = []
        for i in 0 ..< 12 {
            if key.contains("\(i+1)") {
                if let index = key.index(of: "\(i+1)") {
                    yLabelsScore.append(val[index])
                }
            }
        }
        graphView.animation.enabled = true
        graphView.animation.duration = 1.0
        graphView.area = false
        self.graphView.x.grid.visible = false
        self.graphView.y.grid.visible = false
        graphView.x.labels.values = xlabel
        graphView.y.labels.visible = true
        self.graphView.clearAll()
        self.graphView.addLine(yLabelsScore)
        self.graphView.addLine(userGoal)
        self.graphView.addLine(adminGoal)
        self.graphView.addLine([10000])
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        self.graphView.delegate = self
        
        let wk = yLabelsScore
        self.lblWeek.text = "Week 1"
        self.lblUserGoals.text = "My Actual Goals : \(userG)"
        self.lblAdminGoals.text = "Program Goals : \(adminG)"
        self.lblGoal.text = "My Score : \(wk[0])"
    }
    
    
    /*** Line chart delegate method.*/
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        
        self.lblWeek.text = "Week \(Int(x))"
        self.lblUserGoals.text = "My Actual Goals : \(userG)"
        self.lblAdminGoals.text = "Program Goals : \(adminG)"
        self.lblGoal.text = "My Score : \(yValues[0])"
    }
    
    /*** Redraw chart on device rotation.*/
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = graphView {
            chart.setNeedsDisplay()
        }
    }
}
