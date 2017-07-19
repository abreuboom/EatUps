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
    
    // For user persistance
    var dictionary: [String: Any]?
    
    private static var _current: User?
    
    static var current: User? {
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.data(forKey: "currentUserData") {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
                    _current = User(dictionary: dictionary)
                }
            }
            return _current
        }
        set (user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
        }
    }
    
    var facebook_id: String
    var name: String
    var org_id: String
    var profilePhotoUrl: URL?
    var id: String?
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        facebook_id = dictionary["id"] as! String
        name = dictionary["name"] as! String
        org_id = dictionary["org_id"] as! String
        let photoUrl = dictionary["profilePhotoURL"] as! String
        profilePhotoUrl = URL(string: photoUrl)
    }
    
    // Styles round profile picture icons
    class func getRoundProfilePics(photoView: UIImageView) {
        photoView.layer.borderWidth = 1
        photoView.layer.masksToBounds = false
        photoView.layer.borderColor = UIColor.white.cgColor
        photoView.layer.cornerRadius = photoView.frame.height/2
        photoView.clipsToBounds = true
    }
}
