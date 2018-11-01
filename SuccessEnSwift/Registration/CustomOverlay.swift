//
//  CustomOverlay.swift
//  SwiftyOnboardExample
//
//  Created by Jay on 3/27/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

class CustomOverlay: SwiftyOnboardOverlay {
    
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
  //  @IBOutlet weak var buttonSubscribe: UIButton!
    @IBOutlet weak var contentControl: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonLogin.layer.borderColor = UIColor.white.cgColor
        buttonLogin.layer.borderWidth = 1
        buttonLogin.layer.cornerRadius = buttonLogin.bounds.height / 2
        
//        buttonSubscribe.layer.borderColor = UIColor.white.cgColor
//        buttonSubscribe.layer.borderWidth = 1
//        buttonSubscribe.layer.cornerRadius = buttonSubscribe.bounds.height / 2
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomOverlay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}
