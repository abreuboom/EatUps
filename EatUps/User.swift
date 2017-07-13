//
//  User.swift
//  
//
//  Created by John Abreu on 7/12/17.
//
//

import Foundation
import UIKit

class User {
    
    // Styles round profile picture icons
    class func getRoundProfilePics(photoView: UIImageView) {
        photoView.layer.borderWidth = 1
        photoView.layer.masksToBounds = false
        photoView.layer.borderColor = UIColor.white.cgColor
        photoView.layer.cornerRadius = photoView.frame.height/2
        photoView.clipsToBounds = true
    }
    
}
