//
//  ViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var eatup: EatUp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIManager.shared.getUserLocation(userId: (User.current?.id)!) { (success, location) in
            if success == true {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let currentLocation = CLLocation(latitude: lat, longitude: lon)
                
                self.centerMapOnLocation(location: currentLocation)
            }
        }
        
        if User.current?.id == eatup?.inviter {
            APIManager.shared.getUserLocation(userId: (eatup?.invitee)!) { (success, location) in
                if success == true {
                    let annotation = MKPointAnnotation()
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    let centerCoordinate = CLLocationCoordinate2DMake(lat, lon)
                    annotation.coordinate = centerCoordinate
                    APIManager.shared.getUser(uid: (self.eatup?.invitee)!, completion: { (getUserBool, user) in
                        if getUserBool == true {
                            annotation.title = user.name
                            self.mapView.addAnnotation(annotation)
                        }
                    })
                }
            }
        }
        else {
            APIManager.shared.getUserLocation(userId: (eatup?.inviter)!) { (success, location) in
                if success == true {
                    let annotation = MKPointAnnotation()
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    let centerCoordinate = CLLocationCoordinate2DMake(lat, lon)
                    annotation.coordinate = centerCoordinate
                    APIManager.shared.getUser(uid: (self.eatup?.inviter)!, completion: { (getUserBool, user) in
                        if getUserBool == true {
                            annotation.title = user.name
                            self.mapView.addAnnotation(annotation)
                        }
                    })
                }
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

