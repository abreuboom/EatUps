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
import CoreLocation

class OrgSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var orgView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var locationManager: CLLocationManager!
    
    var orgs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request permissions for locations
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Set Firebase Database reference
        var ref = Database.database().reference()
        
        var databaseHandle = ref.child("orgs").observe(.childAdded, with: { (snapshot) in
            
            let data = snapshot.value as? [String: Any]
            
            print(data)
            
            if let orgName = data?["name"] as? String {
                
                self.orgs.append(orgName)
                self.orgView.reloadData()
            }
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
