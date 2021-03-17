//
//  GoogleMapsManager.swift
//  map
//
//  Created by Melki on 17/03/21.
//
import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import CoreData


typealias PlacesCompletion = ([GooglePlace]) -> Void
typealias PhotoCompletion = (UIImage?) -> Void

class GoogleMapsManager {
  private var photoCache: [String: UIImage] = [:]
  private var placesTask: URLSessionDataTask?
  private var session: URLSession {
    return URLSession.shared
  }

  func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, text:String, completion: @escaping PlacesCompletion) -> Void {
    var urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(text)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&key=\(googleApiKey)"
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
    
    guard let url = URL(string: urlString) else {
      completion([])
      return
    }
    
    if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
      task.cancel()
    }
    
    
    placesTask = session.dataTask(with: url) { data, response, error in
        var placesArray: [GooglePlace] = []
        defer {
            DispatchQueue.main.async {
                completion(placesArray)
            }
        }
        guard let data = data,
              let json = try? JSON(data: data, options: .mutableContainers),
              let results = json["results"].arrayObject as? [[String: Any]] else {
            return
        }
        results.forEach {
            let place = GooglePlace(dictionary: $0)
            placesArray.append(place)
            if let reference = place.photoReference {
                self.fetchPhotoFromReference(reference) { image in
                    place.photo = image
                }
            }
        }
    }
    placesTask?.resume()
  }
  
  
  func fetchPhotoFromReference(_ reference: String, completion: @escaping PhotoCompletion) -> Void {
    if let photo = photoCache[reference] {
      completion(photo)
    } else {
      let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(googleApiKey)"
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }
      

      
      session.downloadTask(with: url) { url, response, error in
        var downloadedPhoto: UIImage? = nil
        defer {
          DispatchQueue.main.async {
            completion(downloadedPhoto)
          }
        }
        guard let url = url else {
          return
        }
        guard let imageData = try? Data(contentsOf: url) else {
          return
        }
        downloadedPhoto = UIImage(data: imageData)
        self.photoCache[reference] = downloadedPhoto
      }
        .resume()
    }
  }
}



