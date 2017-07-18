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

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eatUpButton: UIButton!

    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var availableUsers: [User] = []
    var selectedUser: User?
    var eatUp = EatUp()

    var locationManager: CLLocationManager!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAvailableUsers()

        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //CLLocation.distance(from user.current.location : checkLocation)
       
    }
    
    // Gets users in a set radius around the EatUp location
    func getAvailableUsers() {
        // Gets location information of each user
        ref = Database.database().reference()
        databaseHandle = ref.child("users").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (user, info) in data! {
                let userDictionary = info as! NSDictionary
                if let locationString = userDictionary["location"] as? String {
                    let latitude = Double((locationString.components(separatedBy: ",")[0]))
                    let longitude = Double((locationString.components(separatedBy: ",")[1]))
                    let checkLocation = CLLocation(latitude: latitude!, longitude: longitude!)
                    
                    let testLocation = CLLocation(latitude: 37.785834, longitude: -122.406417)
                    let distance = Int(checkLocation.distance(from: testLocation))
                    
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
        // return availableUsers.count - 1
        return 4
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
