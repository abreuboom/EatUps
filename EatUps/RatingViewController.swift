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
            
            for (user, rating) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                
                if uid != user {
                    self.ref?.child("eatups/eatup_id/users").child("user_id").setValue("0")
                } else{
                    // if user is equal to the current id, then print the user's value
                    print(rating)
                }
            }
            
        })

        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        ref?.child("eatups/eatup_id/users/\(uid!)").setValue("0")
        
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, rating) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                
                if uid != user {
                    self.ref?.child("eatups/eatup_id/users").child("user_id").setValue("1")
                } else{
                    // if user is equal to the current id, then print the user's value
                    print(rating)
                }
            }
            
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        ref?.child("eatups/eatup_id/users/\(uid!)").setValue("0")
        
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            let child = snapshot.value as? [String: Any]
            
            for (user, rating) in child! {
                
                // set user to be the key of the current user
                //if user is not equal to the current id, then set the value of the rating
                
                if uid != user {
                    self.ref?.child("eatups/eatup_id/users").child("user_id").setValue("-1")
                } else{
                    // if user is equal to the current id, then print the user's value
                    print(rating)
                }
            }
            
        })
        self.dismiss(animated: true, completion: nil)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
