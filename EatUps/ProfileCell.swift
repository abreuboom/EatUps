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
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var eatupCount: UILabel!
    @IBOutlet weak var friendsCount: UILabel!
    
    var parent: ProfileViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.cornerRadius = 25
        cardView.dropShadow()
        
        photoView.setImageWith(User.current?.profilePhotoUrl, placeholder: #imageLiteral(resourceName: "gray_circle"), options: [.progressiveBlur, .setImageWithFadeAnimation], completion: nil)
        
        nameLabel.text = User.current?.name
        
        
        APIManager.shared.getOrg(orgId: (User.current?.org_id)!) { (success, org) in
            if success == true {
                self.orgLabel.text = org.name
            }
        }
    }
    
    @IBAction func editProfile(_ sender: RoundedButton) {
//        self.parent
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
