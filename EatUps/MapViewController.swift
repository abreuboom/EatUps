//
//  MapViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var org_id: String!
    var place: String!
    
    var latitudeCoor: Float = 0.0
    var longitudeCoor: Float = 0.0
    var places = [String]()

    override func loadView() {
        
        
        latitudeCoor = 37.480364
        longitudeCoor = -122.155644
        let locationString = "37.480364,-122.155644"
        let camera = GMSCameraPosition.camera(withTarget: EatUp.CLLocationtoCLLocationCoordinate2D(locationString: locationString), zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitudeCoor), longitude: CLLocationDegrees(longitudeCoor))
        marker.title = "idk"
        marker.snippet = "idk"
        marker.map = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        org_id = User.current?.org_id
        if org_id != ""{
            APIManager.shared.getPlaces(org_id: org_id!, completion: { (success: Bool, data) in
            if success == true {
                self.places = data
                
                for place in self.places {
                    APIManager.shared.getPlaceLocation(place: place, completion: { (success: Bool, placeLocation) in
                         
                 })
                }
            }
            else {
                print("getPlaces() failed")
            }
            

        // Do any additional setup after loading the view.
            })
        }
        
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
