//
//  EatUp.swift
//  EatUps
//
//  Created by John Abreu on 7/12/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import Foundation
import CoreLocation

class EatUp {
    
    var dictionary: [String: Any]?
    
    // MARK: Properties
    var id: String // For identifying which EatUp
    var users: [String: Bool?] // Participating users and respective ratings
    var place: String // EatUp location
    var org_id: Int64 // EatUp org
    var time: NSDate // EatUp date and time
    
    // MARK: - Create initializer with dictionary
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        id = dictionary["id"] as! String
        users = dictionary["users"] as! [String: Bool?]
        place = dictionary["place"] as! String
        org_id = dictionary["org_id"] as! Int64
        time = dictionary["time"] as! NSDate
    }
    
    class func stringToCLLocation(locationString: String) -> CLLocation {
        let latitude = Double((locationString.components(separatedBy: ",")[0]))
        let longitude = Double((locationString.components(separatedBy: ",")[1]))
        let checkLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        return checkLocation
    }
    
    class func CLLocationtoString(currentLocation: CLLocation) -> String {
        let latitude: String = String(format: "%f", currentLocation.coordinate.latitude)
        let longitude: String = String(format:"%f", currentLocation.coordinate.longitude)
        let locationString = "\(latitude), \(longitude)"
        return locationString
    }
    
}
