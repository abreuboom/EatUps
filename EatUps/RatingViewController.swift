//
//  RatingViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RatingViewController: UIViewController {
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
    //var rating: String
    
    var child = [String]()

    @IBAction func didNotRate(_ sender: UIButton) {
        //        self.ref.child("users/(user.uid)/username").setValue(username)
        databaseHandle = ref?.child("eatups/eatup_id/users").observe(.value, with: { (snapshot) in
            
            self.child.append("1")
            
            for (user, rating) in child {
            
            // set user to be the key of the current user
            
            let user = User.current?.id
            
            //if user is not equal to the current id, then set the value of the rating
            
            if User.current?.id != user{
            // if user is equal to the current id, then print the user's value
                    self.ref?.child("eatups/eatup_id/users").child("user_id").setValue("1")
            }else{
                print(child)
            }
        }

            
        })
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        ref?.child("eatups").child("eatup_id").child("user_id").setValue("1")
        self.dismiss(animated: true, completion: nil)

        
    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        ref?.child("eatups").child("eatup_id").child("user_id").setValue("-1")
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
