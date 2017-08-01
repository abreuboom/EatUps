//
//  UserCell.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//
import UIKit
import AlamofireImage
import YYKit

class AvailableUserCell: UICollectionViewCell {
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    
    var user: User! {
        didSet {
            cardView.layer.cornerRadius = 25
            cardView.dropShadow()
            
            var firstName = User.firstName(name: user.name!)
            
            nameLabel.text = firstName
            if let url = user.profilePhotoUrl {
                photoView.setImageWith(url, placeholder: #imageLiteral(resourceName: "gray_circle"), options: [.progressiveBlur, .setImageWithFadeAnimation], completion: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        User.getRoundProfilePics(photoView: photoView)
    }
}

extension UIView {
    func dropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.layer.shadowRadius = 4
    }
    
    var parentViewController: UserFeedViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UserFeedViewController {
                return viewController
            }
        }
        return nil
    }
}
