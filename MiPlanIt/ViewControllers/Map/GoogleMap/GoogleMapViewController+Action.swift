//
//  GoogleMapViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Alamofire

extension GoogleMapViewController {
    
    func restartAutoPlaceTimer() {
        self.disableAutoPlaceTimer()
        self.activeAutoPlaceTimer()
    }
    
    func activeAutoPlaceTimer() {
        self.perform(#selector(showResults), with: nil, afterDelay: 0.45)
    }
    
    func disableAutoPlaceTimer() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showResults), object: nil)
    }
    
    @objc func showResults(){
        guard let searchText = self.textfieldAddress.text  else {
            return
        }
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient()
        filter.type = .address
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                DispatchQueue.main.async {
                    self.searchResults = results
                    self.searchView.isHidden = results.count == 0
                }
            }
        }
    }
    
    
    func hideResults(){
        searchView.isHidden = true
        tableviewSearch.reloadData()
    }
    
    func getAddressFromLatLong(latitude: Double, longitude : Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = latitude
        //21.228124
        let lon: Double = longitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        self.activityIndicator.startAnimating()
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                self.activityIndicator.stopAnimating()
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                guard let pm = placemarks else {
                    return
                }
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    self.selectedLocation = (addressString, Strings.empty)
                    self.textfieldAddress.text = addressString
                }
        })
        
    }
    
    func getPlaceId(of placeId: String, locaionName: String) {
        let placesClient = GMSPlacesClient.shared()
        self.activityIndicator.startAnimating()
        
        placesClient.lookUpPlaceID(placeId) { (place, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            self.googleMapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.googleMapView.clear()
            let marker = GMSMarker(position: place.coordinate)
            marker.title = locaionName
            marker.map = self.googleMapView
        }
    }
}
