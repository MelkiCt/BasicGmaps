//
//  MapViewModel.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import Foundation
import CoreLocation
import CoreData
import GoogleMaps
import UIKit

class MapViewModel {
    
    var adjustTableSize: Observable<Float> = Observable(0.0)
    var addMarker: Observable<(GMSMarker?, CLLocationCoordinate2D?)> = Observable((nil, nil))
    var addSearchMarkers: Observable<([GMSMarker]?)> = Observable(nil)
    var changeCamera: Observable<(CLLocationCoordinate2D?)> = Observable(nil)
    var clearPlaceMarkers: Observable<Bool> = Observable(false)
    var showPopup: Observable<(String?, String?)> = Observable((nil,nil))
    var userLocation: CLLocationCoordinate2D?
    var currentLocation: CLLocationCoordinate2D?
    private let mapManager = GoogleMapsManager()
   
    // dispatch queues
    let convertQueue = DispatchQueue.init(label: "convertQueue", attributes: .concurrent)
    let saveQueue = DispatchQueue.init(label: "saveQueue", attributes: .concurrent)
    private var searchString: String = ""
    
    private var storedPlaces: [GooglePlace]?
    
    private var places: [GooglePlace]?
    
    var tableViewSize: Float {
        guard let place = places else {
            return 0.0
        }
        if place.count == 0 {
            return 0.0
        }
        else if (place.count >= 5) {
            return 58.5*5
        }
        else {
            return Float(place.count)*58.5
        }
    }
    
    func showPlaceMark(place: GooglePlace) {
        clearPlaceMarkers.value = true
        let marker = GMSMarker(position: place.coordinate)
        marker.title = place.name
        marker.icon = UIImage(named: "icon_stored")
        addMarker.value = (marker, place.coordinate)
    }
    
    func getStoredPlaceMarkers() -> [GMSMarker]? {
        guard let places = storedPlaces else {
            return nil
        }
        var markers: [GMSMarker] = []
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.icon = UIImage(named: "icon_stored")
            markers.append(marker)
        }
        return markers
    }
    
    func setSearchString(str: String, radius: CLLocationDistance) {
        clearPlaceMarkers.value = true
        if (str.isEmpty) {
            clearSearch()
            return
        }
        guard let loc = currentLocation else {
            return
        }
        searchString = str.replacingOccurrences(of: " ", with: "+")
        mapManager.fetchPlacesNearCoordinate(loc, radius: radius, text: searchString) { [weak self] (places) in
            if (self?.searchString.isEmpty ?? true) {
                self?.places = nil
                self?.adjustTableSize.value = 0.0
                self?.addSearchMarkers.value = nil
            }
            else {
                self?.places = places
                self?.adjustTableSize.value = self?.tableViewSize ?? 0.0
                self?.addSearchMarkers.value = self?.getSearchMarkers()
                print(places)
            }
        }
    }
    
    func getSearchMarkers() -> [GMSMarker]?
    {
        guard let places = places else {
            return nil
        }
        var markers: [GMSMarker] = []
        for place in places {
            markers.append(markerForPlace(place: place))
        }
        return markers
    }
    
    func markerForPlace(place: GooglePlace) -> GMSMarker {
        let marker = GMSMarker(position: place.coordinate)
        marker.title = place.name
        return marker
    }
    
    func clearSearch() {
        clearPlaceMarkers.value = true
        searchString = ""
        self.places = nil
        self.adjustTableSize.value = 0.0
    }
    
    
    func setCurrentLocation(coordinates: CLLocationCoordinate2D) {
        userLocation = coordinates
        currentLocation = coordinates
    }
    func setMovedLocation(coordinates: CLLocationCoordinate2D) {
        currentLocation = coordinates
    }
    
    
    func getNumberOfRows() -> Int {
        guard let place = places else {
            return 0
        }
        return place.count
    }
        
    func getPlaceFor(index: Int) -> GooglePlace? {
        guard let place = places else {
            return nil
        }
        if place.count > index {
            return place[index]
        }
        return nil
    }
    
    func savePlaceFrom(index: Int) {
        clearPlaceMarkers.value = true
        guard let place = getPlaceFor(index: index) else {
            return
        }
        let foundPlace = storedPlaces?.first{ $0.coordinate.latitude == place.coordinate.latitude && $0.coordinate.longitude == place.coordinate.longitude }
        if foundPlace == nil {
            createPlacesEntityFrom(place: place)
            storedPlaces?.append(place)
            addSearchMarkers.value = [markerForPlace(place: place)]
            changeCamera.value = place.coordinate
        }
        else {
            showPopup.value = ("", "This place already in your saved list.")
        }
    }

    func getPlacesFromStorage() {
        do {
            let places = try fetchStoredPlaces()
            storedPlaces = createGooglePlacesFromStorage(managed: places)
        }
        catch {

        }
    }

    
    private func fetchStoredPlaces() throws -> [GooglePlacesEntity]? {
        var result: [GooglePlacesEntity]?
        let context = AppDelegate.getManagedObjectContext()
        let fetchRequest: NSFetchRequest<GooglePlacesEntity> = GooglePlacesEntity.fetchRequest()
        do {
            result = try context.fetch(fetchRequest)
        } catch {
        }
        return result
    }
    
    private func createGPlace(obj: GooglePlacesEntity) -> GooglePlace {
        let place = GooglePlace(managedObject: obj)
        return place
    }
    
    private func createGooglePlacesFromStorage(managed: [GooglePlacesEntity]?) -> [GooglePlace]? {
        guard let objects = managed else {
            return nil
        }
        let places = objects.map{self.createGPlace(obj: $0)}
        return places
    }

    func createPlacesEntityFrom(place: GooglePlace) {
        
        var placeImageData: Data?
        convertQueue.sync()  {
            if let imageData = place.photo?.jpegData(compressionQuality: 1)  {
                placeImageData = imageData
            }
            
        }
        convertQueue.sync {
            let moc = AppDelegate.getManagedObjectContext()
            
            guard let placeEntity = NSEntityDescription.insertNewObject(forEntityName: "GooglePlacesEntity", into: moc) as? GooglePlacesEntity else {
                print("entity error")
                return
            }
            placeEntity.name = place.name
            placeEntity.formatted_address = place.formatted_address
            placeEntity.latitude = place.coordinate.latitude
            placeEntity.longitude = place.coordinate.longitude
            placeEntity.photo = placeImageData
            placeEntity.rating = place.rating ?? 0.0
            placeEntity.user_ratings_total = place.user_ratings_total ?? 0
            do {
                try AppDelegate.getAppDelegateObj().saveContext()
            } catch let error {
                print(error)
            }
        }
    }
}


