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

    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var selectedUser: User?
    var eatupId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didFinishEatUp(_ sender: Any) {
        // Deletes the EatUp conversation
//        if let currentUserID = Auth.auth().currentUser?.uid {
//            Database.database().reference().child("eatups").child(eatupId).observe(.value, with: { (snapshot) in
//                if snapshot.hasChild("conversation") {
//                    let data = snapshot.value as! [String: Any]
//                    let location = data["conversation"] as! String
//                    Database.database().reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
//                        if error == nil {
//                            completion(true)
//                        } else {
//                            completion(false)
//                        }
//                    })
//                } else {
//                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
//                        let data = ["conversation": reference.parent!.key]
//                        Database.database().reference().child("eatups").child(eatUpID).updateChildValues(data)
//                        completion(true)
//                    })
//                }
//            })
//        }
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
