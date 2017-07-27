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
import ChameleonFramework

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eatUpButton: UIButton!
    
    @IBOutlet var inviteView: InviteView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    var effect: UIVisualEffect!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var users: [String] = []
    var availableUsers: [User] = []
    var selectedUser: User?
    var eatupId: String?
    var place: String = ""
    var locationManager: CLLocationManager!
    
    var isUserSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = blurEffect.effect!
        blurEffect.effect = nil
        inviteView.layer.cornerRadius = 25
        inviteView.dropShadow()
        
        self.navigationController?.hidesNavigationBarHairline = true
        
        ref = Database.database().reference()
        
        let uid = User.current?.id ?? ""
        
        // Populating collection view with available users
        APIManager.shared.getAvailableUsers(place: place) { (success, users) in
            if success == true {
                for user in users {
                    if self.availableUsers.contains(where: { (storedUser) -> Bool in
                        return storedUser.id == user.id || storedUser.name == user.name
                    }) {
                        print(user.name)
                        print("duplicate user")
                    }
                    else {
                        self.availableUsers.append(user)
                    }
                }
                self.collectionView.reloadData()
            }
        }
        
        APIManager.shared.checkForInvite { (invited, eatupId) in
            if invited == true {
                if eatupId != nil {
                    self.ref.child("eatups/\(eatupId)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let eatupDictionary = snapshot.value as? [String: Any] {
                            let eatup = EatUp(dictionary: eatupDictionary)
                            eatup.id = snapshot.key
                            
                            self.animateInviteIn(eatup: eatup)
                        }
                    })
                }
            }
        }
        
        // Styling eatUp button
        eatUpButton.layer.cornerRadius = eatUpButton.frame.width/5
        eatUpButton.layer.masksToBounds = true
        eatUpButton.isHidden = true
        
        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    func animateInviteIn(eatup: EatUp) {
        self.view.bringSubview(toFront: blurEffect)
        inviteView.eatup = eatup
        inviteView.populateInviteInfo()
        inviteView.layer.position = self.view.center
        inviteView.center = CGPoint(x: blurEffect.contentView.frame.size.width/2, y: blurEffect.contentView.frame.size.height/2)
        self.view.addSubview(inviteView)
        
        inviteView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        inviteView.alpha = 0
        
        UIView.animate(withDuration: 0.4) { 
            self.blurEffect.effect = self.effect
            self.inviteView.alpha = 1
            self.inviteView.transform = CGAffineTransform.identity
        }
    }
    
    func animateInviteOut() {
        UIView.animate(withDuration: 0.2, animations: { 
            self.inviteView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.inviteView.alpha = 0
            self.blurEffect.effect = nil
        }) { (success) in
            self.view.sendSubview(toBack: self.blurEffect)
            self.inviteView.removeFromSuperview()
        }
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
        selectedUser = availableUsers[(sender.view?.tag)!]
        let selectedUserIndexPath = IndexPath(item: (sender.view?.tag)!, section: 0)
        let cell = collectionView.cellForItem(at: selectedUserIndexPath) as! AvailableUserCell
        if isUserSelected == true {
            isUserSelected = false
            eatUpButton.isHidden = true
            cell.cardView.backgroundColor = UIColor.white
            cell.nameLabel.textColor = UIColor.black
        }
        else {
            let name = selectedUser?.name
            eatUpButton.setTitle("EatUp with \(name!)", for: UIControlState.normal)
            eatUpButton.sizeToFit()
            isUserSelected = true
            eatUpButton.isHidden = false
            eatUpButton.tag = (sender.view?.tag)!
            cell.cardView.backgroundColor = UIColor(red: 254/255, green: 63/255, blue: 103/255, alpha: 1)
            cell.nameLabel.textColor = UIColor.white
        }
    }
    
    @IBAction func requestEatUp(_ sender: UIButton) {
        let id = selectedUser?.id
        APIManager.shared.requestEatUp(toUserID: id!, place: place) { (success, eatup) in
            if success == true {
                self.eatupId = eatup
                self.performSegue(withIdentifier: "requestEatUpSegue", sender: sender)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestEatUpSegue" {
            let selectedUserButton = sender as! UIButton
            let selectedUser = availableUsers[selectedUserButton.tag]
            let pendingInviteViewController = segue.destination as! PendingInviteViewController
            pendingInviteViewController.selectedUser = selectedUser
            pendingInviteViewController.eatupId = eatupId
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
