//
//  PeekViewController.swift
//  EatUps
//
//  Created by John Abreu on 8/8/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class PeekViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var favPlaceLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
    var user: User? {
        didSet {
            APIManager.shared.getMutualFriends(id: (user?.facebook_id)!) { (success, mutualFriends) in
                self.mutualFriendsLabel.text = "👥 \(mutualFriends.count) Mutual Friends"
            }
        }
    }
    
    override func awakeFromNib() {
        photoView.image = #imageLiteral(resourceName: "gray_circle")
        nameLabel.text = ""
        aboutLabel.text = ""
        favPlaceLabel.text = ""
        mutualFriendsLabel.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoView.image = #imageLiteral(resourceName: "gray_circle")
        nameLabel.text = ""
        aboutLabel.text = ""
        favPlaceLabel.text = ""
        mutualFriendsLabel.text = ""

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
