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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        if eatup?.invitee == User.current?.id {
            APIManager.shared.getUserLocation(userId: (eatup?.inviter)!, completion: { (success, location) in
                if success == true {
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    
                    //Currently set to Canary Wharf
                    let pinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
                    APIManager.shared.getUser(uid: (self.eatup?.inviter)!, completion: { (getUserBool, user) in
                        if getUserBool == true {
                            if let  mediaUrl = user.profilePhotoUrl {
                                request(mediaUrl, method: .get).responseImage(completionHandler: { (responseImage) in
                                    guard let userImage = responseImage.result.value else {
                                        // Handle error
                                        return
                                    }
                                    
                                    let pinImage = userImage.af_imageRoundedIntoCircle()
                                    
                                    let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
                                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
                                })
                            }
                        }
                    })
                    
                }
            })
        }
        else {
            APIManager.shared.getUserLocation(userId: (eatup?.invitee)!, completion: { (success, location) in
                if success == true {
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    
                    //Currently set to Canary Wharf
                    let pinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
                    let pinImage = UIImage(named: "pin")!
                    let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
                }
            })
        }
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
