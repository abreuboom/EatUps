//
//  SelectLocationViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ChameleonFramework
import CoreLocation
import FirebaseDatabase
import Firebase
import PKHUD

class SelectLocationViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var org_id = User.current?.org_id
    
    @IBOutlet var eatupAtView: EatupAtView!
    @IBOutlet weak var eatupAtParent: UIView!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ref = Database.database().reference()
    var databaseHandle: DatabaseHandle!
    
    var locationManager: CLLocationManager!

    var places: [String] = []
    var emojis: [String] = []
    var userCountIndex: [Int] = []
    
       //create an array to update as we filter through the locations to eat
    var filteredPlaces: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        getPlaces()
        
        eatupAtView.reset()
        eatupAtView.layer.cornerRadius = eatupAtView.frame.width/5
        eatupAtView.dropShadow()
        eatupAtView.center = eatupAtParent.center
        eatupAtParent.addSubview(eatupAtView)
        let size = eatupAtView.eatupAtLabel.sizeThatFits(self.view.bounds.size)
        eatupAtView.eatupAtLabel.frame.size = size
        eatupAtView.frame = CGRect.init(x: eatupAtParent.center.x - (eatupAtView.eatupAtLabel.bounds.size.width + 32)/2, y: eatupAtParent.center.y - eatupAtView.bounds.size.height/2, width: eatupAtView.eatupAtLabel.bounds.size.width + 32, height: eatupAtView.bounds.size.height)
        
        self.navigationController?.hidesNavigationBarHairline = true
   
        locationsTableView.dataSource = self
        searchBar.delegate = self
        
        // Request permissions for locations
        locationManager = CLLocationManager()
        getLocation()
        HUD.flash(.labeledProgress(title: "", subtitle: ""), delay: 0.0)

    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.locationsTableView.setContentOffset(CGPoint.init(x: 0, y: searchBar.frame.size.height) , animated: true)
        if org_id != "" {
            getPlaces()
        }

        addProfileButton()
    }
    
    func addProfileButton() {
        Alamofire.request((User.current?.profilePhotoUrl)!).responseImage(imageScale: 0.5, inflateResponseImage: false) { (response) in
            if let profilePhoto = response.value {
                let roundedPhoto = profilePhoto.af_imageRoundedIntoCircle()
                let profileButton = UIButton(type: .system)
                profileButton.addTarget(self, action: #selector(self.toProfile), for: .touchUpInside)
                profileButton.setImage(roundedPhoto.withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: .normal)
                profileButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                let barButtonItem = UIBarButtonItem(customView: profileButton)
                let widthConstraint = profileButton.widthAnchor.constraint(equalToConstant: 32)
                let heightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 32)
                heightConstraint.isActive = true
                widthConstraint.isActive = true
                self.navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
            }
        }
    }
    
    func getPlaces() {
        APIManager.shared.getPlaces(org_id: org_id!, completion: { (success: Bool, placesData, emojisData) in
            if success == true {
                self.places = placesData
                self.emojis = emojisData
                self.filteredPlaces = self.places
                self.locationsTableView.reloadData()
            }
            else {
                print("getPlaces() failed")
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filteredPlaces = []
        places = []
        //locationsTableView.deselectRow(at: locationsTableView.indexPathForSelectedRow!, animated: true)
        
        let eatupAtViewCopy = EatupAtView()
        eatupAtViewCopy.frame = eatupAtView.frame
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            context.containerView.addSubview(eatupAtViewCopy)
        }, completion: { _ in
            eatupAtViewCopy.removeFromSuperview()
        })
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
        let locationString = EatUp.CLLocationtoString(currentLocation: currentLocation) 
        let user = Auth.auth().currentUser
        // Stores location property in current user
        if let user = user {
            let id = user.uid
            self.ref.child("users/\(id)/location").setValue(locationString)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let placeString = "\(emojis[indexPath.row])  \(filteredPlaces[indexPath.row])"
        cell.nameLabel.text =  placeString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data. For each item, return true if the item should be included and false if the
        filteredPlaces = searchText.isEmpty ? places : places.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        locationsTableView.reloadData()
    }
    
    @IBAction func openMapView(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "mapViewSegue", sender: nil)
    }
    
    func toProfile() {
        self.performSegue(withIdentifier: "profileSegue", sender: nil)
    }
     
    // Sends local eatUp object to the user feed view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectUpeeSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = locationsTableView.indexPath(for: cell) {
                let place = filteredPlaces[indexPath.row]
                let userFeedViewController = segue.destination as! UserFeedViewController
                userFeedViewController.place = place
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
