//
//  MapViewController.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import UIKit
import GoogleMaps



class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchbar: SearchBarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    let manager: CLLocationManager = CLLocationManager()
    var camera: GMSCameraPosition?
    var viewModel: MapViewModel!
    let cellReusableID = "SearchTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationStatus()
        viewModel = MapViewModel()
        searchbar.delegate = self
        viewModel.getPlacesFromStorage()
        self.manager.desiredAccuracy = .greatestFiniteMagnitude
        self.manager.requestWhenInUseAuthorization()
        self.manager.distanceFilter = 50
        self.manager.startUpdatingLocation()
        self.manager.delegate = self
        
        self.camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: Float(15.0))
        self.mapView.camera = self.camera!
        self.mapView.settings.compassButton = true
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.delegate = self
        viewModel.adjustTableSize.bind { [weak self] in
            self?.tableViewHeight.constant = CGFloat($0)
            self?.view.layoutIfNeeded()
            self?.tableView.reloadData()
        }
        
        viewModel.addMarker.bind { [weak self] in
            if (($0.0) != nil) {
                $0.0!.map = self?.mapView
                if ($0.1) !=  nil {
                    let position = GMSCameraPosition(latitude: $0.1!.latitude, longitude: $0.1!.longitude, zoom: Float(15.0))
                    self?.mapView.animate(to: position)
                }
            }
        }
        viewModel.addSearchMarkers.bind { [weak self] in
            if ($0) != nil {
                for item in $0! {
                    item.map = self?.mapView
                }
            }
        }
        
        viewModel.changeCamera.bind {  [weak self] in
            if ($0) != nil {
                self?.searchbar.clearSearchText()
                let position = GMSCameraPosition(latitude: $0!.latitude, longitude: $0!.longitude, zoom: Float(15.0))
                self?.mapView.animate(to: position)
            }
        }
        
        viewModel.clearPlaceMarkers.bind { [weak self] in
            if ($0) {
                self?.mapView.clear()
            }
            
        }
        viewModel.showPopup.bind { [weak self] in
            if (($0.0) != nil || ($0.1) != nil) {
                let alert = UIAlertController(title: $0.0 ?? "", message: $0.1 ?? "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in
                    alert.dismiss(animated: true)
                    
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            searchbar.clearSearchText()
            viewModel.setSearchString(str: "", radius: getRadius())
            if (segue.identifier == "savedPlaces") {
                let destView = segue.destination as! SavedPlacesViewController
                destView.delegate = self
                // pass data to next view
            }
        }
    
    @IBAction func actionOnSavedPlaces(_ sender: UIButton) {
        manager.requestWhenInUseAuthorization()
        self.setStoredMarkers()
    }
    
    func setStoredMarkers() {
        if let markers = viewModel.getStoredPlaceMarkers() {
            for marker in markers {
                marker.map = mapView
            }
        }
    }
    
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.mapView.center
        let centerCoordinate = self.mapView.projection.coordinate(for: centerPoint)
           return centerCoordinate
       }

       func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        let topCenterCoor = self.mapView.convert(CGPoint(x: self.mapView.frame.size.width / 2.0, y: 0), from: self.mapView)
        let point = self.mapView.projection.coordinate(for: topCenterCoor)
           return point
       }
    
    
    func getRadius() -> CLLocationDistance {

        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
    
    func checkLocationStatus() {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in

                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            alertController.addAction(cancelAction)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }

}

extension MapViewController: SavedListProtocol {
    func showPlace(place: GooglePlace) {
        viewModel.showPlaceMark(place: place)
    }
    
    
}


extension MapViewController: CLLocationManagerDelegate  {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            viewModel.setCurrentLocation(coordinates: location.coordinate)
            let zoomLevel = 15.0
            camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: Float(zoomLevel))
            if ((mapView?.isHidden) != nil) {
                mapView?.isHidden = false
                mapView?.camera = camera!
            } else {
                mapView?.animate(to: camera!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }

}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        viewModel.setMovedLocation(coordinates: position.target)
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableID, for: indexPath) as! SearchTableViewCell
        cell.setPlace(place: viewModel.getPlaceFor(index: indexPath.row))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.savePlaceFrom(index: indexPath.row)
        tableViewHeight.constant = 0.0
    }
    
    
}


extension MapViewController: SearchBarViewDelegate {
    func searchByString(searchText: String) {
        viewModel.setSearchString(str: searchText, radius: getRadius())
    }
    
    func clearSearch() {
        viewModel.clearSearch()
    }
    
}

