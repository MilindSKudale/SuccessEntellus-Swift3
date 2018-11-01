
import UIKit

class DocumentListVC: UIViewController {
    
    @IBOutlet var tblDocumentList : UITableView!
    @IBOutlet var btnAddDocs : UIButton!
    
    var arrFileImage = [String]()
    var arrFileNameToShow = [String]()
    var arrFileOri = [String]()
    var arrFilePath = [String]()
    
    var arrSelectedFile = [String]()
    var arrSelectedFilePath = [String]()
    var className = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrSelectedFile = []

        btnAddDocs.layer.cornerRadius = 5.0
        btnAddDocs.clipsToBounds = true
        tblDocumentList.tableFooterView = UIView()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getDocumentList()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionAddDocuments(_ sender : UIButton) {
        
        if self.arrSelectedFile.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please select atleast one document to upload.")
            return
        }
        
        if self.className == "AddEmailTemplate" {
            var dict = [AnyObject]()
            for i in 0 ..< self.arrSelectedFile.count {
                let param = ["fileOri":self.arrSelectedFile[i],
                             "filePath":self.arrSelectedFilePath[i]]
                
                dict.append(param as AnyObject)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ADDFILES"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }else if self.className == "EditEmailTemplate" {
            var dict = [AnyObject]()
            for i in 0 ..< self.arrSelectedFile.count {
                let param = ["fileOri":self.arrSelectedFile[i],
                             "filePath":self.arrSelectedFilePath[i]]
                
                dict.append(param as AnyObject)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EDITFILES"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }else if self.className == "AddTextMessage" {
            var dict = [AnyObject]()
            for i in 0 ..< self.arrSelectedFile.count {
                let param = ["fileOri":self.arrSelectedFile[i],
                             "filePath":self.arrSelectedFilePath[i]]
                
                dict.append(param as AnyObject)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ADDTEXTMSG"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }else if self.className == "EditTextMessage" {
            var dict = [AnyObject]()
            for i in 0 ..< self.arrSelectedFile.count {
                let param = ["fileOri":self.arrSelectedFile[i],
                             "filePath":self.arrSelectedFilePath[i]]
                
                dict.append(param as AnyObject)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EDITTEXTMSG"), object: dict)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func actionClose(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DocumentListVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFileNameToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblDocumentList.dequeueReusableCell(withIdentifier: "Cell") as! DocumentListCell
        
        cell.lblDocTitle.text = self.arrFileNameToShow[indexPath.row]
    
        let docImg =  self.arrFileImage[indexPath.row]
        if docImg != "" {
            cell.imgDoc.imageFromServerURL(urlString: docImg)
        }else{
            cell.imgDoc.image = #imageLiteral(resourceName: "help_tip")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tblDocumentList.cellForRow(at: indexPath) as! DocumentListCell
        
        let file = self.arrFileOri[indexPath.row]
        let filePath = self.arrFilePath[indexPath.row]
        
        if arrSelectedFile.contains(file) {
            let index = arrSelectedFile.index(of: file)
            let indexFile = arrSelectedFilePath.index(of: filePath)
            cell.btnSelect.isSelected = false
            arrSelectedFile.remove(at: index!)
            arrSelectedFilePath.remove(at: indexFile!)
        }else{
            cell.btnSelect.isSelected = true
            arrSelectedFile.append(file)
            arrSelectedFilePath.append(filePath)
        }
    }
}

extension DocumentListVC {
    //getFromSaveDocument
    
    func getDocumentList(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getFromSaveDocument", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrFileImage = []
            self.arrFileNameToShow = []
            self.arrFileOri = []
            self.arrFilePath = []
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                
                let result = JsonDict!["result"] as! [AnyObject]
               // print(result)
                
                for obj in result {
                    self.arrFileImage.append(obj["fileImage"] as? String ?? "")
                    self.arrFileNameToShow.append(obj["fileNameToShow"] as? String ?? "")
                    self.arrFileOri.append(obj["fileOri"] as? String ?? "")
                    self.arrFilePath.append(obj["filePath"] as? String ?? "")
                }
                self.tblDocumentList.reloadData()
                OBJCOM.hideLoader()
            }else{
                self.tblDocumentList.reloadData()
                OBJCOM.hideLoader()
            }
        };
    }
}



