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
    var eatupId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        APIManager.shared.checkResponse(selectedUser: selectedUser!, eatupId: eatupId!) { (success) in
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
        
        
        // Configure timer views
        let timerRect = CGRect(x: 200, y: 200, width: 100, height: 100)
        let timer = SRCountdownTimer(frame: timerRect)
        timer.start(beginingValue: 10)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
        APIManager.shared.resetStatus(userID: (User.current?.id)!)
        ref.child("eatups/\(eatupId)").removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    func timerDidEnd() {
        APIManager.shared.checkResponse(selectedUser: selectedUser!, eatupId: eatupId!) { (success) in
            if success == true {
                self.performSegue(withIdentifier: "acceptedEatUpSegue", sender: nil)
            }
            else {
                var didNotRespondAlertController = UIAlertController(title: "User did not respond", message: "Please select another user", preferredStyle: .alert)
                // Configure alert controller
                let backAction = UIAlertAction(title: "Go Back", style: .cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                    APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
                }
                didNotRespondAlertController.addAction(backAction)
                self.present(didNotRespondAlertController, animated: true)
            }
        }
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
