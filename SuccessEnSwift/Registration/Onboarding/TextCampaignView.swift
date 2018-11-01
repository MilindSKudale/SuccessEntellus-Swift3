//
//  TextCampaignView.swift
//  SuccessEnSwift
//  Created by Milind Kudale on 16/09/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TextCampaignView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        whichView = "TextCampaign"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.createSpotlight()
    }
    
    func createSpotlight(){
        
        let viewSwitchStatusPoint = CGPoint(x: 30, y: 80)
        let itemsToBeHighlighted : [WalkthroughItemType] = [
            (point: viewSwitchStatusPoint,
             height: 50,
             width: self.view.frame.width - 60,
             title: "Text Campaigns",
             description: "Create text message in text campaigns.")]
        
        showWalkthroughView(currentViewController: self, itemsToBeHighlighted: itemsToBeHighlighted)
        
        
    }

}
