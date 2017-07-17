//
//  UserCell.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import AlamofireImage

class UserCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    var user: User! {
        didSet {
//            nameLabel.text = user.name
//            photoView.af_setImage(withURL: user.profilePicURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        User.getRoundProfilePics(photoView: photoView)
        
    }
    
    
}
