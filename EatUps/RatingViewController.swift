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
    //var databaseHandle: DatabaseHandle?
    
   // var rating: [String]

    @IBAction func didNotRate(_ sender: UIButton) {
        //        self.ref.child("users/(user.uid)/username").setValue(username)

       ref?.child("eatups").child("eatup_id").child("user_id").setValue("0")
        
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        ref?.child("eatups").child("eatup_id").child("user_id").setValue("1")

        
    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        ref?.child("eatups").child("eatup_id").child("user_id").setValue("-1")

        
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
