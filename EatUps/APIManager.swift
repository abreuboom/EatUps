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
import FacebookCore
import FacebookLogin

class APIManager: SessionManager {
    
    static var shared: APIManager = APIManager()
    
    var places: [String] = []
    var users: [User] = []
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    let loginManager = LoginManager()
    // MARK: TODO: Add App Keys
    
    // MARK: Facebook API methods
    
    
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.authenticationToken else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            else {
                // MARK: TODO: set User.current, so that it's persisted
                self.getCurrentUser(completion: { (successBool, newUserBool, dictionary) in
                    if successBool == true {
                        let id = Auth.auth().currentUser?.uid
                        User.current = User(dictionary: dictionary)
                        self.graphRequest(id: id!)
                        let photoURL = user?.photoURL
                        let urlString = photoURL?.absoluteString
                        self.ref.child("users/\(id!)/profilePhotoURL").setValue(urlString!)
                        print("successfully logged in")
                        success()
                    }
                })
            }
        }
    }
    
    private func graphRequest(id: String) {
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (response, result) in
            switch result {
            case .failed(let error):
                print("error in graph request:", error)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue{
                    let facebookId = responseDictionary["id"] as? String
                    let name = responseDictionary["name"] as? String
                    let email = responseDictionary["email"] as? String
                    self.ref.child("users/\(id)").setValue(["id": facebookId, "name": name, "email": email])
                }
            }
        }
    }
    
    func logout() {
        loginManager.logOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        User.current = nil
        
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
        
    }
    
    func setOrgId(org_name: String) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        databaseHandle = ref.child("orgs").observe(.value, with: { (snapshot) in
            let data = snapshot.value as! [String: Any]
            
            for (id, info) in data {
                let dictionary = info as! [String: Any]
                let name = dictionary["name"] as! String
                if name == org_name {
                    self.ref.child("users/\(uid)/org_id").setValue(id)
                }
            }
        })
        
        
    }
    
    // set up the Select Location database handle
    func getPlaces(org_id: String, completion: @escaping (_ success: Bool, [String]) -> ()) {
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
    
    func getUsers(completion: @escaping (Bool, [User]) -> ()) {
        
        
    }
    
    func containsUser(arr: [User], targetUser: User) -> Bool {
        for user in arr {
            if user.id == targetUser.id {
                return true
            }
        }
        return false
    }
    
    
    func getCurrentUser(completion: @escaping (Bool, Bool, [String: Any]) -> ()) {
        if let uid = Auth.auth().currentUser?.uid {
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(uid) {
                    self.databaseHandle = self.ref.child("users/\(uid)").observe(.value, with: { (snapshot) in
                        if let data = snapshot.value as? [String: Any] {
                            completion(true, false, data)
                        }
                        else {
                            completion(false, false, [:])
                        }
                    })
                }
                else {
                    completion(true, true, [:])
                }
            })
        }
    }
    
    //   func setUpDatabaseHandleRating(
}


