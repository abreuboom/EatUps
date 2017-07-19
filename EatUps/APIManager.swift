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
    
    var places: [String] = []
    var users: [User] = []
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    // MARK: TODO: Add App Keys
    
    // MARK: Facebook API methods
    
    // MARK: TODO: Get User Feed
    
    
    func setUpDatabaseHandle(org_id: String, completion: @escaping (_ success: Bool, [String]) -> ()) {
        databaseHandle = ref.child("orgs/\(org_id)/places").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (place, _) in data! {
                let placeName = place as! String
                self.places.append(placeName)
                print(self.places)
                print(placeName)
            }
            if self.places.isEmpty == true {
                completion(false, self.places)
            }
            else {
                completion(true, self.places)
            }
        })
    }
    
    func getUsers(completion: @escaping (Bool, [User]) -> ()) {
        databaseHandle = ref.child("users").observe(.childChanged, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            let tempUser = User.init(dictionary: data as! [String : Any])
            tempUser.id = snapshot.key
            self.users.append(tempUser)

            if self.users.isEmpty == true {
                completion(false, self.users)
            }
            else {
                completion(true, self.users)
            }
        })
    }
}
