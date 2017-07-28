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
import EasyAnimation

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eatUpButton: UIButton!
    
    @IBOutlet var inviteView: InviteView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    var effect: UIVisualEffect!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    @IBOutlet weak var eatupAtParent: UIView!
    @IBOutlet var eatupAtView: EatupAtView!
    
    var users: [String] = []
    var availableUsers: [User] = []
    var selectedUser: User?
    var eatupId: String?
    var place: String = ""
    var locationManager: CLLocationManager!
    
    var isUserSelected: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        eatupAtView.layer.cornerRadius = eatupAtView.frame.width/5
        eatupAtView.dropShadow()
        eatupAtView.center = eatupAtParent.center
        
        eatupAtView.place = place
        let size = eatupAtView.eatupAtLabel.sizeThatFits(self.view.bounds.size)
        eatupAtView.eatupAtLabel.frame.size = size
        eatupAtView.frame = CGRect.init(x: eatupAtParent.center.x - (eatupAtView.eatupAtLabel.bounds.size.width + 32)/2, y: eatupAtParent.center.y - eatupAtView.bounds.size.height/2, width: eatupAtView.eatupAtLabel.bounds.size.width + 32, height: eatupAtView.bounds.size.height)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        eatupAtView.reset()
        eatupAtView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eatupAtParent.addSubview(eatupAtView)
        
        effect = blurEffect.effect!
        blurEffect.effect = nil
        inviteView.layer.cornerRadius = 25
        inviteView.dropShadow()
        inviteView.layer.position = blurEffect.contentView.center
        inviteView.center = CGPoint(x: blurEffect.contentView.frame.size.width/2, y: blurEffect.contentView.frame.size.height/2)
        
        
        self.navigationController?.hidesNavigationBarHairline = true
        
        ref = Database.database().reference()
        
        let uid = User.current?.id ?? ""
        
        // Populating collection view with available users
        APIManager.shared.getAvailableUsers(place: place) { (success, users) in
            if success == true {
                for user in users {
                    // Does not add self and other users into user feed view
                    if (user.id == uid || self.availableUsers.contains(where: { (storedUser) -> Bool in
                        return storedUser.id == user.id || storedUser.name == user.name
                    })) != true {
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
        eatUpButton.layer.position.y = self.view.frame.maxY + 50
        
        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    func animateInviteIn(eatup: EatUp) {
        self.view.bringSubview(toFront: blurEffect)
        inviteView.eatup = eatup
        inviteView.parent = self
        inviteView.frame = CGRect.init(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.frame.width, height: self.view.frame.height)
        inviteView.populateInviteInfo()
        inviteView.center = self.view.center
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
        
        //        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectUpee(_:)))
        //        tapped.numberOfTapsRequired = 1
        //        cell.cardView.addGestureRecognizer(tapped)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedUser = availableUsers[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        
        if cell.isSelected == true {
            if isUserSelected == false {
                isUserSelected = true
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.eatUpButton.layer.position.y = 515
                    cell.cardView.backgroundColor = UIColor(red: 254/255, green: 63/255, blue: 103/255, alpha: 1)
                    cell.nameLabel.textColor = UIColor.white
                }, completion: { (success) in
                    if success == true {
                        self.isUserSelected = true
                        self.eatUpButton.tag = cell.cardView.tag
                        
                    }
                })
            }
            else {
                isUserSelected = false
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.eatUpButton.layer.position.y = self.view.frame.maxY + 50
                    cell.cardView.backgroundColor = UIColor.white
                    cell.nameLabel.textColor = UIColor.black
                }, completion: nil)
            }
        }
        else {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
                self.eatUpButton.layer.position.y = 500
            }, completion: { (success) in
                if success == true {
                    print("woop")
                    self.isUserSelected = true
                    self.eatUpButton.tag = (cell.tag)
                    cell.cardView.backgroundColor = UIColor(red: 254/255, green: 63/255, blue: 103/255, alpha: 1)
                    cell.nameLabel.textColor = UIColor.white
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        isUserSelected = false
        cell.cardView.backgroundColor = UIColor.white
        cell.nameLabel.textColor = UIColor.black
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
        else if segue.identifier == "feedToFindSegue" {
            let findUpeeViewController = segue.destination as! FindUpeeViewController
            findUpeeViewController.eatupId = self.inviteView.eatup?.id
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
