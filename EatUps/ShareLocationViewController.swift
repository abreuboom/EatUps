//
//  ShareLocationViewController.swift
//  EatUps
//
//  Created by Maxine Kwan on 8/2/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class ShareLocationViewController: UINavigationController, CLLocationManagerDelegate {
    
    var currentUser = User.current
    var selectedUser: User?
    var eatupPlace: String?
    var placeLocation = CLLocation()
    var yourLocation = CLLocation()
    var myLocation = CLLocation()
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets location of the eatUp place
        APIManager.shared.getPlaceLocation(place: eatupPlace!) { (success: Bool, placeLocation: CLLocation) in
            if success == true {
                self.placeLocation = placeLocation
            }
        }
        
        // Gets location of the other person
        ref.child("users/\(selectedUser?.id)/location").observeSingleEvent(of: .value, with: { (snapshot) in
            if let yourLocationString = snapshot.value as? String {
                self.yourLocation = EatUp.stringToCLLocation(locationString: yourLocationString)
            }
        })
        
        // Gets own location
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
        let currentLocation = locations.last!
        let myLocationString = EatUp.CLLocationtoString(currentLocation: currentLocation)
        let user = Auth.auth().currentUser
        // Stores location property in current user
        if let user = user {
            let id = user.uid
            self.ref.child("users/\(id)/location").setValue(myLocationString)
            myLocation = EatUp.stringToCLLocation(locationString: myLocationString)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
