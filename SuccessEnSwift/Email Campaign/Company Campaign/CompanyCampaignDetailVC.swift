//
//  CompanyCampaignDetailVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CompanyCampaignDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var companyCampaign = ""
    var bgColor = UIColor()
    var arrTemplateTitle = [String]()
    var arrTemplateId = [String]()
    var arrCampaignId = [String]()
    var arrInterval = [String]()
    var arrIntervalType = [String]()
    var arrTemplateImage = [String]()
    var arrCampaignStepSubject = [String]()
    var arrCampaignHTMLContent = [String]()

    @IBOutlet var collectView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
            self.getEmailCampaignTemplate(campaignID:self.companyCampaign)
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    @IBAction func actionBtnClose(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTemplateTitle.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectView.dequeueReusableCell(withReuseIdentifier: "CollectCell", for: indexPath) as! CompanyCampDetailCell
        cell.labelCampaignName.text = arrTemplateTitle[indexPath.row]
        let strInterval = "\(self.arrInterval[indexPath.row]) \(self.arrIntervalType[indexPath.row])"
        cell.labelInterval.text = strInterval
        let imgUrl = self.arrTemplateImage[indexPath.row]
        if imgUrl != "" {
            cell.templateImage.imageFromServerURL(urlString: imgUrl)
        }
        //cell.view.backgroundColor = bgColor.withAlphaComponent(0.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = ["timeIntervalValue":self.arrInterval[indexPath.row],
                    "timeIntervalType":self.arrIntervalType[indexPath.row],
                    "emailSubject":self.arrTemplateTitle[indexPath.row],
                    "emailHeading":self.arrCampaignStepSubject[indexPath.row],
                    "templateId":self.arrTemplateId[indexPath.row],
                    "campaignId":"",
                    "htmlString":self.arrCampaignHTMLContent[indexPath.row]]
        
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idTemplatePreviewVC") as! TemplatePreviewVC
        vc.htmlString = self.arrCampaignHTMLContent[indexPath.row]
        vc.templateName = self.arrTemplateTitle[indexPath.row]
        vc.isCustomCampaign = false
        //vc.bgColor = bgColor
        vc.dictData = dict
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    func getEmailCampaignTemplate(campaignID:String){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "campaignId":campaignID]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaignEmailTemplate", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let dictJsonData = (JsonDict!["result"] as! [AnyObject])
                print(dictJsonData)
                
                if dictJsonData.count > 0 {
                    self.arrTemplateTitle = []
                    self.arrTemplateId = []
                    self.arrInterval = []
                    self.arrIntervalType = []
                    self.arrCampaignStepSubject = []
                    self.arrCampaignHTMLContent = []
                    self.arrTemplateImage = []
                    
                    for obj in dictJsonData {
                        self.arrTemplateTitle.append(obj.value(forKey: "campaignStepTitle") as! String)
                        self.arrTemplateId.append(obj.value(forKey: "campaignStepId") as! String)
                        self.arrInterval.append(obj.value(forKey: "campaignStepSendInterval") as! String)
                        self.arrIntervalType.append(obj.value(forKey: "campaignStepSendIntervalType") as! String)
                    self.arrCampaignStepSubject.append(obj.value(forKey: "campaignStepSubject") as! String)
                    self.arrCampaignHTMLContent.append(obj.value(forKey: "campaignStepContent") as! String)
                        self.arrTemplateImage.append(obj.value(forKey: "stepImage") as! String)
                        
                    }
                }
                self.collectView.delegate = self;
                self.collectView.dataSource = self
                self.collectView.reloadData()
                OBJCOM.hideLoader()
            }else{
                print("result:",JsonDict ?? "")
                OBJCOM.hideLoader()
            }
        };
    }
}
