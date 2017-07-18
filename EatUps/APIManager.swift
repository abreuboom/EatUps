//
//  APIManager.swift
//  EatUps
//
//  Created by John Abreu on 7/12/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess
import Firebase
import FirebaseDatabase

class APIManager: SessionManager {
    
    static var shared: APIManager = APIManager()
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    // MARK: TODO: Add App Keys
    // MARK: Facebook API methods
    // MARK: TODO: Get User Feed
    
    
    func getPlaces(org_id: String) -> [String] {
        var places: [String] = []
        databaseHandle = ref.child("orgs/\(org_id)/places").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (place, _) in data! {
                let placeName = place as? String
                places.append(placeName!)
            }
        })
        return places
    }
    
    
    
}
