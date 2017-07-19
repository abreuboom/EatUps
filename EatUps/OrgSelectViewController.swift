//
//  OrgSelectViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/13/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import Firebase

class OrgSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var orgView: UITableView!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var locationManager: CLLocationManager!
    
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
        
        // Request permissions for locations
        locationManager = CLLocationManager()
        getLocation()

    }
    
    // MARK: Location manager methods
    // Gets location of user
    func getLocation() {
        let status  = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // Location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Gets current location
        let currentLocation = locations.last!
        // print("Current location: \(currentLocation)")
        
        // Converts into string
        let latitude: String = String(format: "%f", currentLocation.coordinate.latitude)
        let longitude: String = String(format:"%f", currentLocation.coordinate.longitude)
        let currentLocationString = "(\(latitude), \(longitude))"
        let user = Auth.auth().currentUser
        
        // MARK: TODO: Set location in current user
        if let user = user {
            let id = user.uid
            self.ref.child("users/\(id)/location").setValue(currentLocationString)
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
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
        let org_id = parent.nameLabel.text
        APIManager.shared.setOrgId(org_id: org_id!)
        self.performSegue(withIdentifier: "selectedOrgSegue", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
