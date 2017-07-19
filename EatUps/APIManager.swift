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
    
// set up the Select Location database handle
    func setUpDatabaseHandle(org_id: String, completion: @escaping (_ success: Bool, [String]) -> ()) {
        databaseHandle = ref.child("orgs/\(org_id)/places").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (place, _) in data! {
                let placeName = place as! String
                self.places.append(placeName)
            }
            if self.places.isEmpty == true {
                completion(false, self.places)
            }
            else {
                completion(true, self.places)
            }
        })
    }

   
    //get the places
    func getPlaces() -> [String] {
        print(places)
        return places
    }

    
    func getUsers(completion: @escaping (Bool, [User]) -> ()) {
        databaseHandle = ref.observe(.childChanged, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (user, info) in data! {
                let tempUser = User.init(dictionary: info as! [String : Any])
                tempUser.id = user as? String
                if self.containsUser(arr: self.users, targetUser: tempUser) == false {
                    self.users.append(tempUser)
                }
            }
            
            if self.users.isEmpty == true {
                completion(false, self.users)
            }
            else {
                completion(true, self.users)
            }
        })
        
    }
    
    func containsUser(arr: [User], targetUser: User) -> Bool {
        for user in arr {
            if user.id == targetUser.id {
                return true
            }
        }
        return false
    }
    
 //   func setUpDatabaseHandleRating(
}


