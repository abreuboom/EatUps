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
import ChameleonFramework


class PendingInviteViewController: UIViewController, SRCountdownTimerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timer: SRCountdownTimer!

    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!

    var selectedUser: User?

    var eatup: EatUp?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        self.view.backgroundColor = GradientColor(gradientStyle: .topToBottom, frame: self.view.frame, colors: [HexColor(hexString: "FE8F72"), HexColor(hexString: "FE3F67")])
        
        APIManager.shared.checkResponse(selectedUser: selectedUser!, eatupId: (eatup?.id)!) { (success) in
            if success == true {
                self.performSegue(withIdentifier: "pendingToChatSegue", sender: nil)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }

        // Configure send invite user views
        if let name = selectedUser?.name {
            self.nameLabel.text = User.firstName(name: name)
        }
        if let url = selectedUser?.profilePhotoUrl {
            profileImage.af_setImage(withURL: url)
        }
        User.getRoundProfilePics(photoView: profileImage)

        // Configure alert controller
        let backAction = UIAlertAction(title: "Go Back", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
            APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
            
        }
        
        // Timer setup
        timer.backgroundColor = UIColor(white: 0, alpha: 0)
        timer.isOpaque = false
        timer.lineColor = .white
        timer.lineWidth = 4.0
        timer.trailLineColor = .clear
        timer.labelTextColor = .white
        timer.labelFont = UIFont.boldSystemFont(ofSize: 25)
        timer.start(beginingValue: 60)
        timer.delegate = self
        
    }



    @IBAction func didTapCancel(_ sender: Any) {
        APIManager.shared.resetStatus(userID: (self.selectedUser?.id)!)
        APIManager.shared.resetStatus(userID: (User.current?.id)!)
        let id = eatup?.id
        ref.child("eatups/\(id!)").removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func timerDidEnd() {
        self.didTapCancel(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pendingToChatSegue" {
            let navigationViewController = segue.destination as! UINavigationController
            let chatViewController = navigationViewController.viewControllers.first as! ChatViewController
            chatViewController.selectedUser = selectedUser
            chatViewController.eatup = eatup
            timer.dismiss()
        }
    }

}
