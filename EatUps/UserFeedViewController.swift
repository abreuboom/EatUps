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
        
        databaseHandle = ref.child("users").observe(.value , with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (user, info) in data! {
                let tempUser = User.init(dictionary: info as! [String : Any])
                tempUser.id = user as? String
                if APIManager.shared.containsUser(arr: self.availableUsers, targetUser: tempUser) == false {
                    self.availableUsers.append(tempUser)
                }
            }
            self.collectionView.reloadData()
            print(self.availableUsers)

        })
        
//        APIManager.shared.getUsers { (success, users) in
//            if success == true {
//                self.availableUsers = users
//                self.collectionView.reloadData()
//                print(self.availableUsers)
//            }
//            else {
//                print("getUsers() failed")
//            }
//        }

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
    
    func getAvailableUsers() {
        databaseHandle = ref.child("users").observe(.value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            for (user, info) in data! {
                let userDictionary = info as! NSDictionary
                if let locationString = userDictionary["location"] as? String {
                    let latitude = Double((locationString.components(separatedBy: ",")[0]))
                    let longitude = Double((locationString.components(separatedBy: ",")[1]))
                    let location = CLLocationCoordinate2DMake(latitude!, longitude!)
                    
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
