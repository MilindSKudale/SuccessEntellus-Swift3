//
//  EmailDetailsHeader.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 26/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit
import LUExpandableTableView

final class EmailDetailsHeader: LUExpandableTableViewSectionHeader {
    // MARK: - Properties
    
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
            expandCollapseButton?.setImage(isExpanded ? #imageLiteral(resourceName: "up-arrow") : #imageLiteral(resourceName: "right-arrow"), for: .normal)
            
        }
    }
    
    // MARK: - Base Class Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelName?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel)))
        labelName?.isUserInteractionEnabled = true
        labelStatus?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel)))
        labelStatus?.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions
    
    @IBAction func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
    
    // MARK: - Private Functions
    
    @objc private func didTapOnLabel(_ sender: UIGestureRecognizer) {
        // Send the message to his delegate that was selected
        delegate?.expandableSectionHeader(self, wasSelectedAtSection: section)
    }
}
