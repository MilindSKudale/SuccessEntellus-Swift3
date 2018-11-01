//
//  PopUpWeeklyRepeatTVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit



class PopUpWeeklyRepeatTVC: UITableViewController {

    let currentDate = Date()
    @IBOutlet weak var stepperRepeatWeek: PKYStepper!
    @IBOutlet weak var stepperOccurrence: PKYStepper!
    var arrBtn : [UIButton]!
    @IBOutlet var btnSun: UIButton!
    @IBOutlet var btnMon: UIButton!
    @IBOutlet var btnTue: UIButton!
    @IBOutlet var btnWed: UIButton!
    @IBOutlet var btnThu: UIButton!
    @IBOutlet var btnFri: UIButton!
    @IBOutlet var btnSat: UIButton!
    
    @IBOutlet var btnDaily: UIButton!
    @IBOutlet var btnSelectedDays: UIButton!
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnEndDate: UIButton!
    
    @IBOutlet var btnOptionNever: UIButton!
    @IBOutlet var btnOptionAfterOccurance: UIButton!
    @IBOutlet var btnOptionEndDate: UIButton!
    
    var strStartDate = ""
    var strEventEndType = ""
    var strSelectedDays = ""
    var arrSelectedDays = [String]()
    var strRepeatBy = ""
    var strOccurance = ""
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OBJCOM.setStepperValues(stepper: stepperRepeatWeek, min: 1, max: 100)
        OBJCOM.setStepperValues(stepper: stepperOccurrence, min: 0, max: 100)
        
        btnDaily.isSelected = true
        btnSun.isSelected = true
        btnMon.isSelected = true
        btnTue.isSelected = true
        btnWed.isSelected = true
        btnThu.isSelected = true
        btnFri.isSelected = true
        btnSat.isSelected = true
        arrSelectedDays = ["SU","MO","TU","WE","TH","FR","SA"]
        btnOptionNever.isSelected = true
        stepperOccurrence.isUserInteractionEnabled = false
        btnEndDate.isEnabled = false
        
        self.tableView.tableFooterView = UIView()
        
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
            stepperOccurrence.countLabel.text = "0"
//        }
        
        btnStartDate.setTitle(self.strStartDate , for: .normal)
        btnEndDate.setTitle(self.strStartDate, for: .normal)
        arrBtn = [btnSun, btnMon, btnTue, btnWed, btnThu, btnFri, btnSat]
        setBtnBorder(arrBtn: arrBtn)
        
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
            strEndOn = btnEndDate.titleLabel!.text!
        }
        
        strSelectedDays = self.arrSelectedDays.joined(separator: ",")
        
        dictForRepeate = ["repeatEvery":stepperRepeatWeek.countLabel.text!,
                          "repeatBy":strRepeatBy,
                          "day":strSelectedDays,
                          "ends":strEventEndType,
                          "ondate":strEndOn,
                          "Occurences":strOccurance]
        
        print(dictForRepeate)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionOptionNever(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = false
        btnOptionEndDate.isSelected = false
        btnOptionNever.isSelected = true
        strEventEndType = "never"
        stepperOccurrence.isUserInteractionEnabled = false
        btnEndDate.isEnabled = false
    }
    
    @IBAction func actionOptionAfterOccurance(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = true
        btnOptionEndDate.isSelected = false
        btnOptionNever.isSelected = false
        strEventEndType = "after"
        stepperOccurrence.isUserInteractionEnabled = true
        btnEndDate.isEnabled = false
    }
    
    @IBAction func actionOptionEndDate(_ sender: Any) {
        btnOptionAfterOccurance.isSelected = false
        btnOptionEndDate.isSelected = true
        btnOptionNever.isSelected = false
        strEventEndType = "endOn"
        stepperOccurrence.isUserInteractionEnabled = false
        btnEndDate.isEnabled = true
      //  strEndOn = btnEndDate.titleLabel?.text!
    }
}

extension PopUpWeeklyRepeatTVC {
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    @IBAction func actionBtnDaily(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if sender.isSelected {
            btnSelectedDays.isSelected = false
            btnSun.isSelected = true
            btnMon.isSelected = true
            btnTue.isSelected = true
            btnWed.isSelected = true
            btnThu.isSelected = true
            btnFri.isSelected = true
            btnSat.isSelected = true
            arrSelectedDays = ["SU","MO","TU","WE","TH","FR","SA"]
        }
    }
    
    @IBAction func actionBtnSelectedDays(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
         if sender.isSelected {
            btnDaily.isSelected = false
            btnSun.isSelected = false
            btnMon.isSelected = false
            btnTue.isSelected = false
            btnWed.isSelected = false
            btnThu.isSelected = false
            btnFri.isSelected = false
            btnSat.isSelected = false
            arrSelectedDays.removeAll()
        }
    }
    
    @IBAction func actionBtnSunday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("SU")
    }
    @IBAction func actionBtnMonday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("MO")
    }
    @IBAction func actionBtnTuesday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("TU")
    }
    @IBAction func actionBtnWedensday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("WE")
    }
    @IBAction func actionBtnThursday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("TH")
    }
    @IBAction func actionBtnFriday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("FR")
    }
    @IBAction func actionBtnSaterday(sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        self.arrSelectedDays.append("SA")
    }
    
    @IBAction func actionChangeDate(sender: UIButton) {
 
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
                                formatter.dateFormat = "yyyy-MM-dd"
                                let dateStr = formatter.string(from: dt)
                                sender.setTitle(dateStr, for: .normal)
                            }
        }
    }
    
    func setBtnBorder (arrBtn:[UIButton]){
        for btn in arrBtn{
            btn.layer.borderColor = APPGRAYCOLOR.cgColor
            btn.layer.borderWidth = 0.5
            btn.layer.cornerRadius = 5
            btn.clipsToBounds = true
        }
    }
}

extension PopUpWeeklyRepeatTVC {
    func stringToDate(strDate:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.date(from: strDate)!
    }
    
    func dateToString(dt:Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: dt)
    }
}

