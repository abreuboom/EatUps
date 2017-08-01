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

class FindUpeeViewController: UIViewController {

    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var selectedUser: User?
    var eatupId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets background colour of view
        self.view.backgroundColor = GradientColor(gradientStyle: .topToBottom, frame: self.view.frame, colors: [HexColor(hexString: "FE8F72"), HexColor(hexString: "FE3F67")])
        
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
            self.nameLabel.text = "Find \(User.firstName(name: name))!"
        }
    }
    
    @IBAction func didFinishEatUp(_ sender: Any) {
        performSegue(withIdentifier: "findToRatingSegue", sender: UIButton())
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
        else if segue.identifier == "findToRatingSegue" {
            let RatingViewController = segue.destination as! RatingViewController
            RatingViewController.selectedUser = selectedUser
            RatingViewController.eatupId = eatupId
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
