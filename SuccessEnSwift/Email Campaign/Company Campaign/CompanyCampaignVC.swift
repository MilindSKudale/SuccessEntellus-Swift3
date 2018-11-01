//
//  CompanyCampaignVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CompanyCampaignVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var companyCampaign = ""
    var campaignID = ""
    var index : Int!
    // Campaign info declaration
    var arrCampaignTitle = [String]()
    var arrCampaignId = [String]()
    var arrCampaignDays = [String]()
    var arrCampaignColor = [AnyObject]()
    var arrCampaignImage = [String]()
    var arrCampaignStepContent = [String]()
    
    @IBOutlet var collectView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            DispatchQueue.main.async {
                self.companyCampaign = "1"
                self.campaignID = "1"
                self.index = Int(self.campaignID)! - 1;
                self.getEmailCampaignData()
            }
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
 
    func getEmailCampaignData(){
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "companyCampaign":self.companyCampaign]

        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];

        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getCampaign", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                self.arrCampaignTitle = []
                self.arrCampaignId = []
                let dictJsonData = JsonDict!["result"] as! [AnyObject]
                print(dictJsonData)
                
                for obj in dictJsonData {
                    self.arrCampaignTitle.append(obj.value(forKey: "campaignTitle") as! String)
                    self.arrCampaignId.append(obj.value(forKey: "campaignId") as! String)
                    self.arrCampaignImage.append(obj.value(forKey: "campaignImage") as! String)
                    self.arrCampaignColor.append(obj.value(forKey: "campaignColor") as AnyObject)
                    
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCampaignTitle.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectView.dequeueReusableCell(withReuseIdentifier: "CollectCell", for: indexPath) as! CollectionViewCell
        cell.labelCampaignName.text = self.arrCampaignTitle[indexPath.row]
        let imgUrl = self.arrCampaignImage[indexPath.row]
        if imgUrl != "" {
            cell.campIcon.imageFromServerURL(urlString: imgUrl)
        }
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let redColor = colorObj.object(at: 0)
            let blueColor = colorObj.object(at: 2)
            let greenColor = colorObj.object(at: 1)

            cell.view.backgroundColor = UIColor.init(red: redColor as! Int, green: greenColor as! Int, blue: blueColor as! Int)
            cell.view.layer.cornerRadius = 5.0;
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var bgColor = UIColor()
        let colorObj = self.arrCampaignColor[indexPath.row]
        if colorObj.count > 0 {
            let redColor = colorObj.object(at: 0)
            let blueColor = colorObj.object(at: 2)
            let greenColor = colorObj.object(at: 1)
            
            bgColor = UIColor.init(red: redColor as! Int, green: greenColor as! Int, blue: blueColor as! Int)
            
        }
    
        let storyboard = UIStoryboard(name: "EmailCampaign", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idCompanyCampaignDetailVC") as! CompanyCampaignDetailVC
        vc.companyCampaign = "\(indexPath.row + 1)"
        vc.bgColor = bgColor
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
    
    
}



