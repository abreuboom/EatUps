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
import GoogleMaps
import AlamofireImage

class ShareLocationViewController: UINavigationController, CLLocationManagerDelegate {
    
    var currentUser = User.current
    var selectedUser: User?
    var eatupPlace: String?
    @IBOutlet weak var imageView: UIImageView!
    var markersInfo = [String: Array<Any>]()
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markersSetUp { (success) in
            if success == true {
                
                // Sets up the map view
                let placeLocation = self.markersInfo[self.eatupPlace!]?[0] as? CLLocationCoordinate2D
                let camera = GMSCameraPosition.camera(withLatitude: (placeLocation?.latitude)!, longitude: (placeLocation?.longitude)!, zoom: 15)
                let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
                self.view = mapView
                
                for (name, info) in self.markersInfo {
                    let location = info[0]
                    let pic = info[1]
                    let marker = GMSMarker()
                    marker.position = location as! CLLocationCoordinate2D
                    marker.title = name
                    marker.icon = pic as? UIImage 
                    marker.snippet = "Facebook University"
                    marker.map = mapView
                }
            }
        }

        
    }
    
    // MARK: Loading information for markers
    func markersSetUp(completion: @escaping(Bool) -> ()) {
        // Gets location of the eatUp place
        APIManager.shared.getPlaceLocation(place: eatupPlace!) { (success: Bool, placeLocation: CLLocation) in
            if success == true {
                let placeLocation = placeLocation.coordinate
                let org_id = self.currentUser?.org_id
                self.ref.child("orgs/\(org_id!)/emojis/\(self.eatupPlace!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let placeEmoji = snapshot.value as? String {
                        let placeEmojiPic = UIImage.init(emoji: placeEmoji, size: 30)
                        self.markersInfo[self.eatupPlace!] = [placeLocation, placeEmojiPic!]
                    }
                    if self.markersInfo.count == 3 {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                })
    
            }
        }
        
        // Gets location of the other person
        if let yourLocationString = selectedUser?.dictionary?["location"] {
            let yourLocation = (EatUp.stringToCLLocation(locationString: yourLocationString as! String)).coordinate
            if let yourPicLink = selectedUser?.dictionary?["profilePhotoURL"] {
                imageView.af_setImage(withURL: yourPicLink as! URL)
                let yourPic = imageView.image!
                self.markersInfo[User.firstName(name: (self.selectedUser?.name)!)] = [yourLocation, yourPic]
            }
        }
        
        
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
            let myLocation = (EatUp.stringToCLLocation(locationString: myLocationString)).coordinate
            if let myPicLink = URL(string: currentUser?.dictionary?["profilePhotoURL"] as! String) {
                imageView.af_setImage(withURL: myPicLink)
                let myPic = imageView.image
                self.markersInfo[User.firstName(name: (self.currentUser?.name)!)] = [myLocation, myPic]
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
