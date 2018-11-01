//
//  DailyScoreGraphView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class DailyScoreGraphView: UIViewController, LineChartDelegate  {

    @IBOutlet weak var graphView : LineChart!
    @IBOutlet weak var lblValues : UILabel!
    var xLabels = [String]()
    var arrScore = [Any]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Dashboard"
        
        

        // simple line with custom x axis labels
        xLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        graphView.layer.cornerRadius = 5.0
        graphView.clipsToBounds = true
        graphView.animation.enabled = true
        graphView.animation.duration = 1.0
        graphView.area = true
        graphView.x.labels.visible = true
        graphView.x.grid.count = 6
        graphView.y.grid.count = 10
        graphView.x.labels.values = xLabels
        graphView.y.labels.visible = true
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getGraphData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            //OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getGraphData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func getGraphData(){
        let dictParam = ["user_id": userID,
                         "platform":"3"]
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getWeeklyGraph", param:dictParam as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as AnyObject)
                self.arrScore = dictJsonData as! [Any]
//                let arrDays = (dictJsonData.object(at: 0) as AnyObject).allKeys
                self.graphView.clearAll()
                self.graphView.addLine(self.arrScore as! [CGFloat])
                //self.graphView.addLine([10])
                self.graphView.translatesAutoresizingMaskIntoConstraints = false
                self.graphView.delegate = self
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
    
    /*** Line chart delegate method.*/
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        //lblValues.text = "Your score is \(yValues)."
    }

    /*** Redraw chart on device rotation.*/
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = graphView {
            chart.setNeedsDisplay()
        }
    }
}

public extension LazyMapCollection  {
    
    func toArray() -> [Element]{
        return Array(self)
    }
}

