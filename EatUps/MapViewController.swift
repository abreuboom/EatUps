//
//  MapViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 8/2/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var backToPlacesButton: UIButton!
    
    @IBAction func didTapBackToPlaces(_ sender: Any) {
        self.performSegue(withIdentifier: "placesViewSegue", sender: nil)
        
    }
    var org_id: String!
    var place: String!
    var emojis: [String] = []
    
    var latitudeCoor: Float = 0.0
    var longitudeCoor: Float = 0.0
    var places = [String]()
    var ref: DatabaseReference?
    
    
    override func loadView() {
        
        
        latitudeCoor = 37.480364
        longitudeCoor = -122.155644
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(latitudeCoor), longitude: CLLocationDegrees(longitudeCoor), zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        ref = Database.database().reference()
        
        org_id = User.current?.org_id
        if org_id != ""{
            APIManager.shared.getPlaces(org_id: org_id!, completion: { (success: Bool, data, emojiData) in
                if success == true {
                    self.places = data
                    self.emojis = emojiData
                    
                    for i in 0 ... self.places.count-1 {
                        APIManager.shared.getPlaceLocation(place: self.places[i], completion: { (success: Bool, placeLocation) in
                            
                            if success == true {
                                
                                self.latitudeCoor = Float(placeLocation.coordinate.latitude)
                                self.longitudeCoor = Float(placeLocation.coordinate.longitude)
                                
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.latitudeCoor), longitude: CLLocationDegrees(self.longitudeCoor))
                                marker.title = self.places[i]
                                marker.icon = self.emojis[i].image()
                                marker.snippet = "Facebook University"
                                marker.map = mapView
                            }
                                
                            else {
                                print("failed")
                            }
                            
                            
                            // Do any additional setup after loading the view.
                        })
                    }
                    
                }
            })
        }
 
    }
    
    override func viewDidLoad() {
       // self.view.bringSubview(toFront: backToPlacesButton)
    }

}
