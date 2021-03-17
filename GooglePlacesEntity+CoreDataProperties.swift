//
//  GooglePlacesEntity+CoreDataProperties.swift
//  map
//
//  Created by Melki on 17/03/21.
//
//

import Foundation
import CoreData


extension GooglePlacesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GooglePlacesEntity> {
        return NSFetchRequest<GooglePlacesEntity>(entityName: "GooglePlacesEntity")
    }

    @NSManaged public var formatted_address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var photo: Data?
    @NSManaged public var photoReference: String?
    @NSManaged public var placeType: NSObject?
    @NSManaged public var rating: Double
    @NSManaged public var user_ratings_total: Int64

}

extension GooglePlacesEntity : Identifiable {

}
