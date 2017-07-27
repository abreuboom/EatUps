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
                        User.current?.id = uid
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
        ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                if let data = snapshot.value as? [String: Any] {
                    User.current = User(dictionary: data)
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
            else {
                self.graphRequest(id: uid, completion: { (successBool) in
                    if successBool == true {
                        print("Created new user")

                        let photoURL = Auth.auth().currentUser?.photoURL
                        let urlString = photoURL?.absoluteString
                        self.ref.child("users/\(uid)/profilePhotoURL").setValue(urlString!)
                        self.databaseHandle = self.ref.child("users/\(uid)").observe(.value , with: { (snapshot) in
                            if let data = snapshot.value as? [String: Any] {
                                User.current = User(dictionary: data)
                                completion(true)
                            }
                        })
                    }
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
        var places: [String] = []
        ref.child("orgs/\(org_id)/places").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? NSDictionary {
                for (place, _) in data {
                    let placeName = place as! String
                    places.append(placeName)
                }
                if places.isEmpty == true {
                    completion(false, places)
                }
                else {
                    completion(true, places)
                }
            }
        })
    }

    func getPlaceLocation(place: String, completion: @escaping(Bool, CLLocation) -> ()) {
        if let org_id = User.current?.org_id {
            ref.child("orgs/\(org_id)/places/\(place)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let placeLocationString = snapshot.value as? String {
                    //                let placeLocationString = data[place] as? String
                    self.placeLocation = EatUp.stringToCLLocation(locationString: placeLocationString)
                }
                if self.placeLocation.coordinate.latitude == 0 {
                    if self.placeLocation.coordinate.longitude == 0 {
                        completion(false, CLLocation())
                    }
                }
                else {
                    completion(true, self.placeLocation)
                }

            })
        }

    }

    // Gets users in a set radius around the EatUp location
    func getAvailableUsers(place: String, completion: @escaping (Bool, [User]) -> ()) {
        users = []
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
                            let distance = Int(userLocation.distance(from: placeLocation))
                            // Gets nearby users in a given radius
                            let radius = 350
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


    func getUsersCount(place: String, completion: @escaping(Bool, Int) -> ()) {
        var users: [String] = []
        var availableUsers: [User] = []
        var usersCount: Int?

        getAvailableUsers(place: place) { (success, users) in
            if success == true {
                availableUsers = []
                for user in users {
                    if availableUsers.contains(where: { (storedUser) -> Bool in
                        return storedUser.id == user.id || storedUser.name == user.name
                    }) != true {
                        availableUsers.append(user)
                    }
                }
                usersCount = availableUsers.count
                print(place, availableUsers, usersCount)
                if usersCount == nil {
                    completion(false, -20)
                }
                else {
                    completion(true, usersCount!)
                }
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

    // Returns User object from a given user id
    func getUser(uid: String, completion: @escaping (Bool, User) -> ()) {
        ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let user = User(dictionary: data)
                user.id = snapshot.key
                completion(true, user)
            }
        })
    }

    // MARK: EatUp request handling methods
    // Called when user sends another user an invite
    func requestEatUp(toUserID: String, completion: @escaping (Bool, String) -> ()) {
        let id = User.current?.id ?? ""

        let eatup = self.ref.child("eatups").childByAutoId()
        let timeStamp = String(NSDate().timeIntervalSince1970)
        eatup.setValue(["org_id": User.current?.org_id ?? "", "time": timeStamp, "inviter": id, "invitee": "none"])
        ref.child("users/\(id)/eatup_history/\(eatup.key)").setValue(timeStamp)

        ref.child("users/\(toUserID)/status").setValue(eatup.key)
        ref.child("users/\(id)/status").setValue(eatup.key)
        ref.child("users/\(id)/status").observeSingleEvent(of: .value, with: { (snapshot) in
            if let eatupID = snapshot.value as? String {
                completion(true, eatup.key)
            }
        })
    }

    // Called when user resets status
    func resetStatus(userID: String) {
        ref.child("users/\(userID)/status").setValue("")
    }

    //
    func handleInvite(response: Bool, completion: @escaping (Bool) -> ()) {
        if let id = User.current?.id {
            if response == true {
                ref.child("users/\(id)/status").observeSingleEvent(of: .value, with: { (snapshot) in
                    let eatupID = snapshot.value as? String
                    self.ref.child("eatups/\(eatupID)/time").observeSingleEvent(of: .value, with: { (snapshot) in
                        let time = snapshot.value as? String
                        self.ref.child("users/\(id)/eatup_history/\(eatupID)").setValue(time)
                        self.ref.child("eatups/\(eatupID)/invitee").setValue(id)
                        completion(true)
                    })

                })
            }
            else {
                ref.child("users/\(id)/status").setValue("")
            }
        }
    }

    func checkResponse(selectedUser: User, eatupID: String, completion: @escaping (Bool) -> ()) {
        let uid = User.current?.id
        databaseHandle = ref.child("eatups/\(eatupID)/invitee").observe(.value, with: { (snapshot) in
            let data = snapshot.value as! String
            if data == uid {
                completion(true)
            }
            else if data == "" {
                self.ref.child("eatups/\(eatupID)").removeValue()
                self.ref.child("users/\(uid!)/status").setValue("", withCompletionBlock: { (error, databaseReference) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                completion(false)
            }
        })
    }

    func checkForInvite(completion: @escaping (Bool, String) -> ()) {
        let uid = User.current?.id
        databaseHandle = ref.child("users/\(uid!)/status").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? String
            if data != "" && data != nil {
                completion(true, data!)
            }
        })
    }

    func setUpDatabaseHandleRating() {
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
