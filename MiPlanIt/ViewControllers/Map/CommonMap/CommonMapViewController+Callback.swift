//
//  CommonMapViewController+Callback.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation
import MapKit

extension CommonMapViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.selectedLocation?.locationName = Strings.empty
        self.selectedLocation?.longitude = nil
        self.selectedLocation?.latitude = nil
        return true
    }
}


extension CommonMapViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell) as? LocationTableViewCell
        cell?.configMapItem(self.searchResults[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.searchResults.count > indexPath.row else { return }
        let searchRequest = MKLocalSearch.Request(completion: self.searchResults[indexPath.row])
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil, let mapItems = response?.mapItems.first {
                self.textfieldAddress.text = mapItems.placemark.title
                self.selectedLocation = (locationName: mapItems.placemark.title ?? Strings.empty, latitude: Double(mapItems.placemark.coordinate.latitude), longitude: Double(mapItems.placemark.coordinate.longitude))
                self.searchView.isHidden = true
                self.view.endEditing(true)
                self.dropPinZoomIn(placemark: mapItems.placemark)
            }
        }
    }
}

extension CommonMapViewController : CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        self.userLocation = location.coordinate
        if let location = self.selectedLocation, location.locationName.isEmpty, location.latitude == nil, location.longitude == nil {
            mapView.setRegion(region, animated: true)
            self.setUserLocationName {
            }
        }
    }

}


extension CommonMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        
        return pinView
    }
}


extension CommonMapViewController: SpeechTextFieldDelegate {
    
    func speechTextField(_ speechTextField: SpeechTextField, valueChanged text: String) {
        if !text.isEmpty {
            self.getSearchResults(for: text)
        }
    }
    
    func speechTextField(_ speechTextField: SpeechTextField, valueAdded text: String) {
        
    }
}


extension CommonMapViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        self.searchResults = completer.results
        self.searchView.isHidden = completer.results.count == 0
        self.tableviewSearch.reloadData()
        
//        if let compltionData = completer.results.first {
//            let searchRequest = MKLocalSearch.Request(completion: compltionData)
//            let search = MKLocalSearch(request: searchRequest)
//            search.start { (response, error) in
//                if error == nil, let mapItems = response?.mapItems {
//                    self.searchResults = mapItems
//                    self.searchView.isHidden = mapItems.count == 0
//                    self.tableviewSearch.reloadData()
//                }
//            }
//        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}
