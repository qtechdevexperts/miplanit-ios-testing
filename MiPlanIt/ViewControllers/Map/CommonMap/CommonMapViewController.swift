//
//  CommonMapViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import MapKit

protocol CommonMapViewControllerDelegate: class {
    func commonMapViewController(_ commonMapViewController: CommonMapViewController, selectedLocation: String, latitude: Double?, longitude: Double?)
}

class CommonMapViewController: UIViewController {
    
    var searchResults = [MKLocalSearchCompletion]() {
        didSet {
            self.tableviewSearch.reloadData()
        }
    }
    let locationManager = CLLocationManager()
    var selectedLocation: (locationName: String, latitude: Double?, longitude: Double?)?
    weak var delegate: CommonMapViewControllerDelegate?
    var userLocation: CLLocationCoordinate2D?
    var gotUserLocationOnce: Bool = false
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        return  MKLocalSearchCompleter()
    }()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var textfieldAddress: SpeechTextField!
    @IBOutlet weak var searchView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let selectedLocation = self.selectedLocation, let latitude = selectedLocation.latitude, let longitude = selectedLocation.longitude else {
            return
        }
        self.showLocation(location: CLLocation(latitude: latitude, longitude: longitude), locationName: selectedLocation.locationName)
    }
    
    @IBAction func searchValueChanged(_ sender: UITextField) {
        guard let searchtext = self.textfieldAddress.text, !searchtext.isEmpty else {
            self.searchResults.removeAll()
            self.searchView.isHidden = true
            self.searchCompleter.cancel()
            return
        }
        self.getSearchResults(for: searchtext)
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        if let locationName = self.textfieldAddress.text, locationName.isEmpty {
            self.gotUserLocationOnce = false
            self.setUserLocationName {
                self.dismissController()
            }
        }
        else {
            self.dismissController()
        }
    }
    
    func dismissController() {
        self.dismiss(animated: true) {
            var locationName = Strings.empty
            var latitude: Double?
            var longitude: Double?
            if let selectLocation = self.selectedLocation {
                locationName = selectLocation.locationName
                latitude = selectLocation.latitude
                longitude = selectLocation.longitude
                if let searchText = self.textfieldAddress.text, searchText.trimmingCharacters(in: .whitespacesAndNewlines) != selectLocation.locationName,  !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    locationName = (self.textfieldAddress.text ?? Strings.empty).trimmingCharacters(in: .whitespacesAndNewlines)
                    latitude = nil
                    longitude = nil
                }
            }
            self.delegate?.commonMapViewController(self, selectedLocation: locationName, latitude: latitude, longitude: longitude)
        }
    }
}


