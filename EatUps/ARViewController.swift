//
//  ARViewController.swift
//  EatUps
//
//  Created by John Abreu on 8/7/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation
import AlamofireImage
import Alamofire

class ARViewController: UIViewController {
    
    var sceneLocationView = SceneLocationView()
    
    var eatup: EatUp?
    var userPhoto: UIImage?
    var userId: String?
    
    override func viewWillAppear(_ animated: Bool) {
        sceneLocationView.run()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIManager.shared.getUserLocation(userId: userId!, completion: { (success, location) in
            if success == true {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                //Create pin for the other user's location and place it in AR
                let pinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
                let pinImage = self.userPhoto?.af_imageRoundedIntoCircle()
                let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage!)
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
                self.view.addSubview(self.sceneLocationView)
            }
        })
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sceneLocationView.pause()
        sceneLocationView.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
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
