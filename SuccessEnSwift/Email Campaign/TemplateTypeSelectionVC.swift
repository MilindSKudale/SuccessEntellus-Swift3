//
//  TemplateTypeSelectionVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 24/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TemplateTypeSelectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var templateSelectionCV : UICollectionView!

    var arrTemplateType = [String]()
    var arrTemplateImage = [String]()
    var arrTemplateId = [String]()
    
    var campaignId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.getTemplateSelection()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC(_ :)), name: NSNotification.Name(rawValue: "DISMISSVIEW"), object: nil)
    }
    
    @objc func dismissVC(_ notification: NSNotification){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTemplateType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = templateSelectionCV.dequeueReusableCell(withReuseIdentifier: "TemplateCell", for: indexPath) as! TemplateSelectionCell
        
        cell.lblTemplateType.text = self.arrTemplateType[indexPath.row]
        let imgUrl = self.arrTemplateImage[indexPath.row]
        if imgUrl != "" {
            cell.imgTemplate.imageFromServerURL(urlString: imgUrl)
        }
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(selectTemplateForAddTempalte(_:)), for: .touchUpInside)
        return cell
    }
    //
    
    @IBAction func selectTemplateForAddTempalte (_ sender : UIButton){
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idAddTemplateVC") as! AddTemplateVC
        vc.campaignId = campaignId
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func getTemplateSelection(){
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getTemplateSelection", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                if dictJsonData.count > 0 {
                    self.arrTemplateType = []
                    self.arrTemplateId = []
                    self.arrTemplateImage = []
                    
                    
                    for obj in dictJsonData {
                        self.arrTemplateType.append(obj.value(forKey: "labelTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignTemplateId") as! String)
                        self.arrTemplateImage.append(obj.value(forKey: "imageUrl") as! String)
//
                    }
                }
                self.templateSelectionCV.delegate = self;
                self.templateSelectionCV.dataSource = self
                self.templateSelectionCV.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
