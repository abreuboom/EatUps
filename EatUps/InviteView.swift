//
//  CardView.swift
//  EatUps
//
//  Created by John Abreu on 7/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class InviteView: UIView {
    
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UIButton!
    
    var eatup: EatUp?

    @IBAction func acceptEatup(_ sender: UIButton) {
        let eatupId = eatup?.id ?? ""
        APIManager.shared.handleInvite(eatupId: eatupId, response: true, completion: { (success) in
            if success == true {
                let userFeedVC = super.superview as! UserFeedViewController
                userFeedVC.performSegue(withIdentifier: "pendingToFindSegue", sender: nil)
            }
        })
    }
    
    @IBAction func rejectEatup(_ sender: UIButton) {
        let eatupId = eatup?.id ?? ""
        APIManager.shared.handleInvite(eatupId: eatupId, response: false, completion: { (success) in
            if success == true {
                let userFeedVC = super.superview as! UserFeedViewController
                userFeedVC.animateInviteOut()
            }
        })
    }
    
    func populateInviteInfo() {
        let inviter = eatup?.inviter
        APIManager.shared.getUser(uid: inviter!) { (success, inviter) in
            if success == true {
                if let photoURL = inviter.profilePhotoUrl {
                    self.profilePhotoView.af_setImage(withURL: photoURL)
                    User.getRoundProfilePics(photoView: self.profilePhotoView)
                }
                if let name = inviter.name {
                    self.nameLabel.text = User.firstName(name: name)
                }
            }
        }
        placeLabel.setTitle(eatup?.place, for: .normal)
        placeLabel.sizeToFit()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
