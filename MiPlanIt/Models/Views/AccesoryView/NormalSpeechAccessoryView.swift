//
//  NormalSpeechAccessoryView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 24/07/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation

protocol NormalSpeechAccessoryViewDelegate: class {
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, touchDown: Any)
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, touchUpInside: Any)
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, doneClicked: Any)
    func normalSpeechAccessoryView(_ normalSpeechAccessoryView: NormalSpeechAccessoryView, autoCompleteTagSelected tag: String)
}

class NormalSpeechAccessoryView: UIView {
    
    let kCONTENT_XIB_NAME = "NormalSpeechAccessoryView"
    weak var delegate: NormalSpeechAccessoryViewDelegate?
    var showAutoCompleteTag: [String] = [] {
        didSet {
            self.collectionViewTags.reloadData()
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelListening: UILabel!
    @IBOutlet weak var constraintButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var viewContainerTags: UIView!
    @IBOutlet weak var collectionViewTags: UICollectionView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        self.collectionViewTags.register(UINib(nibName: "AutoCompleteTagCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier.autoCompleteTagCell)
        self.collectionViewTags.delegate = self
        self.collectionViewTags.dataSource = self
        contentView.fixInView(self)
    }
    
    @IBAction func speechBottonTouchDown(_ sender: Any) {
        self.delegate?.normalSpeechAccessoryView(self, touchDown: sender)
    }
    
    @IBAction func speechButtonTouchUpInside(_ sender: Any) {
        self.delegate?.normalSpeechAccessoryView(self, touchUpInside: sender)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.delegate?.normalSpeechAccessoryView(self, doneClicked: sender)
    }
    
    func updateAutoCompleteTag(_ tags: [String]) {
        self.showAutoCompleteTag = tags
    }
    
}


extension NormalSpeechAccessoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showAutoCompleteTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.autoCompleteTagCell, for: indexPath) as! AutoCompleteTagCell
        cell.configCell(tag: self.showAutoCompleteTag[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = self.showAutoCompleteTag[indexPath.row].size(withAttributes: [NSAttributedString.Key.font : UIFont(name: Fonts.SFUIDisplayRegular, size: 15)!])
        return CGSize(width: (itemSize.width < 60 ? 60 : itemSize.width)+40, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.normalSpeechAccessoryView(self, autoCompleteTagSelected: self.showAutoCompleteTag[indexPath.row])
    }
    
    
    
}
