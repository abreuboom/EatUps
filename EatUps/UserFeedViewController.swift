//
//  UserFeedViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseDatabase
import CoreLocation
import DZNEmptyDataSet
import Firebase
import ChameleonFramework
import EasyAnimation
import UserNotifications

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UNUserNotificationCenterDelegate, UIViewControllerPreviewingDelegate {
    
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
    var inviter: Bool = false
    var currentEatup: EatUp?
    
    var isUserSelected: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "MADE Waffle Soft", size: 18)!]
        
        eatupAtView.layer.cornerRadius = eatupAtView.frame.width/5
        eatupAtView.dropShadow()
        eatupAtView.center = eatupAtParent.center
        
        eatupAtView.place = place
        let size = eatupAtView.eatupAtLabel.sizeThatFits(self.view.bounds.size)
        eatupAtView.eatupAtLabel.frame.size = size
        eatupAtView.frame = CGRect.init(x: eatupAtParent.center.x - (eatupAtView.eatupAtLabel.bounds.size.width + 32)/2, y: eatupAtParent.center.y - eatupAtView.bounds.size.height/2, width: eatupAtView.eatupAtLabel.bounds.size.width + 32, height: eatupAtView.bounds.size.height)
        
        addProfileButton()
    }
    
    func addProfileButton() {
        Alamofire.request((User.current?.profilePhotoUrl)!).responseImage(imageScale: 0.5, inflateResponseImage: false) { (response) in
            if let profilePhoto = response.value {
                let roundedPhoto = profilePhoto.af_imageRoundedIntoCircle()
                let profileButton = UIButton(type: .system)
                profileButton.addTarget(self, action: #selector(self.toProfile), for: .touchUpInside)
                profileButton.setImage(roundedPhoto.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: .normal)
                profileButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                let widthConstraint = profileButton.widthAnchor.constraint(equalToConstant: 32)
                let heightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 32)
                heightConstraint.isActive = true
                widthConstraint.isActive = true
                let barButtonItem = UIBarButtonItem(customView: profileButton)
                self.navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
            }
        }
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
                            let inviterId = eatup.inviter
                            APIManager.shared.getUser(uid: inviterId, completion: { (success, inviter) in
                                if success == true {
                                    let acceptEatup = UNNotificationAction(identifier: "accept", title: "Accept EatUp!", options: UNNotificationActionOptions.foreground)
                                    let declineEatup = UNNotificationAction(identifier: "decline", title: "Decline", options: UNNotificationActionOptions.foreground)
                                    
                                    let category = UNNotificationCategory(identifier: "eatupNotification", actions: [acceptEatup, declineEatup], intentIdentifiers: [], options: [])
                                    UNUserNotificationCenter.current().setNotificationCategories([category])
                                    
                                    let content = UNMutableNotificationContent()
                                    content.title = "\(inviter.name!) wants to eatup with you!"
                                    content.subtitle = "Join them @\(eatup.place)"
                                    content.body = "Eatup with \(inviter.name!) @\(eatup.place) now"
                                    content.badge = 1
                                    
                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                    let request = UNNotificationRequest(identifier: "eatupInvite", content: content, trigger: trigger)
                                    
                                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                }
                            })
                            
                            self.currentEatup = eatup
                            self.animateInviteIn(eatup: eatup)
                        }
                    })
                }
            }
        }
        
        if( traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: collectionView)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "accept" || response.actionIdentifier == "eatupNotification" {
            self.inviteView.acceptEatup(self)
        }
        else if response.actionIdentifier == "decline" {
            self.inviteView.rejectEatup(self)
        }
        completionHandler()
    }
    
    func peek() {
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = collectionView.indexPathForItem(at: location)
        let cell = collectionView.cellForItem(at: indexPath!) as? AvailableUserCell
        
        guard let peekVC = storyboard?.instantiateViewController(withIdentifier: "peekViewController") as? PeekViewController else { return nil }
        if peekVC != nil {
            peekVC.nameLabel.text = cell?.user.name
            peekVC.aboutLabel.text = cell?.user.about ?? ""
            peekVC.favPlaceLabel.text = "😍 \(cell?.user.favoritePlace ?? "")"
            peekVC.user = cell?.user
            
            if let image = cell?.photoView.image {
                peekVC.photoView.image = image
            }
            else {
                peekVC.photoView.image = #imageLiteral(resourceName: "gray_circle")
            }
            
            
            previewingContext.sourceRect = (cell?.frame)!
            
            return peekVC
        }
        else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //
    }
    
    func animateInviteIn(eatup: EatUp) {
        if inviter == false {
            self.view.bringSubview(toFront: blurEffect)
            self.view.bringSubview(toFront: inviteView)
            inviteView.eatup = eatup
            inviteView.populateInviteInfo()
            inviteView.parent = self
            
            inviteView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            inviteView.alpha = 0
            
            UIView.animate(withDuration: 0.4) {
                self.blurEffect.effect = self.effect
                self.inviteView.alpha = 1
                self.inviteView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func animateInviteOut() {
        if inviter == false {
            UIView.animate(withDuration: 0.2, animations: {
                self.inviteView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.inviteView.alpha = 0
                self.blurEffect.effect = nil
            }) { (success) in
                self.view.sendSubview(toBack: self.blurEffect)
                self.view.sendSubview(toBack: self.inviteView)
            }
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
        inviter = true
        let id = selectedUser?.id
        APIManager.shared.requestEatUp(toUserID: id!, place: place) { (success, eatup) in
            if success == true {
                self.eatupId = eatup
                self.performSegue(withIdentifier: "requestEatUpSegue", sender: sender)
            }
        }
    }
    
    func toProfile() {
        self.performSegue(withIdentifier: "profileSegue", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestEatUpSegue" {
            let selectedUserButton = sender as! UIButton
            let selectedUser = availableUsers[selectedUserButton.tag]
            let pendingInviteViewController = segue.destination as! PendingInviteViewController
            pendingInviteViewController.selectedUser = selectedUser
            pendingInviteViewController.eatup = currentEatup
        }
        else if segue.identifier == "feedToChatSegue" {
            let navigationViewController = segue.destination as! UINavigationController
            let chatViewController = navigationViewController.viewControllers.first as! ChatViewController
            chatViewController.selectedUser = self.selectedUser
            chatViewController.eatup = currentEatup
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
