//
//  EatupAtView.swift
//  EatUps
//
//  Created by John Abreu on 7/28/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import ActiveLabel
import ChameleonFramework

class EatupAtView: UIView {
    
    @IBOutlet weak var eatupAtLabel: ActiveLabel!
    
    var place: String? {
        didSet {
            eatupAtLabel.customize { (label) in
                eatupAtLabel.mentionColor = HexColor(hexString: "FE3F67")
                eatupAtLabel.handleMentionTap({ (_) in
                    self.parentViewController?.navigationController?.popViewController(animated: true)
                })
            }
            eatupAtLabel.text = eatupAtLabel.text! + place! + " with"
            eatupAtLabel.sizeToFit()

        }
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
