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
import Firebase

class OrgSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var orgView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    var locationManager: CLLocationManager!
    
    var orgs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Firebase Database reference
        ref = Database.database().reference()
        
        databaseHandle = ref.child("orgs").observe(.value, with: { (snapshot) in

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
        
        // Request permissions for locations
        locationManager = CLLocationManager()
        getLocation()

        // Do any additional setup after loading the view.
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
        print("Current location: \(currentLocation)")
        
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
    
    
    // MARK: Collection view methods
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
