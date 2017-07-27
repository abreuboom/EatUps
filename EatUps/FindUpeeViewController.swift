//
//  FindUpeeViewController.swift
//  EatUps
//
//  Created by Maxine Kwan on 7/25/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Firebase

class FindUpeeViewController: UIViewController {

    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var selectedUser: User?
    var eatupId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedUser == nil {
            Database.database().reference().child("eatups").child(eatupId!).child("inviter").observe(.value, with: { (snapshot) in
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
            self.nameLabel.text = User.firstName(name: name)
        }
    }
    
    @IBAction func didFinishEatUp(_ sender: Any) {
        // Deletes the EatUp conversation
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("eatups").child(eatupId!).observe(.value, with: { (snapshot) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findToChatSegue" {
            let ChatViewController = segue.destination as! ChatViewController
            ChatViewController.selectedUser = selectedUser
            ChatViewController.eatupId = eatupId
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
