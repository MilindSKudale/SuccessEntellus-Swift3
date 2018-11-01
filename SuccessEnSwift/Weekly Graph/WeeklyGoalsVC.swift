//
//  WeeklyGoalsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var arrGoals = [AnyObject]()
var arrScore = [AnyObject]()
var userGoal  : [CGFloat] = []
var adminGoal : [CGFloat] = []

var userG = "0000"
var adminG = "0000"
var xLabels = [String]()
var yLabels = [CGFloat]()
var xLabelsScore = [String]()
var yLabelsScore = [CGFloat]()

class WeeklyGoalsVC: UIViewController, LineChartDelegate  {
   
    @IBOutlet weak var graphView : LineChart!
    @IBOutlet weak var viewLabels : UIView!
    @IBOutlet weak var lblWeek : UILabel!
    @IBOutlet weak var lblAdminGoals : UILabel!
    @IBOutlet weak var lblUserGoals : UILabel!
    @IBOutlet weak var lblGoal : UILabel!

    var userId = ""
    var xlabel = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weekly Goals"
        
        if user == "cft"{
//            if selectedCFTUser == ""{
//                userId = userID
//            }else{
                userId = selectedCFTUser
//            }
        }else{
            userId = userID
        }
        
        xlabel = ["1","2","3","4","5","6","7","8","9","10","11","12"]
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
        
        if userID == userId {
            viewLabels.isHidden = false
        }else{
            viewLabels.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
 
        if userId == "" {
            return
        }
        getGraphData()
    }
    
    
    func getGraphData(){
        let dictParam = ["user_id": userId,
                         "platform" : "3"]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getGraphInfo", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
             
                arrGoals = JsonDict!["weekly_goals"] as! [AnyObject]
                arrScore = JsonDict!["weekly_score"] as! [AnyObject]
                
                let a = JsonDict!["user_goal_sum"] as AnyObject
                let b = JsonDict!["admin_goal_sum"] as AnyObject
        
                let val = arrGoals[0].allValues as! [CGFloat]
                let key = arrGoals[0].allKeys as! [String]
                userG = "\(JsonDict!["user_goal_sum"] as AnyObject)"
                adminG = "\(JsonDict!["admin_goal_sum"] as AnyObject)"
                

                yLabels = []
                userGoal = []
                adminGoal = []
                
                for i in 0 ..< 12 {
                    if key.contains("\(i+1)") {
                        if let index = key.index(of: "\(i+1)") {
                            yLabels.append(val[index])
                        }
                    }
                    userGoal.append(CGFloat(a.doubleValue))
                    adminGoal.append(CGFloat(b.doubleValue))
                }
                //print(self.userG, self.adminG)
            
                self.graphView.clearAll()
               
                self.graphView.addLine(yLabels)
                self.graphView.addLine(userGoal)
                self.graphView.addLine(adminGoal)
                self.graphView.addLine([10000])
                
                self.graphView.translatesAutoresizingMaskIntoConstraints = false
                self.graphView.delegate = self
                
                let wk = yLabels
                self.lblWeek.text = "Week 1"
                self.lblUserGoals.text = "My Actual Goals : \(userG)"
                self.lblAdminGoals.text = "Program Goals : \(adminG)"
                self.lblGoal.text = "My Goals : \(wk[0])"
            }
        };
    }
    
    /*** Line chart delegate method.*/
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        
        self.lblWeek.text = "Week \(Int(x))"
        self.lblUserGoals.text = "My Actual Goals : \(userG)"
        self.lblAdminGoals.text = "Program Goals : \(adminG)"
        self.lblGoal.text = "My Goals : \(yValues[0])"
    }
    
    /*** Redraw chart on device rotation.*/
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = graphView {
            chart.setNeedsDisplay()
        }
    }
}
