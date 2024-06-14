//
//  GoogleMapViewController.swift
//  placeAutocomplete
//
//  Created by Indresh Arora on 06/11/18.
//  Copyright © 2018 Indresh Arora. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import Alamofire

protocol GoogleMapViewControllerDelegate: class {
    func googleMapViewController(_ googleMapViewController: GoogleMapViewController, selectedLocation: String)
}

class GoogleMapViewController: UIViewController {
    
    var searchResults = [GMSAutocompletePrediction]() {
        didSet {
            self.tableviewSearch.reloadData()
        }
    }
    weak var delegate: GoogleMapViewControllerDelegate?
    let locationManager = CLLocationManager()
    
    var selectedLocation: (locationName: String, placeId: String)?
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var textfieldAddress: UITextField!
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.textfieldAddress.delegate = self
        self.locationManager.delegate = self
        self.googleMapView.delegate = self
        self.textfieldAddress.text = selectedLocation?.0 ?? Strings.empty
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        var selectedLocation = (self.selectedLocation?.0 ?? Strings.empty)
        if let textfieldAddress = self.textfieldAddress.text, !textfieldAddress.isEmpty, (self.selectedLocation?.0 ?? Strings.empty).trimmingCharacters(in: .whitespacesAndNewlines) != textfieldAddress.trimmingCharacters(in: .whitespacesAndNewlines) {
            selectedLocation = textfieldAddress
        }
        if !(self.selectedLocation?.1 ?? Strings.empty).isEmpty {
            selectedLocation += String(Strings.locationSeperator)+(self.selectedLocation?.1 ?? Strings.empty)
        }
        if let textfieldAddress = self.textfieldAddress.text, textfieldAddress.isEmpty {
            selectedLocation = Strings.empty
        }
        self.delegate?.googleMapViewController(self, selectedLocation: selectedLocation)
        self.dismiss(animated: true, completion: nil)
    }
}

