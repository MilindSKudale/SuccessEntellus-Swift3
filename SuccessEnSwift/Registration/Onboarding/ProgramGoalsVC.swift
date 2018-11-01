//
//  ProgramGoalsVC.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ProgramGoalsVC: UIViewController {

    @IBOutlet var uiView : UIView!
    @IBOutlet var btnLetGo : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnLetGo.layer.cornerRadius = btnLetGo.frame.height/2
        btnLetGo.clipsToBounds = true
        uiView.layer.cornerRadius = 8.0
        uiView.clipsToBounds = true
    }
    
    @IBAction func actionLetsGo(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idSetGoalsAndImageVC") as! SetGoalsAndImageVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        //vc.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        self.present(vc, animated: false, completion: nil)
    }
}
