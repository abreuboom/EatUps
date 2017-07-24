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

class PendingInviteViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
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
        
        // Do any additional setup after loading the view.
    }
    
    func timerDidEnd() {
        self.present(self.didNotRespondAlertController, animated: true)
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
