//
//  PopUpMonthlyRepeatTVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PopUpMonthlyRepeatTVC: UITableViewController {

    @IBOutlet weak var stepperRepeatWeek: PKYStepper!
    @IBOutlet weak var stepperOccurrence: PKYStepper!
    
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnEndDate: UIButton!
    
    @IBOutlet var btnOptionNever: UIButton!
    @IBOutlet var btnOptionAfterOccurance: UIButton!
    @IBOutlet var btnOptionEndDate: UIButton!
    
    var strStartDate = ""
    var strEventEndType = ""
    var strRepeatBy = ""
    var strOccurance = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        OBJCOM.setStepperValues(stepper: stepperRepeatWeek, min: 1, max: 100)
        OBJCOM.setStepperValues(stepper: stepperOccurrence, min: 0, max: 100)
        
        btnStartDate.setTitle(self.strStartDate , for: .normal)
        btnEndDate.setTitle(self.strStartDate, for: .normal)
    
//        stepperRepeatWeek.countLabel.text = dictForRepeate["repeatEvery"] ?? "1"
        strRepeatBy = ""
//        if dictForRepeate["ends"] == "never"{
//            strEventEndType = "never"
//            btnOptionNever.isSelected = true
//            btnEndDate.isEnabled = false
//            stepperOccurrence.countLabel.text = "0"
//        }else if dictForRepeate["ends"] == "after"{
//            strEventEndType = "after"
//            btnOptionNever.isSelected = true
//            btnEndDate.isEnabled = false
//            stepperOccurrence.countLabel.text = dictForRepeate["Occurences"]
//        }else if dictForRepeate["ends"] == "endOn"{
//            strEventEndType = "endOn"
//            btnOptionNever.isSelected = true
//            btnEndDate.isEnabled = false
//            stepperOccurrence.countLabel.text = "0"
//        }else{
            strEventEndType = "never"
            btnOptionNever.isSelected = true
            btnEndDate.isEnabled = false
            stepperOccurrence.isUserInteractionEnabled = false
            stepperOccurrence.countLabel.text = "0"
//        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSaveEvent(_ sender: Any) {
        
        
        if strEventEndType == "after" {
            strOccurance = stepperOccurrence.countLabel.text!
        }
        
        var strEndOn = ""
        if strEventEndType == "endOn" {
            strEndOn = (btnEndDate.titleLabel?.text)!
        }
        
        dictForRepeate = ["repeatEvery":stepperRepeatWeek.countLabel.text!,
                          "repeatBy":"dayMonth",
                          "day":"",
                          "ends":strEventEndType,
                          "ondate":strEndOn,
                          "Occurences":strOccurance]
        print(dictForRepeate)
        
        self.dismiss(animated: true, completion: nil)
    }

}

extension PopUpMonthlyRepeatTVC {
    @IBAction func actionOptionNever(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = false
        btnOptionEndDate.isSelected = false
        btnOptionNever.isSelected = true
        strEventEndType = "never"
        btnEndDate.isEnabled = false
        stepperOccurrence.isUserInteractionEnabled = false
    }
    
    @IBAction func actionOptionAfterOccurance(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = true
        btnOptionEndDate.isSelected = false
        btnOptionNever.isSelected = false
        strEventEndType = "after"
        btnEndDate.isEnabled = false
        stepperOccurrence.isUserInteractionEnabled = true
    }
    
    @IBAction func actionOptionEndDate(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = false
        btnOptionEndDate.isSelected = true
        btnOptionNever.isSelected = false
        strEventEndType = "endOn"
        btnEndDate.isEnabled = true
        stepperOccurrence.isUserInteractionEnabled = false
    }
    
    @IBAction func actionEndWeeklyEventOnDate(sender: UIButton) {
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        let endDate = self.stringToDate(strDate: strStartDate)
        datePicker.show("Set End Date",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: endDate,
                        datePickerMode: .date) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM-dd-yyyy"
                                let dateStr = formatter.string(from: dt)
                                sender.setTitle(dateStr, for: .normal)
                            }
        }
    }
    
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.date(from: strDate)!
    }
}
