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

    @IBAction func didNotRate(_ sender: UIButton) {
        ref?.child("eatups").child("eatup_id").child("user_id")
        
    }
    
    
    @IBAction func wouldEatUpAgain(_ sender: Any) {
        
        
    }
    
    
    @IBAction func wouldNotEatUpAgain(_ sender: Any) {
        
        
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
