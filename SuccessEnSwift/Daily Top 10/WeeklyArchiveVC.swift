
import UIKit

var isSelectedRow = ""

class WeeklyArchiveVC: UIViewController {
    
    @IBOutlet var weekDropDown : UIDropDown!
    @IBOutlet var stackBtn : UIStackView!
    @IBOutlet var tblList : UITableView!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var noDataView : UIView!
    
    var arrStackBtn = [UIButton]()

    var arrWeeksData = [String]()
    var datesBetweenArray  = [String]()
    var arrDays = [String]()
    
    var arrScoreData = [AnyObject]()
    var arrFirstName = [String]()
    var arrScore = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.weekDropDown.textColor = .black
        self.weekDropDown.tint = .black
        self.weekDropDown.optionsSize = 15.0
        self.weekDropDown.placeholder = "Select Week"
        self.weekDropDown.optionsTextAlignment = NSTextAlignment.center
        self.weekDropDown.textAlignment = NSTextAlignment.center
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getWeeksDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
        
        self.tblList.tableFooterView = UIView()
        self.noDataView.isHidden = false
    }
    
    @IBAction func actionCloseVC(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WeeklyArchiveVC {
    func getWeeksDataFromServer(){
        let dictParam = ["userId":userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getDailyTopWeek", param : dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                self.arrWeeksData = []
                
                var start_date = [String]()
                var end_date = [String]()
                for obj in result {
                    start_date.append(obj["start_date"] as? String ?? "")
                    end_date.append(obj["end_date"] as? String ?? "")
                    let weekTitle = "\(obj["start_date"] as? String ?? "") To \(obj["end_date"] as? String ?? "")"
                    self.arrWeeksData.append(weekTitle)
                    
                }
                
                self.weekDropDown.options = self.arrWeeksData
                self.weekDropDown.placeholder = self.arrWeeksData.last
                isSelectedRow = self.arrWeeksData.last!

                self.designStackView(start_date.last!, end_date.last!)
                
                self.weekDropDown.didSelect { (option, index) in
                    self.weekDropDown.placeholder = self.arrWeeksData[index]
                    isSelectedRow = self.arrWeeksData[index]
                    self.datesBetweenArray = []
                    self.arrDays = []
                    self.designStackView(start_date[index], end_date[index])
                    self.arrFirstName = []
                    self.arrScore = []
                    self.tblList.reloadData()
                    self.noDataView.isHidden = false
                }
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
        }
    }
    
    func designStackView(_ fromDt:String, _ toDt:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        let startDate = dateFormatter.date(from: fromDt)
        let endDate = dateFormatter.date(from: toDt)
        
        if startDate == nil || endDate == nil {
            OBJCOM.setAlert(_title: "", message: "Something went wrong, please try again..")
            return
        }
        
        self.datesBetweenArray = Date().generateDatesArrayBetweenTwoDates(startDate: startDate!, endDate: endDate!)
        print(self.datesBetweenArray)
        
        for obj in self.datesBetweenArray {
            let strDayName = self.getDayNameBy(obj)
            self.arrDays.append(strDayName)
        }
        print(self.arrDays)
        
        if self.arrDays.count > 0 {
            
            for view in self.stackBtn.subviews {
                view.removeFromSuperview()
            }
            arrStackBtn = []
            for i in 0 ..< self.arrDays.count {
                let button = UIButton()
                button.backgroundColor = .white
                button.layer.cornerRadius = 5.0
                button.layer.borderColor = UIColor.black.cgColor
                button.layer.borderWidth = 1
                button.clipsToBounds = true
                button.tag = i
               
                button.setTitle(String(self.arrDays[i].prefix(3)), for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.setTitleColor(APPORANGECOLOR, for: .selected)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                button.addTarget(self, action: #selector(self.actionSelectDay(_:)), for: .touchUpInside)
                self.stackBtn.addArrangedSubview(button)
                arrStackBtn.append(button)
            }
        }
    }
    
    @objc func actionSelectDay(_ sender:UIButton) {
        self.noDataView.isHidden = true
        updateButton(sender)
        self.lblTitle.text = "Top 10 score of \(self.arrDays[sender.tag])"
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getDailyScoreData(self.datesBetweenArray[sender.tag])
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func updateButton(_ sender: UIButton){
        arrStackBtn.forEach { $0.isSelected = false }
        sender.isSelected = !sender.isSelected
    }
    
    func getDayNameBy(_ stringDate: String) -> String
    {
        let df  = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: stringDate)!
        df.dateFormat = "EEEE"
        return df.string(from: date);
    }
}

extension WeeklyArchiveVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFirstName.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTopTenCell
        cell.lblRecruitName.text = self.arrFirstName[indexPath.row]
        cell.lblScore.text = self.arrScore[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func getDailyScoreData(_ strDate : String){
        
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "type":"weekly",
                         "scoreDate":strDate]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "dailyTopTenScore", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            self.arrFirstName = []
            self.arrScore = []
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrScoreData = JsonDict!["result"] as! [AnyObject]
                if self.arrScoreData.count > 0 {
                    self.arrFirstName = self.arrScoreData.compactMap { $0["recruitUserName"] as? String}
                    self.arrScore = self.arrScoreData.compactMap { $0["recruitUserScoreValue"] as? String }
                }
                OBJCOM.hideLoader()
            }else{
                OBJCOM.hideLoader()
            }
            
            self.tblList.reloadData()
        }
    }
}

extension Date{
    func generateDatesArrayBetweenTwoDates(startDate: Date, endDate:Date) -> [String]
    {
        var datesArray =  [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "MMM-dd-yyyy"
        let calendar = Calendar.current
        var date = startDate // first date
        let endDate = endDate // last date
        
        datesArray = []
        while date <= endDate {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: date)
            datesArray.append(strDate)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return datesArray
    }
}




