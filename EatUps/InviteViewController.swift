//
//  InviteViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/26/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UIButton!
    
    var eatup: EatUp?
    
    override func viewWillAppear(_ animated: Bool) {
        let inviter = eatup?.inviter
        APIManager.shared.getUser(uid: inviter!) { (success, inviter) in
            if success == true {
                if let photoURL = inviter.profilePhotoUrl {
                    self.profilePhotoView.af_setImage(withURL: photoURL)
                }
                if let name = inviter.name {
                    self.nameLabel.text = User.firstName(name: name)
                }
            }
        }
        placeLabel.setTitle(eatup?.place, for: .normal)
        placeLabel.sizeToFit()
        
        cardView.layer.cornerRadius = 25
        cardView.dropShadow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init as above and then...
        // Get superview's CGSize
        let size = super.view.frame.size;
        self.view.center = CGPoint.init(x: size.width/2, y: size.height/2)
        
        User.getRoundProfilePics(photoView: profilePhotoView)

        // Do any additional setup after loading the view.
    }

    @IBAction func acceptEatUp(_ sender: UIButton) {
        let eatupId = eatup?.id ?? ""
        APIManager.shared.handleInvite(eatupId: eatupId, response: true, completion: { (success) in
            if success == true {
                self.parent?.performSegue(withIdentifier: "pendingToFindSegue", sender: nil)
            }
        })
    }
    
    @IBAction func rejectEatUp(_ sender: UIButton) {
        let eatupId = eatup?.id ?? ""
        APIManager.shared.handleInvite(eatupId: eatupId, response: false, completion: { (success) in
            if success == true {
                self.view.removeFromSuperview()
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
