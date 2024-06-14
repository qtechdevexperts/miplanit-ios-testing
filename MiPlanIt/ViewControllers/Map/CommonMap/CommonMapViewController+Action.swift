//
//  CommonMapViewController+Action.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MapKit

extension CommonMapViewController {
    
    func initializeData() {
        self.initializeMap()
        self.textfieldAddress.speechTextFieldDelegate = self
        self.textfieldAddress.text = self.selectedLocation?.locationName ?? Strings.empty
        self.searchCompleter.delegate = self
    }
    
    func initializeMap() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func getSearchResults(for searchText: String) {
        guard !searchText.isEmpty, searchText.count > 2 else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = self.mapView.region
        if #available(iOS 13.0, *) {
            request.resultTypes = .pointOfInterest
        }
        if self.searchCompleter.isSearching {
            self.searchCompleter.cancel()
        }
        self.searchCompleter.queryFragment = searchText
    }
    
    func dropPinZoomIn(placemark: MKPlacemark){
        self.mapView.removeAnnotations(self.mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func showLocation(location: CLLocation, locationName: String) {
        let mUserLocation:CLLocation = location
        
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
        mkAnnotation.title = locationName
        self.mapView.addAnnotation(mkAnnotation)
        
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(mRegion, animated: true)
    }
    
    func setUserLocationName(completionHandler: @escaping () -> ()) {
        guard let userLocation = self.userLocation, !self.gotUserLocationOnce else {
            completionHandler()
            return
        }
        self.textfieldAddress.isUserInteractionEnabled = false
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)) { (placemarksArray, error) in
            self.textfieldAddress.isUserInteractionEnabled = true
            if let locationMark = placemarksArray, locationMark.count > 0, let placemark = locationMark.first, (self.textfieldAddress.text ?? Strings.empty).isEmpty {
                let locality = (placemark.locality ?? Strings.empty).isEmpty ? Strings.empty : (placemark.locality ?? Strings.empty)+", "
                let bairro = (placemark.subLocality ?? Strings.empty).isEmpty ? Strings.empty : (placemark.subLocality ?? Strings.empty)+" "
                let street = (placemark.thoroughfare ?? Strings.empty).isEmpty ? Strings.empty : (placemark.thoroughfare ?? Strings.empty)+", "
                let addressLabel = street+locality+bairro
                self.selectedLocation = (locationName: addressLabel, latitude: Double(userLocation.latitude), longitude: Double(userLocation.longitude))
                self.textfieldAddress.text = addressLabel
                self.gotUserLocationOnce = true
            }
            completionHandler()
        }
    }
}
