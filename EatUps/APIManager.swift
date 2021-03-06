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
                        print("Welcome back \(User.current?.name ?? "")")
                        UserDefaults.standard.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
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
            if snapshot.hasChild("name") {
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
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.width(500)"]).start { (response, result) in
            switch result {
            case .failed(let error):
                print("error in graph request:", error)
                completion(false)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    let facebookId = responseDictionary["id"] as? String
                    let name = responseDictionary["name"] as? String
                    let email = responseDictionary["email"] as? String
                    let imageURL = ((responseDictionary["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String

                    self.ref.child("users/\(id)").setValue(["id": facebookId, "name": name, "email": email, "org_id": "", "profilePhotoURL": imageURL, "status": ""])
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

        UserDefaults.standard.removeObject(forKey: "uid")

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
    func getPlaces(org_id: String, completion: @escaping (_ success: Bool, [String], [String]) -> ()) {
        var places: [String] = []
        var emojis: [String] = []
        ref.child("orgs/\(org_id)/places").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? NSDictionary {
                for (place, _) in data {
                    let placeName = place as! String
                    places.append(placeName)
                }
                self.ref.child("orgs/\(org_id)/emojis").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let emojiDictionary = snapshot.value as? NSDictionary {
                        for (_, emojiData) in emojiDictionary {
                            let emoji = emojiData as! String
                            emojis.append(emoji)
                        }
                        if places.isEmpty == true {
                            completion(false, places, emojis)
                        }
                        else {
                            completion(true, places, emojis)
                        }
                    }
                })

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
        getPlaceLocation(place: place) { (successBool, placeLocation) in
            if successBool == true {
                self.users = []
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

    func getUserLocation(userId: String, completion: @escaping (Bool, CLLocation) -> ()) {
        ref.child("users/\(userId)/location").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? String {
                let location = EatUp.stringToCLLocation(locationString: data)
                if location != nil {
                    completion(true, location)
                }
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
    func requestEatUp(toUserID: String, place: String, completion: @escaping (Bool, String) -> ()) {
        let id = User.current?.id ?? ""

        let eatup = self.ref.child("eatups").childByAutoId()
        let timeStamp = Int(Date().timeIntervalSince1970)
        eatup.setValue(["place": place, "org_id": User.current?.org_id ?? "", "time": timeStamp, "inviter": id, "invitee": "none"])
        eatup.child("users/\(id)").setValue("")
        eatup.child("users/\(toUserID)").setValue("")

        ref.child("users/\(id)/status").setValue(eatup.key)
        ref.child("users/\(toUserID)/status").setValue(eatup.key, withCompletionBlock: { (error, databaseRef) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                completion(true, eatup.key)
            }
        })
    }

    func checkResponse(selectedUser: User, eatupId: String, completion: @escaping (Bool) -> ()) {
        let uid = User.current?.id ?? ""
        databaseHandle = ref.child("eatups/\(eatupId)/invitee").observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? String {
                if data != "" && data != "none" {
                    self.ref.child("eatups/\(eatupId)/time").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let timeStamp = snapshot.value as? Int {
                            self.ref.child("users/\(uid)/eatup_history/\(eatupId)").setValue(timeStamp)
                            completion(true)
                        }
                    })
                }
                else if data == "" {
                    self.ref.child("eatups/\(eatupId)").removeValue()
                    self.ref.child("users/\(uid)/status").setValue("", withCompletionBlock: { (error, databaseReference) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                    completion(false)
                }
            }
            else {
                completion(false)
            }
        })

    }

    // Called when user resets status
    func resetStatus(userID: String) {
        ref.child("users/\(userID)/status").setValue("")
    }

    func checkForInvite(completion: @escaping (Bool, String) -> ()) {
        let uid = Auth.auth().currentUser?.uid
        databaseHandle = ref.child("users/\(uid!)/status").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? String
            if data != "" && data != nil {
                completion(true, data!)
            }
        })
    }

    // Checks if current user has been invited to an eatup and handles their response
    func handleInvite(eatupId: String, response: Bool, completion: @escaping (Bool) -> ()) {
        if let uid = User.current?.id {
            if response == true {
                ref.child("eatups/\(eatupId)/time").observeSingleEvent(of: .value, with: { (snapshot) in
                    let time = snapshot.value as? String
                    self.ref.child("users/\(uid)/eatup_history/\(eatupId)").setValue(time)
                    self.ref.child("eatups/\(eatupId)/invitee").setValue(uid, withCompletionBlock: { (error, databaseRef) in
                        completion(true)
                    })

                })
            }
            else {
                ref.child("users/\(uid)/status").setValue("")
                ref.child("eatups/\(eatupId)/invitee").setValue("", withCompletionBlock: { (error, databaseRef) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    }
                    else {
                        completion(true)
                    }
                })
            }
        }
    }

    // Sets the selected user from an invite in the UserFeedVC
    func setSelectedUserInFeed(currentEatup: EatUp, completion: @escaping (Bool, User) -> ()) {
        ref.child("eatups").child((currentEatup.id!)).child("inviter").observeSingleEvent(of: .value, with: { (snapshot) in
                let inviter = snapshot.value as! String
                APIManager.shared.getUser(uid: inviter) { (success, inviter) in
                    if success == true {
                        completion(true, inviter)
                    }
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

    func getUserEatupIds(completion: @escaping (Bool, [String]) -> ()) {
        let uid = User.current?.id
        var eatups: [String] = []
        ref.child("users/\(uid!)/eatup_history").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? [String: Any]
            for (id, _) in data! {
                eatups.append(id)
            }
            completion(true, eatups)
        })
    }

    func getEatups(eatupIds: [String], completion: @escaping (Bool, [EatUp]) -> ()) {
        var eatups: [EatUp] = []
        for id in eatupIds {
            ref.child("eatups/\(id)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any] {
                    let eatup = EatUp.init(dictionary: data)
                    eatup.id = snapshot.key
                    eatups.append(eatup)
                }
                completion(true, eatups)
            })
        }
    }

    func getOrg(orgId: String, completion: @escaping (Bool, Org) -> ()) {
        ref.child("orgs/\(orgId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let org = Org.init(dictionary: data)
                org.id = snapshot.key
            }
        })
    }

    func getMutualFriends(id: String, completion: @escaping (Bool, [String: Any]) -> ()) {
        GraphRequest(graphPath: "/me", parameters: ["fields": "context.fields(mutual_friends)"]).start { (response, result) in
            switch result {
            case .failed(let error):
                print(error)
                completion(false, [:])
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    if let contextDictionary = responseDictionary["context"] as? [String: Any] {
                        if let mutualDictionary = contextDictionary["mutual_friends"] as? [String: Any] {
                            let data = mutualDictionary["data"] as! [[String: Any]]
                            var mutualFriends: [String: String] = [:]
                            for friend in data {
                                let id = friend["id"] as? String
                                mutualFriends[id!] = friend["name"] as! String
                            }
                            completion(true, mutualFriends)
                        }
                    }
                }
            }
        }
    }

    func getUniqueFriends(eatups: [EatUp], uid: String) -> [String] {
        var friends:[String] = []
        for eatup in eatups {
            if eatup.inviter == uid {
                if friends.contains(eatup.invitee) == false {
                    friends.append(eatup.invitee)
                }
            }
            else if eatup.invitee == uid {
                if friends.contains(eatup.inviter) == false {
                    friends.append(eatup.inviter)
                }
            }
        }
        return friends
    }
}
