//
//  SendInviteViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import AlamofireImage
import FirebaseDatabase
import SRCountdownTimer

class PendingInviteViewController: UIViewController, SRCountdownTimerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timer: SRCountdownTimer!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var selectedUser: User?
    
    var didNotRespondAlertController = UIAlertController(title: "User did not respond", message: "Please select another user", preferredStyle: .alert)

    
    
    @IBAction func didTapCancel(_ sender: Any) {

        APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
        APIManager.shared.resetStatus(userID: (User.current?.id)!)
        self.dismiss(animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        APIManager.shared.checkResponse(selectedUser: selectedUser!) { (success) in
            if success == true {
                self.performSegue(withIdentifier: "acceptedEatUpSegue", sender: nil)
            }
        }
        
        // Configure send invite user views
        nameLabel.text = selectedUser?.name
        if let url = selectedUser?.profilePhotoUrl {
            profileImage.af_setImage(withURL: url)
        }
        User.getRoundProfilePics(photoView: profileImage)
        
        // Configure alert controller
        let backAction = UIAlertAction(title: "Go Back", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
            APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
        }
        didNotRespondAlertController.addAction(backAction)
    }
        
        // Chat stuff
        
        // notification setup
        
    func timerDidEnd() {
        APIManager.shared.checkResponse(selectedUser: selectedUser!) { (success) in
            if success == true {
                self.performSegue(withIdentifier: "acceptedEatUpSegue", sender: nil)
            }
            else {
                    APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
                }
                self.present(self.didNotRespondAlertController, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pendingToFindSegue" {
            let FindUpeeViewController = segue.destination as! FindUpeeViewController
            FindUpeeViewController.selectedUser = selectedUser
        }
    }

}
