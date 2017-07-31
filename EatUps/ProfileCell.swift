//
//  ProfileCell.swift
//  EatUps
//
//  Created by John Abreu on 7/30/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import YYKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    
    @IBOutlet weak var eatupCount: UILabel!
    @IBOutlet weak var invitedCount: UILabel!
    @IBOutlet weak var inviterCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.cornerRadius = 25
        cardView.dropShadow()
        
        photoView.setImageWith(User.current?.profilePhotoUrl, placeholder: #imageLiteral(resourceName: "gray_circle"), options: [.progressiveBlur, .setImageWithFadeAnimation], completion: nil)
        User.getRoundProfilePics(photoView: photoView)
        
        nameLabel.text = User.current?.name
        orgLabel.text = User.current?.org_id
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
