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
    var place: String = ""
    var locationManager: CLLocationManager!
    
    var isUserSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // Populating collection view with available users
        APIManager.shared.getAvailableUsers(place: place) { (success, users) in
            if success == true {
                self.availableUsers = users
                self.collectionView.reloadData()
            }
        }
        
        // Styling eatUp button
        eatUpButton.layer.cornerRadius = eatUpButton.frame.width/5
        eatUpButton.layer.masksToBounds = true
//        eatUpButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        eatUpButton.invalidateIntrinsicContentSize()
        eatUpButton.isHidden = true
        
        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    // MARK: Collection View Configuration
    // Setup placeholder text for empty collection view
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Don't worry, you'll find someone to EatUp with!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    // Configuring collection view cell views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "availableUserCell", for: indexPath) as! AvailableUserCell
        cell.user = availableUsers[indexPath.item]
        cell.cardView.tag = indexPath.item
        collectionView.allowsMultipleSelection = false
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectUpee(_:)))
        tapped.numberOfTapsRequired = 1
        cell.cardView.addGestureRecognizer(tapped)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableUsers.count
    }
    
    
    // Changing button text after selecting and deselecting user
    func selectUpee(_ sender: UITapGestureRecognizer) {
        let selectedUser = availableUsers[(sender.view?.tag)!]
        let selectedUserIndexPath = IndexPath(item: (sender.view?.tag)!, section: 0)
        let cell = collectionView.cellForItem(at: selectedUserIndexPath) as! AvailableUserCell
        if isUserSelected == true {
            isUserSelected = false
            eatUpButton.isHidden = true
            cell.cardView.backgroundColor = UIColor.white
            cell.nameLabel.textColor = UIColor.black
        }
        else {
            let name = selectedUser.name
            eatUpButton.setTitle("EatUp with \(name!)", for: UIControlState.normal)
            eatUpButton.sizeToFit()
            isUserSelected = true
            eatUpButton.isHidden = false
            cell.cardView.backgroundColor = UIColor(red: 254/255, green: 63/255, blue: 103/255, alpha: 1)
            cell.nameLabel.textColor = UIColor.white
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
