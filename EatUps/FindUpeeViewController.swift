//
//  FindUpeeViewController.swift
//  EatUps
//
//  Created by Maxine Kwan on 7/25/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

protocol FindUpeeViewControllerDelegate: class {
    func didActionBubble(content: String?)
}

class FindUpeeViewController: UIViewController {
    
    weak var delegate: FindUpeeViewControllerDelegate?
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var onWhereStand: UIButton!
    @IBOutlet weak var onWhatSee: UIButton!
    
    var selectedUser: User?
    
    var eatup: EatUp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets background colour of view
        self.view.backgroundColor = GradientColor(gradientStyle: .topToBottom, frame: self.view.frame, colors: [HexColor(hexString: "FE8F72"), HexColor(hexString: "FE3F67")])
        
        
        if selectedUser == nil {
            Database.database().reference().child("eatups").child((eatup?.id!)!).child("inviter").observe(.value, with: { (snapshot) in
                let inviter = snapshot.value as! String
                APIManager.shared.getUser(uid: inviter) { (success, inviter) in
                    if success == true {
                        self.selectedUser = inviter
                        self.customizeView()
                    }
                }
            })
        }
        else {
            customizeView()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func customizeView() {
        if let photoURL = selectedUser?.profilePhotoUrl {
            self.profilePhotoView.af_setImage(withURL: photoURL)
            User.getRoundProfilePics(photoView: self.profilePhotoView)
        }
        if let name = selectedUser?.name {
            self.nameLabel.text = "Find \(User.firstName(name: name))!"
        }
    }
    
    @IBAction func didFinishEatUp(_ sender: Any) {
        performSegue(withIdentifier: "findToRatingSegue", sender: UIButton())
        // Deletes the EatUp conversation
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("eatups").child((eatup?.id!)!).observe(.value, with: { (snapshot) in
                if snapshot.hasChild("conversation") {
                    let eatupInfo = snapshot.value as! NSDictionary
                    let conversationKey = eatupInfo["conversation"] as! String
                    let ref = Database.database().reference().child("conversations")
                    ref.child(conversationKey).removeValue()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onWhereStand(_ sender: UIButton) {
        self.performSegue(withIdentifier: "findToChatSegue", sender: UIButton())
    }
    
    @IBAction func onWhatSee(_ sender: Any) {
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findToChatSegue" {
            let ChatViewController = segue.destination as! ChatViewController
            ChatViewController.selectedUser = selectedUser
            ChatViewController.eatup = eatup
            if onWhereStand.isTouchInside == true {
                self.delegate = ChatViewController
                self.delegate?.didActionBubble(content: "Where are you standing?")
            }
        }
        else if segue.identifier == "findToLocationSegue" {
            let ShareLocationViewController = segue.destination as! ShareLocationViewController
            ShareLocationViewController.selectedUser = selectedUser
            ShareLocationViewController.eatupPlace = eatup?.place
            
        }
        else if segue.identifier == "findToRatingSegue" {
            let RatingViewController = segue.destination as! RatingViewController
            RatingViewController.selectedUser = selectedUser
            RatingViewController.eatupId = eatup?.id
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
