//
//  UserFeedViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import BouncyLayout
import FirebaseDatabase

class UserFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var availableUsers: [User] = []
    var selectedUser = User()
    var eatUp = EatUp()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eatUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load available users into table view
        var ref = Database.database().reference()
        // place = eatUp.place.location
        
        // scan everyone in org for location information close enough to that place
//         var databaseHandle = ref.child(orgs).observe(.childAdded, with: { (snapshot) in
//            let data = snapshot.value as? [String: Any]
//            
//            print(data)
//            
//            if let orgName = data?["name"] as? String {
//                
//                self.orgs.append(orgName)
//                self.orgView.reloadData()
//            }
//        })
        
        let layout = BouncyLayout()
        
//        flowLayout = layout
        
        // Initialise collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    // Configuring collection view cell views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "availableUserCell", for: indexPath) as! AvailableUserCell
         cell.user = availableUsers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return availableUsers.count - 1
        return 4
    }
    
    // Changes views and stores selected user
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AvailableUserCell
        if(cell.isSelected) {
            cell.backgroundColor = UIColor.red
            selectedUser = cell.user
            eatUpButton.isHidden = false
        }
        else {
            cell.backgroundColor = UIColor.white
            eatUpButton.isHidden = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
