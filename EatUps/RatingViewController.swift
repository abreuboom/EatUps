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

class RatingViewController: UIViewController {
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
    //var rating: String
    
    var child = [String]()

    @IBAction func didNotRate(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        ref?.child("eatups/eatup_id/users/\(uid!)").setValue("0")
        
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/eatup_id/users/user_id").setValue("0")
                    self.performSegue(withIdentifier: "ratingSegue", sender: nil)

                }
            }
            
        })
        
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        ref?.child("eatups/eatup_id/users/\(uid!)").setValue("0")
        
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/eatup_id/users/user_id").setValue("1")
                }
            }
            
        })
         //   self.performSegue(withIdentifier: "loginSegue", sender: nil)

    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        ref?.child("eatups/eatup_id/users/\(uid!)").setValue("0")
        
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, _) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                if user != uid!{
                    // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/eatup_id/users/user_id").setValue("-1")
                }
            }
            
        })
        
        //self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

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
