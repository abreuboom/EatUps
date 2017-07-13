//
//  Org.swift
//  EatUps
//
//  Created by John Abreu on 7/12/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import Foundation

class Org {
    
    // For user persistance
    var dictionary: [String: Any]?
    
    var id: Int64
    var name: String
    var type: String?
    var users: [Int64]?

    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        id = dictionary["id"] as! Int64
        name = dictionary["name"] as! String
        type = dictionary["type"] as? String
        users = dictionary["users"] as? [Int64]
    }
}
