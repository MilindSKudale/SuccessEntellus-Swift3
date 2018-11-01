//
//  EmailCampaignView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

var whichView = ""

class EmailCampaignView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        whichView = "EmailCampaign"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.createSpotlight()
    }
    
    func createSpotlight(){
        
        let viewSwitchStatusPoint = CGPoint(x: 275, y: 140)
        let itemsToBeHighlighted : [WalkthroughItemType] = [
            (point: viewSwitchStatusPoint,
             height: 40,
             width: 40,
             title: "Email Campaigns",
             description: "Add email to send email campaigns.")]
        
        showWalkthroughView(currentViewController: self, itemsToBeHighlighted: itemsToBeHighlighted)
        
        
    }

}
