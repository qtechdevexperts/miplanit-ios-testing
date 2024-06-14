//
//  AutoCompleteTagCell.swift
//  MiPlanIt
//
//  Created by Febin Paul on 30/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol AutoCompleteTagCellDelegate: class {
    func autoCompleteTagCell(_ autoCompleteTagCell: AutoCompleteTagCell, selectedText: String)
}

class AutoCompleteTagCell: UICollectionViewCell {
    
    weak var delegate: AutoCompleteTagCellDelegate?
    
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        
    }
    
    func configCell(tag: String) {
        self.labelTag.text = tag
    }
}

