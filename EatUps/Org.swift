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
    
    var id: String?
    var name: String?

    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
    }
}
