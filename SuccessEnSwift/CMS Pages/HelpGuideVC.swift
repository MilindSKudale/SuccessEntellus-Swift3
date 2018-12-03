//
//  HelpGuideVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class HelpGuideVC: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var tblDocList : UITableView!
    
    var arrDocTitle = [String]()
    var arrDocUrl = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblDocList.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getDataFromServer()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }

    func getDataFromServer(){
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getStepByStepStaticList", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            
            self.arrDocTitle = []
            self.arrDocUrl = []
            
            let result = JsonDict!["result"] as! [AnyObject]
            
            for obj in result {
                self.arrDocTitle.append(obj.value(forKey: "stepStaticTitle") as! String)
                self.arrDocUrl.append(obj.value(forKey: "stepStaticUrl") as! String)
            }
            self.tblDocList.reloadData()
            OBJCOM.hideLoader()
            
        };
    }
}

extension HelpGuideVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDocTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblDocList.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HelpGuideCell
        cell.lblDocName.text = self.arrDocTitle[indexPath.row]
        cell.btnDownload.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(actionDownloadDoc(_ :)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func actionDownloadDoc(_ sender : UIButton){
        
        let storyboard = UIStoryboard(name: "CMS", bundle: nil)
        if #available(iOS 11.0, *) {
            let vc = storyboard.instantiateViewController(withIdentifier: "idpdfViewVC") as! pdfViewVC
            vc.pdfName = self.arrDocTitle[sender.tag]
            vc.pdfUrl = self.arrDocUrl[sender.tag]
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            self.present(vc, animated: false, completion: nil)
        } else {
            // Fallback on earlier versions
            
        }
        
        
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
