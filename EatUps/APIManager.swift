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

    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
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
                self.getCurrentUser(completion: { (successBool, dictionary) in
                    if successBool == true {
                        User.current = User(dictionary: dictionary)

                        let id = Auth.auth().currentUser?.uid

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
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        User.current = nil

        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)

    }

    func setOrgId(org_id: String) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        ref.child("users/\(uid)/org_id").setValue(org_id)
    }

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

    func getPlaceLocation(place: String) {
        // Gets location information of eatUp place
        let userOrg = String(describing: User.current?.org_id)
        // change back to userOrg
        databaseHandle = self.ref.child("orgs/org_id/places/\(place)").observe(.value, with:{ (snapshot) in
            let placeDictionary = snapshot.value as? NSDictionary
            print(placeDictionary ?? "")
            //            let placeLocationString =
            //            let placeLocation = EatUp.stringToCLLocation(locationString: placeLocationString)
        })
    }

    // Gets users in a set radius around the EatUp location
    func getAvailableUsers(place: String, completion: @escaping (Bool, [User]) -> ()) {

        getPlaceLocation(place: place)

        // Gets location information of each user
        self.databaseHandle = self.ref.child("users").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary

            for (user, info) in data! {
                let userDictionary = info as! NSDictionary
                // Converts user's location string into CLLocation
                if let userLocationString = userDictionary["location"] as? String {
                    let userLocation = EatUp.stringToCLLocation(locationString: userLocationString)

                    let testLocation = CLLocation(latitude: 37.785834, longitude: -122.406417)
                    let distance = Int(userLocation.distance(from: testLocation))

                    //                    let distance = Int(userLocation.distance(from: placeLocation))
                    // Gets nearby users in a given radius
                    let radius = 800
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


    func containsUser(arr: [User], targetUser: User) -> Bool {
        for user in arr {
            if user.id == targetUser.id {
                return true
            }
        }
        return false
    }


    func getCurrentUser(completion: @escaping (Bool, [String: Any]) -> ()) {
        if let uid = Auth.auth().currentUser?.uid {
            self.databaseHandle = self.ref.child("users/\(uid)").observe(.value, with: { (snapshot) in
                if let data = snapshot.value as? [String: Any] {
                    completion(true, data)
                }
                else {
                    completion(false, [:])
                }
            })
        }
    }

    //   func setUpDatabaseHandleRating(
}
