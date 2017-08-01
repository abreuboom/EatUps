//
//  EatUpCell.swift
//  EatUps
//
//  Created by John Abreu on 7/30/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import YYKit
import DateToolsSwift

class EatUpCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var inviteArrow: UIImageView!
    @IBOutlet weak var invitedLabel: UILabel!
    
    var eatup: EatUp! {
        didSet {
            cardView.layer.cornerRadius = 25
            cardView.dropShadow()
            
            User.getRoundProfilePics(photoView: self.photoView)
            
            placeLabel.text = eatup.place
            let doubleDate = Double(eatup.time)
            let date = Date.init(timeIntervalSince1970: doubleDate)
            timeLabel.text = Date.shortTimeAgo(since: date)
            
            if eatup.invitee == User.current?.id {
                invitedLabel.text = "Invited"
                inviteArrow.image = #imageLiteral(resourceName: "left_arrow")
                
                APIManager.shared.getUser(uid: eatup.inviter) { (success, user) in
                    if success == true {
                        self.photoView.setImageWith(user.profilePhotoUrl, placeholder: #imageLiteral(resourceName: "gray_circle"), options: [.progressiveBlur, .setImageWithFadeAnimation], completion: nil)
                        self.nameLabel.text = User.firstName(name: user.name!)
                        
                    }
                }
            }
            else {
                invitedLabel.text = "Inviter"
                inviteArrow.image = #imageLiteral(resourceName: "right_arrow")
                
                APIManager.shared.getUser(uid: eatup.invitee) { (success, user) in
                    if success == true {
                        self.photoView.setImageWith(user.profilePhotoUrl, placeholder: #imageLiteral(resourceName: "gray_circle"), options: [.progressiveBlur, .setImageWithFadeAnimation], completion: nil)
                        self.nameLabel.text = user.name
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
