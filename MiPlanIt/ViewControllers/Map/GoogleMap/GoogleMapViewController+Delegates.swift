//
//  GoogleMapViewController+Delegates.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Alamofire
import MapKit


extension GoogleMapViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        if fullText.count > 2 {
            self.restartAutoPlaceTimer()
        }else{
            hideResults()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.selectedLocation?.locationName = Strings.empty
        self.selectedLocation?.placeId = Strings.empty
        return true
    }
}


extension GoogleMapViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.searchResults.count)
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell) as? LocationTableViewCell
        cell?.config(self.searchResults[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textfieldAddress.text = self.searchResults[indexPath.row].attributedFullText.string
        self.selectedLocation = (self.searchResults[indexPath.row].attributedFullText.string, self.searchResults[indexPath.row].placeID)
        self.searchView.isHidden = true
        self.view.endEditing(true)
        self.getPlaceId(of: self.searchResults[indexPath.row].placeID, locaionName: self.searchResults[indexPath.row].attributedFullText.string)
    }
}


extension GoogleMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        guard let savedLocation = self.selectedLocation else {
            self.googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.getAddressFromLatLong(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
            return
        }
        if !savedLocation.1.isEmpty {
            self.getPlaceId(of: savedLocation.1, locaionName: savedLocation.0)
        }
        else if !savedLocation.0.isEmpty {
            self.textfieldAddress.text = savedLocation.0
        }
        else {
            self.googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.getAddressFromLatLong(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        locationManager.stopUpdatingLocation()
    }
    
}

extension GoogleMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.googleMapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        self.getAddressFromLatLong(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let cordinates = self.googleMapView.myLocation?.coordinate, let lat =  self.googleMapView.myLocation?.coordinate.latitude, let long = self.googleMapView.myLocation?.coordinate.longitude else {
            return true
        }
        self.googleMapView.camera = GMSCameraPosition(target: cordinates, zoom: 15, bearing: 0, viewingAngle: 0)
        self.textfieldAddress.text = nil
        self.getAddressFromLatLong(latitude: lat, longitude: long)
        return true
    }
}
