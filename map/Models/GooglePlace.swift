//
//  GooglePlace.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import Foundation
import CoreLocation
import UIKit
import SwiftyJSON


class GooglePlace {
    let name: String
    let formatted_address: String?
    let coordinate: CLLocationCoordinate2D
    let placeType: [String]
    var photoReference: String?
    var photo: UIImage?
    var rating: Double?
    var user_ratings_total: Int64?
    init(dictionary: [String: Any])
    {
        let json = JSON(dictionary)
        name = json["name"].stringValue
        formatted_address = json["formatted_address"].stringValue
        
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        photoReference = json["photos"][0]["photo_reference"].string
        rating = json["rating"].double
        user_ratings_total = json["user_ratings_total"].int64
        placeType = json["types"].arrayObject as? [String] ?? []
    }
    init(managedObject: GooglePlacesEntity) {
        name = managedObject.name ?? ""
        formatted_address = managedObject.formatted_address ?? ""
        coordinate = CLLocationCoordinate2DMake(managedObject.latitude, managedObject.longitude)
        if let data = managedObject.photo {
            photo = UIImage.init(data: data)
        }
        photoReference = managedObject.photoReference
        rating = managedObject.rating
        user_ratings_total = managedObject.user_ratings_total
        placeType = managedObject.placeType as? [String] ?? []
    }
}
