//
//  MotivationalVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 05/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class MotivationalVC: UIViewController {
    
    @IBOutlet var lblTotalScore : UILabel!
    @IBOutlet var lblQuote : UILabel!
    @IBOutlet var lblQuoteAuthor : UILabel!
    @IBOutlet var lblReason : UILabel!
    @IBOutlet var lblWelcomeLblFirst : UILabel!
    @IBOutlet var lblForMotivationalQuoteofDay : UILabel!
    @IBOutlet var viewBckRadious : UIView!
    @IBOutlet var imgBusiness : UIImageView!
    @IBOutlet var imgEmotion : UIImageView!
    @IBOutlet var btnGotoDashboard : UIButton!
    
    var dict : AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set("true", forKey: "MOTIVATIONAL")
        UserDefaults.standard.synchronize()
        
        btnGotoDashboard.layer.cornerRadius = 5.0
        btnGotoDashboard.layer.borderColor = APPORANGECOLOR.cgColor
        btnGotoDashboard.layer.borderWidth = 1.0
        btnGotoDashboard.clipsToBounds = true
        
        lblQuote.text = dict["quote"] as? String ?? ""
        lblQuoteAuthor.text = dict["quoteAuthor"] as? String ?? ""
        lblReason.text = dict["reason"] as? String ?? ""
        let totalScore = dict["totalScore"]! ?? ""
        let categoryLevel = dict["categoryLevel"]! ?? ""
        lblTotalScore.text = "Your total score is \(totalScore). \(categoryLevel)"
        lblWelcomeLblFirst.text = dict["progressText"] as? String ?? ""
        let busiImg = dict["dreamImage"] as? String ?? ""
        if busiImg != "" {
//            imgBusiness.imageFromServerURL(urlString: busiImg)
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                if let url = URL(string: busiImg) {
                    do{
                        let data = try Data.init(contentsOf: url)
                        DispatchQueue.main.async {
                            self.imgBusiness.image = UIImage(data: data)
                        }
                    }catch{
                        
                    }
                }
            }

        }else{
            imgBusiness.image = #imageLiteral(resourceName: "alamo_sunrise")
        }
        
//        let emoji = dict["emoticonImage"] as? String ?? ""
//        if emoji != "" {
//            imgEmotion.imageFromServerURL(urlString: emoji)
//        }else{
            imgEmotion.image = #imageLiteral(resourceName: "EmojiSPECT")
//        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7){
            // your code with delay
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func actionGoToDashboard(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
