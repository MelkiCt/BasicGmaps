//
//  SavedPlaceVM.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import Foundation
import CoreData

class SavedPlaceVM {
    private var places: [GooglePlace]?
    var isNoData: Observable<Bool?> = Observable(false)
    
    init() {
        self.getPlacesFromStorage()
    }
    
    
    func getPlacesFromStorage() {
        do {
            let places = try fetchStoredPlaces()
            self.places = createGooglePlacesFromStorage(managed: places)
        }
        catch {
            
        }
        if (self.places?.count == 0) {
            isNoData.value = true
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
    
    
    private func createGooglePlacesFromStorage(managed: [GooglePlacesEntity]?) -> [GooglePlace]? {
        guard let objects = managed else {
            return nil
        }
        let places = objects.map{self.createGPlace(obj: $0)}
        return places
    }
    
    private func createGPlace(obj: GooglePlacesEntity) -> GooglePlace {
        let place = GooglePlace(managedObject: obj)
        return place
    }

    
    
    var numberOfRowsInSection: Int {
        return places?.count ?? 0
    }
    func placeFor(index: Int) -> GooglePlace? {
        return places?[index]
    }
}
