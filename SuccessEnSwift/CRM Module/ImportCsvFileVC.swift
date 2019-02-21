//
//  ImportCsvFileVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/02/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImportCsvFileVC: UIViewController {
    
    @IBOutlet var bgView : UIView!
    @IBOutlet var btnImport : UIButton!
    var docController:UIDocumentInteractionController!
    
    var arrImpFname = [String]()
    var arrImpMiddle = [String]();
    var arrImpLname = [String]();
    var arrImpEmail = [String]();
    var arrImpPhone = [String]();
    var contactCsvArray:[Dictionary<String, AnyObject>] =  Array()
    var crmFlag = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.designUI()
    }
    
    func designUI(){
        self.bgView.layer.cornerRadius = 5.0
        self.bgView.clipsToBounds = true
        self.btnImport.layer.cornerRadius = 5.0
        self.btnImport.clipsToBounds = true
    }
    
    @IBAction func actionCancel(_ sender : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImportCsv(_ sender : UIButton){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)

    }
    
    @IBAction func actionDownloadSimpleCsv(_ sender : UIButton){
        
        if crmFlag == "1" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/contact.csv")
        }else if crmFlag == "2" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/customer.csv")
        }else if crmFlag == "3" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/prospect.csv")
        }else if crmFlag == "4" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/recruit.csv")
        }
    }

    
    @IBAction func actionDownloadFullCsv(_ sender : UIButton){
        if crmFlag == "1" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/contactfull.csv")
        }else if crmFlag == "2" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/customerfull.csv")
        }else if crmFlag == "3" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/prospectfull.csv")
        }else if crmFlag == "4" {
            self.downloadAndSaveFile("https://www.successentellus.com/assets/recruitfull.csv")
        }
    }


}

extension ImportCsvFileVC {
    /*func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
        
        print(url.lastPathComponent)
        print(url.pathExtension)
        
        if controller.documentPickerMode == .import {
            arrImpFname = [];
            //   arrImpMiddle = [];
            arrImpLname = [];
            arrImpEmail = [];
            arrImpPhone = [];
            
            let content = try? String(contentsOf: url, encoding: .ascii)
            var rows = content?.components(separatedBy: "\n")
            
            var columnsTitle = rows![0].components(separatedBy: ",")
            if columnsTitle.count >= 4 {
                var fn = columnsTitle[0]
                // let mn = columnsTitle[1]
                var ln = columnsTitle[1]
                var em = columnsTitle[2]
                var ph = columnsTitle[3]
                
                fn = fn.replacingOccurrences(of: "\r", with: "")
                ln = ln.replacingOccurrences(of: "\r", with: "")
                em = em.replacingOccurrences(of: "\r", with: "")
                ph = ph.replacingOccurrences(of: "\r", with: "")
                
                if fn == "fname" && ln == "lname" && em == "email" && ph == "phone"{
                    for i in 1..<(rows?.count)!-1 {
                        var columns = rows![i].components(separatedBy: ",")
                        if columns.count > 0{
                            arrImpFname.append(columns[0])
                            // arrImpMiddle.append(columns[1])
                            arrImpLname.append(columns[1])
                            arrImpEmail.append(columns[2])
                            arrImpPhone.append(columns[3])
                        }
                    }
                    var importArray = [AnyObject]()
                    for i in 0..<arrImpFname.count {
                        let tempDict = ["fname": arrImpFname[i],
                                        "lname": arrImpLname[i],
                                        "email": arrImpEmail[i],
                                        "phone": arrImpPhone[i]]
                        importArray.append(tempDict as AnyObject)
                    }
                    if importArray.count > 0 {
        
                        self.importCSVAPIContacts(impArray: importArray, crmFlag: crmFlag)
                    }
                }else{
                    OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
                }
            }else{
                OBJCOM.setAlert(_title: "", message: "Selected file format is invalid.")
            }
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
    }
    
    func importCSVAPIContacts(impArray : [AnyObject], crmFlag : String){
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "crmFlag":crmFlag,
                         "csvDetails": impArray] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "importCsvCrm", param:dictParamTemp as [String : AnyObject],  vcObject: self) {
            JsonDict, staus in
            
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                OBJCOM.hideLoader()
                let result = JsonDict!["result"] as! String
                print(result)
                let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if crmFlag == "1" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                    }else if crmFlag == "2" {
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                    }else if crmFlag == "3" {
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                    }else if crmFlag == "4" {
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }*/
    
    func downloadAndSaveFile(_ urlStr : String){
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var fileURL = self.createFolder(folderName: "SuccessEntellus")
            let fileName = URL(string : urlStr)
            fileURL = fileURL.appendingPathComponent((fileName?.lastPathComponent)!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(urlStr, to: destination).response(completionHandler: { (DefaultDownloadResponse) in
            // print("res >> ",DefaultDownloadResponse.destinationURL!);
            self.docController = UIDocumentInteractionController(url: DefaultDownloadResponse.destinationURL!)
            self.docController.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
        })
    }
    
    func createFolder(folderName:String)->URL
    {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as? String ?? ""
        let dataPath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(folderName).absoluteString
        if !FileManager.default.fileExists(atPath: dataPath) {
            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
        let fileURL = URL(string: dataPath)
        return fileURL!
    }
}
extension ImportCsvFileVC : UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func downloadfile(URL: NSURL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                let statusCode = response?.mimeType
                print("Success: \(String(describing: statusCode))")
                DispatchQueue.main.async(execute: {
                    OBJCOM.importCSVfile(data!, filename: URL.lastPathComponent!, crmFlag: self.crmFlag) {
                        JsonDict in
                        let success:String = JsonDict!["IsSuccess"] as! String
                        if success == "true"{
                            let result = JsonDict!["result"] as? String ?? "CSV Data Imported Successfully!"
                            
                            OBJCOM.hideLoader()
                            let alertController = UIAlertController(title: "", message: result, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                if self.crmFlag == "1" {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateContactList"), object: nil)
                                }else if self.crmFlag == "2" {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomerList"), object: nil)
                                }else if self.crmFlag == "3" {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProspectList"), object: nil)
                                }else if self.crmFlag == "4" {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRecruitList"), object: nil)
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            
                        }else{
                            OBJCOM.hideLoader()
                            let result = JsonDict!["result"] as? String ?? "Nothing to import!"
                            OBJCOM.setAlert(_title: "", message: result)
                        }
                    }
                })
                
            }
            else {
                // Failure
                OBJCOM.hideLoader()
                print("Failure: %@", error!.localizedDescription)
            }
        })
        task.resume()
    }
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url = \(url)")
        
        let pathExtention = url.pathExtension
        if pathExtention == "csv" || pathExtention == "CSV" {
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.downloadfile(URL: url as NSURL)
            }else{
                OBJCOM.showNetworkAlert()
            }
        } else{
            OBJCOM.setAlert(_title: "", message: "Supported file format for importing contact is .csv")
        }
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
