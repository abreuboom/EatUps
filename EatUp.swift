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
    var id: String? // For identifying which EatUp
    var inviter: String // User who requested EatUp
    var invitee: String // User who accepted EatUp
    var conversationId: String? // ID for conversation
    var place: String // EatUp location
    var org_id: String // EatUp org
    var time: Int // EatUp date and time

    // MARK: - Create initializer with dictionary
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        inviter = dictionary["inviter"] as! String
        invitee = dictionary["invitee"] as! String
        //conversationId = dictionary["conversation"] as! String
        place = dictionary["place"] as! String
        org_id = dictionary["org_id"] as! String
        time = dictionary["time"] as! Int
    }
    
    // MARK: TODO: Get current eatUp ID
    class func getEatUpID() -> String {
        return "eatup_id"
    }

    // MARK: String and CLLocation conversion methods
    class func stringToCLLocation(locationString: String) -> CLLocation {
        let latitude = CLLocationDegrees((locationString.components(separatedBy: ",")[0]))
        let longitude = CLLocationDegrees((locationString.components(separatedBy: ",")[1]))
        let checkLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        return checkLocation
    }

    class func CLLocationtoString(currentLocation: CLLocation) -> String {
        let latitude: String = String(format: "%f", currentLocation.coordinate.latitude)
        let longitude: String = String(format:"%f", currentLocation.coordinate.longitude)
        let locationString = "\(latitude),\(longitude)"
        return locationString
    }
    

}
