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
        
        eatUpButton.layer.cornerRadius = eatUpButton.frame.width/3
        eatUpButton.layer.masksToBounds = true
        eatUpButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        eatUpButton.sizeToFit()
        eatUpButton.invalidateIntrinsicContentSize()
        
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
        collectionView.alwaysBounceVertical = true
        
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
        
        cell.cardView.tag = indexPath.item
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectUpee(_:)))
        tapped.numberOfTapsRequired = 1
        
        cell.cardView.addGestureRecognizer(tapped)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableUsers.count
    }
    
    // Changes views and stores selected user
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        cell.cardView.backgroundColor = UIColor(red: 254/255, green: 63/255, blue: 103/255, alpha: 1)
        cell.nameLabel.textColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        cell.cardView.backgroundColor = UIColor.white
        cell.nameLabel.textColor = UIColor.black
    }
    
    func selectUpee(_ sender: UITapGestureRecognizer) {
        let selectedUser = availableUsers[(sender.view?.tag)!]
        let name = selectedUser.name
        eatUpButton.titleLabel?.text = "EatUp with \(name)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
