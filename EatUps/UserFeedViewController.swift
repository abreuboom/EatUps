//
//  UserFeedViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import BouncyLayout
import FirebaseDatabase
import CoreLocation
import DZNEmptyDataSet
import Firebase

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eatUpButton: UIButton!

    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!

    var users: [String] = []
    var availableUsers: [User] = []
    var selectedUser: User?
    var place: String?


    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        APIManager.shared.getUsers { (success, users) in
            if success == true {
                self.availableUsers = users
                self.collectionView.reloadData()
            }
            else {
                print("getUsers() failed")
            }
        }

        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Don't worry, you'll find someone to EatUp with!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    // Gets users in a set radius around the EatUp location
    func getAvailableUsers() {

        ref = Database.database().reference()

        // Gets location information of eatUp
        let userOrg = Auth.auth().currentUser.org_id
        databaseHandle = ref.queryOrdered(byChild: "orgs/\(u<#T##String#>serOrg).places").queryEqual(toValue: eatUpPlace).observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
        })

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

//                    let distance = Int(checkLocation.distance(from: eatUp.location))
                    let radius = 800
                    if distance < radius {
                        self.availableUsers.append(user as! User)
                    }

                }
            }
        })
    }
    



    // Configuring collection view cell views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "availableUserCell", for: indexPath) as! AvailableUserCell
         cell.user = availableUsers[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableUsers.count
    }

    // Changes views and stores selected user
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        if(cell.isSelected) {
            cell.backgroundColor = UIColor.red
            selectedUser = cell.user
            eatUpButton.isHidden = false
        }
        else {
            cell.backgroundColor = UIColor.white
            eatUpButton.isHidden = true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
