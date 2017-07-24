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
        
        checkResponse()
        
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
    
    func checkResponse() {
        let uid = User.current?.id
        databaseHandle = ref.child("users/\(uid)/status").observe(.value, with: { (snapshot) in
            let data = snapshot.value as! String
            if data == uid {
                print("inviting \(self.selectedUser?.name)")
            }
            else if data != "" {
                self.ref.child("users/\(data)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let userData = snapshot.value as! [String: Any]
                    let inviter = User(dictionary: userData)
                    inviter.id = snapshot.key
                    print("invited by \(inviter.name)")
                    self.performSegue(withIdentifier: "acceptedEatUpSegue", sender: nil)
                })
            }
        })
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
