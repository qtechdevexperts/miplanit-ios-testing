//
//  LocationTableViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 22/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var lableMainLocation: UILabel!
    @IBOutlet weak var labelSubLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ place: GMSAutocompletePrediction) {
        self.lableMainLocation.text = place.attributedPrimaryText.string
        self.labelSubLocation.text = place.attributedSecondaryText?.string
    }
    
    func configMapItem(_ item: MKLocalSearchCompletion) {
        self.lableMainLocation.text = item.title
        self.labelSubLocation.text = item.subtitle
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
                            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
                    (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
                            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
}
