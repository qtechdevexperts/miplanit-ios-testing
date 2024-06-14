//
//  CalendarColorView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 03/06/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CalendarColorViewDelegate: class {
    func calendarColorView(_ calendarColorView: CalendarColorView, selectedColorCode: String)
}

class CalendarColorView: UIView {
    
    lazy var arrayColorCodes: [CalendarColor] = {
        return setCalendarColor()
    }()
    weak var delegate: CalendarColorViewDelegate?
    
    @IBOutlet weak var collectionViewColor: UICollectionView!
    
    func setCalendarColor() -> [CalendarColor] {
        var arrayCalendarColor: [CalendarColor] = Storage().getAllColorCodes().compactMap({ CalendarColor(colorCode: $0, isSelected: false) })
        let element = arrayCalendarColor.removeLast()
        element.isSelected = true
        arrayCalendarColor.insert(element, at: 0)
        return arrayCalendarColor
    }
    
    func getDefaultColot() -> CalendarColor? {
        return self.arrayColorCodes.first
    }
    
    func setSelectionForColor(colorCode: String) {
        guard !colorCode.isEmpty else {
            self.delegate?.calendarColorView(self, selectedColorCode: self.arrayColorCodes[0].colorCode.readColorCodeKey())
            return
        }
        for (index, color) in self.arrayColorCodes.enumerated() {
            if color.colorCode.readColorCodeKey() == colorCode {
                self.resetSelection()
                self.arrayColorCodes[index].isSelected = true
                break
            }
        }
        self.collectionViewColor.reloadData()
    }
    
    func resetSelection() {
        self.arrayColorCodes.forEach { (color) in
            color.isSelected = false
        }
    }
    
}


extension CalendarColorView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayColorCodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.calendarColorCell, for: indexPath) as! CalendarColorCell
        cell.configColor(calendarColor: self.arrayColorCodes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.arrayColorCodes.forEach({ $0.isSelected = false })
        self.arrayColorCodes[indexPath.row].isSelected = true
        self.collectionViewColor.reloadData()
        self.delegate?.calendarColorView(self, selectedColorCode: self.arrayColorCodes[indexPath.row].colorCode.readColorCodeKey())
    }
}
