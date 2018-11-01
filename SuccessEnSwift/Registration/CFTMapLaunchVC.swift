//
//  CFTMapLaunchVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 07/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CFTMapLaunchVC: UIViewController {

    @IBOutlet weak var mapOnboard: SwiftyOnboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapOnboard.style = .light
        mapOnboard.delegate = self
        mapOnboard.dataSource = self
        mapOnboard.backgroundColor = UIColor(red: 46/256, green: 46/256, blue: 76/256, alpha: 1)
        
    }
    
    @objc func handleSkip() {
        mapOnboard?.goToPage(index: 2, animated: true)
    }
    
    @objc func handleContinue(sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idLoginVC") as! LoginVC
        //isCFTMap = true
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func handleSubsribeNow(sender: UIButton) {
        print("SUBSCRIBE NOW")
        if let url = URL(string: "https://successentellus.com/signup/register") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension CFTMapLaunchVC: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 1
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as? CustomPage
        
        view?.titleLabel.text = "Are you located here?"
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
      //  overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay?.skip.isHidden = true
        overlay?.buttonLogin.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
      //  overlay?.buttonSubscribe.addTarget(self, action: #selector(handleSubsribeNow), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
       // let currentPage = round(position)
       // overlay.pageControl.currentPage = Int(currentPage)
        overlay.buttonLogin.tag = Int(position)
//        overlay.buttonSubscribe.tag = Int(position)
//        overlay.buttonSubscribe.setTitle("Subscribe Now", for: .normal)
        overlay.buttonLogin.setTitle("Log In", for: .normal)
        overlay.skip.setTitle("", for: .normal)
        overlay.skip.isHidden = true
       
    }
    
    
}

