//
//  OrgSelectViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/13/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class OrgSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var orgView: UITableView!

    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!

    var orgs: [String] = []
    var org_ids: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Firebase Database reference
        ref = Database.database().reference()

        databaseHandle = ref.child("orgs").observe(.value, with: { (snapshot) in

            let data = snapshot.value as? NSDictionary

            for (org, info) in data! {
                let org_id = org as! String
                let orgDictionary = info as! NSDictionary
                let name = orgDictionary["name"] as? String ?? ""
                self.orgs.append(name)
                self.org_ids.append(org_id)
                self.orgView.reloadData()
            }
        })

        orgView.delegate = self
        orgView.dataSource = self



    }

    // MARK: TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orgs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orgView.dequeueReusableCell(withIdentifier: "OrgCell", for: indexPath) as! OrgCell
        let org = orgs[indexPath.row]
        cell.nameLabel.text = org

        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self , action: #selector(setOrg(_:)))
        tapped.numberOfTapsRequired = 1

        cell.addGestureRecognizer(tapped)

        return cell
    }

    @objc func setOrg(_ sender: UITapGestureRecognizer) {
        let parent = sender.view as! OrgCell
        let org_name = parent.nameLabel.text
        APIManager.shared.setOrgId(org_name: org_name!) { (success) in
            if success == true {
                self.performSegue(withIdentifier: "selectedOrgSegue", sender: nil)
            }
            else {
                print("setOrgId() failed")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


