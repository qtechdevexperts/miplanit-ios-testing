//
//  SuggustedStringCollectionViewCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 09/05/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol SuggustedStringCollectionViewCelllDelegate: class {
    func suggustedStringCollectionViewCell(_ cell: SuggustedStringCollectionViewCell, selected hint: PlanItShopItems)
}

class SuggustedStringCollectionViewCell: UICollectionViewCell {
    
    var hint: PlanItShopItems!
    weak var delegate: SuggustedStringCollectionViewCelllDelegate?
    
    // MARK:- IBOutlet
    @IBOutlet weak var buttonAddTag: UIButton!
    @IBOutlet weak var labelString: UILabel!
    
    func configureHint(_ hint: PlanItShopItems, vc: SuggustedStringCollectionViewCelllDelegate) {
        self.delegate = vc
        self.hint = hint
        self.labelString.text = hint.itemName
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        self.delegate?.suggustedStringCollectionViewCell(self, selected: self.hint)
    }
}
