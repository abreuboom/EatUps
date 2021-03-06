//
//  RatingViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import ChameleonFramework

class RatingViewController: UIViewController {
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var selectedUser: User?
    var eatupId: String?
    
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    //var rating: String
    
    var child = [String]()

    @IBAction func didNotRate(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        databaseHandle = ref?.child("eatups/\(eatupId!)/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/\(self.eatupId!)/users/\(user)").setValue("0")
                    APIManager.shared.resetStatus(userID: uid!)
                    self.performSegue(withIdentifier: "ratingSegue", sender: nil)
                }
            }
        })
        
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        
        databaseHandle = ref?.child("eatups/\(eatupId!)/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/\(self.eatupId!)/users/\(user)").setValue("1")
                    APIManager.shared.resetStatus(userID: uid!)
                    self.performSegue(withIdentifier: "ratingSegue", sender: nil)
                }
            }
        })
    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid        
        databaseHandle = ref?.child("eatups/\(eatupId!)/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/\(self.eatupId!)/users/\(user)").setValue("-1")
                    APIManager.shared.resetStatus(userID: uid!)
                    self.performSegue(withIdentifier: "ratingSegue", sender: nil)
                }
            }
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // Sets view background colour
        self.view.backgroundColor = GradientColor(gradientStyle: .topToBottom, frame: self.view.frame, colors: [HexColor(hexString: "FE8F72"), HexColor(hexString: "FE3F67")])
        
        if let photoURL = selectedUser?.profilePhotoUrl {
            self.profilePhotoView.af_setImage(withURL: photoURL)
            User.getRoundProfilePics(photoView: self.profilePhotoView)
        }
        if let name = selectedUser?.name {
            self.nameLabel.text = User.firstName(name: name)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

}
