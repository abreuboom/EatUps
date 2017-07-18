//
//  OrgSelectViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/13/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import BouncyLayout
import FirebaseDatabase

class OrgSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var orgView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var orgs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Firebase Database reference
        ref = Database.database().reference()
        
        databaseHandle = ref.child("org").observe(.value, with: { (snapshot) in

            let data = snapshot.value as? NSDictionary
            
            for (org, info) in data! {
                let orgDictionary = info as! NSDictionary
                let name = orgDictionary["name"] as? String ?? ""
                self.orgs.append(name)
                self.orgView.reloadData()
            }
            let name = data?.value(forKey: "name")
        })
        
        let layout = BouncyLayout()
        
        flowLayout = layout
        
        
        orgView.delegate = self
        orgView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = orgView.dequeueReusableCell(withReuseIdentifier: "OrgCell", for: indexPath) as! OrgCell
        cell.nameLabel.text = orgs[indexPath.row]
        
        return cell
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
