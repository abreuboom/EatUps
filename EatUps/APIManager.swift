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
import CoreLocation
import FacebookCore
import FacebookLogin

class APIManager: SessionManager {

    static var shared: APIManager = APIManager()

    var places: [String] = []
    var users: [User] = []
    var placeLocation = CLLocation()

    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    let loginManager = LoginManager()
    // MARK: TODO: Add App Keys

    // MARK: Facebook API methods

    func login(completion: @escaping (Bool) -> ()) {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.authenticationToken else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)

        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            else {
                let uid = Auth.auth().currentUser?.uid
                self.populateUserInfo(uid: uid!, completion: { (successBool) in
                    if successBool == true {
                        print("successfully logged in")
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                })
            }
        }
    }

    func populateUserInfo(uid: String, completion: @escaping (Bool) -> ()) {
        ref.child("users/\(uid)/org_id").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                self.graphRequest(id: uid, completion: { (successBool) in
                    if successBool == true {
                        print("Created new user")
                    }
                    let photoURL = Auth.auth().currentUser?.photoURL
                    let urlString = photoURL?.absoluteString
                    self.ref.child("users/\(uid)/profilePhotoURL").setValue(urlString!)
                    self.databaseHandle = self.ref.child("users/\(uid)").observe(.value , with: { (snapshot) in
                        if let data = snapshot.value as? [String: Any] {
                            User.current = User(dictionary: data)
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    })
                })
            }
        })
    }

    private func graphRequest(id: String, completion: @escaping (_ success: Bool) -> ()) {
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (response, result) in
            switch result {
            case .failed(let error):
                print("error in graph request:", error)
                completion(false)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue{
                    let facebookId = responseDictionary["id"] as? String
                    let name = responseDictionary["name"] as? String
                    let email = responseDictionary["email"] as? String
                    self.ref.child("users/\(id)").setValue(["id": facebookId, "name": name, "email": email, "org_id": "", "profilePhotoURL": ""])
                    completion(true)
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

    func setOrgId(org_name: String, completion: @escaping (_ success: Bool) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        databaseHandle = ref.child("orgs").observe(.value, with: { (snapshot) in
            let data = snapshot.value as! [String: Any]

            for (id, info) in data {
                let dictionary = info as! [String: Any]
                let name = dictionary["name"] as! String
                if name == org_name {
                    self.ref.child("users/\(uid)/org_id").setValue(id)
                    completion(true)
                }
            }
        })


    }

    // set up the Select Location database handle
    func getPlaces(org_id: String, completion: @escaping (_ success: Bool, [String]) -> ()) {
        print(org_id)
        ref.child("orgs/\(org_id)/places").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? NSDictionary {
                for (place, _) in data {
                    let placeName = place as! String
                    self.places.append(placeName)
                }
                if self.places.isEmpty == true {
                    completion(false, self.places)
                }
                else {
                    completion(true, self.places)
                }
            }
        })
    }

    func getPlaceLocation(place: String, completion: @escaping(Bool, CLLocation) -> ()) {
        let userOrg = User.current?.org_id
        // change back to userOrg
        databaseHandle = self.ref.child("orgs/org_id/places/\(place)").observe(.value, with:{ (snapshot) in
            let placeLocationString = snapshot.value as? String
            self.placeLocation = EatUp.stringToCLLocation(locationString: placeLocationString!)
        })

        if placeLocation == CLLocation() {
            completion(false, CLLocation())
        }
        else {
            completion(true, self.placeLocation)
        }

    }

    // Gets users in a set radius around the EatUp location
    func getAvailableUsers(place: String, completion: @escaping (Bool, [User]) -> ()) {

        // MARK: TODO: Completion handler for getplacelocation
        getPlaceLocation(place: place) { (successBool, placeLocation) in
            if successBool == true {
                // Gets location information of each user
                self.databaseHandle = self.ref.child("users").observe(.value, with: { (snapshot) in
                    let data = snapshot.value as? NSDictionary

                    for (user, info) in data! {
                        let userDictionary = info as! NSDictionary
                        // Converts user's location string into CLLocation
                        if let userLocationString = userDictionary["location"] as? String {
                            let userLocation = EatUp.stringToCLLocation(locationString: userLocationString)

                            // for testing purposes
                            let testLocation = CLLocation(latitude: 37.48137600, longitude: -122.15207300)
                            let distance = Int(userLocation.distance(from: testLocation))
                            // Gets nearby users in a given radius
                            let radius = 20000
                            if distance < radius {
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
                        }
                    }
                })
            }
        }
    }


    func containsUser(arr: [User], targetUser: User) -> Bool {
        for user in arr {
            if user.id == targetUser.id {
                return true
            }
        }
        return false
    }
    
    func setUpDatabaseHandleRating(){
        //        self.ref.child("users/(user.uid)/username").setValue(username)
        databaseHandle = ref.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in

            let child = snapshot.value as? [String: Any]

            for (user, rating) in child! {

                // set user to be the key of the current user

                let currentUserId = User.current?.id

                //if user is not equal to the current id, then set the value of the rating

                if currentUserId != user {
                    // if user is equal to the current id, then print the user's value
                    self.ref.child("eatups/eatup_id/users").child("user_id").setValue("-1")
                } else{
                    print(child)
                }
            }

        })
    }
}
