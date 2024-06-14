//
//  ShopItemQuantityOptionView.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Speech

protocol ShopItemQuantityOptionViewDelegate: class {
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, searchText: String)
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, selectedQuantity: String)
    func shopItemQuantityOptionViewDismissKeyboard(_ shopItemQuantityOptionView: ShopItemQuantityOptionView)
    func shopItemQuantityOptionView(_ shopItemQuantityOptionView: ShopItemQuantityOptionView, addNew itemName: String)
}

class ShopItemQuantityOptionView: UIView {
    
    let kCONTENT_XIB_NAME = "ShopItemQuantityOption"
    weak var delegate: ShopItemQuantityOptionViewDelegate?
    var shopItem: ShopItem?
    var speechToTextRecorder: SpeechToTextRecorder?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTextFieldContainer: UIView!
    @IBOutlet weak var viewCollectionContainer: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAddButton: UIView!
    @IBOutlet weak var buttonRecord: UIButton!
    @IBOutlet weak var buttonAddButton: ProcessingButton!
    @IBOutlet weak var labelListening: UILabel!
    
    
    lazy var itemQuantites: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    deinit {
        print(" ")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        self.collectionView.register(UINib(nibName: "ShopItemQuantityCell", bundle: nil), forCellWithReuseIdentifier: "shopItemQuantityCell")
        contentView.fixInView(self)
        self.speechToTextRecorder = SpeechToTextRecorder()
        self.speechToTextRecorder?.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "Add / Search Items", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 114/255, green: 114/255, blue: 114/255, alpha: 1.0)])
    }
    
    @IBAction func buttonRecordTouchDownClicked(_ sender: UIButton) {
        self.labelListening.isHidden = false
        self.speechToTextRecorder?.cancelRecording()
        self.speechToTextRecorder?.recordAndRecognizeSpeech()
    }
    
    @IBAction func buttonRecordTouchInsideClicked(_ sender: UIButton) {
        self.labelListening.isHidden = true
        self.speechToTextRecorder?.cancelRecording()
    }
    
    @IBAction func onTextChange(_ sender: UITextField) {
        self.delegate?.shopItemQuantityOptionView(self, searchText: sender.text ?? Strings.empty)
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        let itemName = self.textField.text ?? Strings.empty
        self.textField.text = Strings.empty
        guard !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.showAlertWithAction(message: Message.validTitleforItem, title: Message.warning, items: [Message.cancel], callback: { index in
            })
            return
        }
        self.delegate?.shopItemQuantityOptionView(self, addNew: itemName)
    }
    
    func startPlusButtonAnimation() {
        self.buttonAddButton.clearButtonTitleForAnimation()
        self.buttonAddButton.startAnimation()
    }
    
    func stopPlusButtonAnimation(with status: Bool, callback: @escaping(Bool)->()) {
        if status {
            self.buttonAddButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0) {
                self.buttonAddButton.showTickAnimation(borderOnly: true) { (result) in
                    self.buttonAddButton.clearButtonTitleForAnimation()
                    self.buttonAddButton.setImage(#imageLiteral(resourceName: "plusicon"), for: .normal)
                    callback(true)
                }
            }
        }
        else {
            self.buttonAddButton.setImage(#imageLiteral(resourceName: "plusicon"), for: .normal)
            self.buttonAddButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0) {
                callback(false)
            }
        }
    }
    
    func setPreviousQuantitysOfShopItem(_ shopItem: PlanItShopItems?) {
        guard let planItShopItems = shopItem else { return }
        let allQuantities = DatabasePlanItShopListItem().readAllShopQuantityListItem(planItShopItems).compactMap({ $0.readQuantity().trimmingCharacters(in: .whitespacesAndNewlines) })
        var distintValues = [String]()
        for value in allQuantities {
            if !distintValues.contains(value) {
                distintValues.append(value)
            }
        }
        if distintValues.isEmpty {
            distintValues = ["1", "2", "3", "4", "5", "6"]
        }
        distintValues.insert(Strings.details, at: 0)
        self.itemQuantites = distintValues
        self.collectionView.reloadData()
    }
    
    func enableTextField() {
        self.viewCollectionContainer.isHidden = true
        self.viewTextFieldContainer.isHidden = false
        self.buttonRecord.isHidden = false
        self.textField.becomeFirstResponder()
    }
    
    func enablQuantityOption(shopItem: ShopItem?) {
        self.setPreviousQuantitysOfShopItem(shopItem?.planItShopItem)
        self.setVisibilityAddButton(show: false)
        self.viewCollectionContainer.isHidden = false
        self.viewTextFieldContainer.isHidden = true
        self.shopItem = shopItem
        self.buttonRecord.isHidden = true
        self.textField.resignFirstResponder()
    }
    
    func closeQuantityOption() {
        self.setVisibilityAddButton(show: false)
        self.viewCollectionContainer.isHidden = true
        self.viewTextFieldContainer.isHidden = false
        self.buttonRecord.isHidden = true
        self.buttonRecord.isHidden = true
    }
    
    func deinitQuantityOption() {
        self.shopItem = nil
        self.delegate = nil
    }
    
    func setVisibilityAddButton(show flag: Bool) {
        self.buttonAddButton.isHidden = !flag
    }
    func showAlertWithAction(message: String, title: String = Strings.empty, preferredStyle: UIAlertController.Style = .alert, items: [String], callback: @escaping (_ buttonIndex : NSInteger?) ->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let closure = { (action: UIAlertAction!) -> Void in
            callback(alert.actions.firstIndex(of: action))
        }
        for item in items {
            let defaultAction = UIAlertAction(title: item, style: .default, handler: closure)
            alert.addAction(defaultAction)
        }
        self.parentContainerViewController()?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showAlertOntopMostViewController(message: String) {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return
        }
        var topController = rootViewController
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        topController.showAlert(message: message, title: Message.warning, preferredStyle: .alert)
    }
}

extension ShopItemQuantityOptionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemQuantites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopItemQuantityCell", for: indexPath) as! ShopItemQuantityCell
        cell.configCell(quantity: self.itemQuantites[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60.0, height: 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.shopItemQuantityOptionView(self, selectedQuantity: self.itemQuantites[indexPath.row])
    }
    
}

extension ShopItemQuantityOptionView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = Strings.empty
        self.delegate?.shopItemQuantityOptionViewDismissKeyboard(self)
        return true
    }
}


extension ShopItemQuantityOptionView: SpeechToTextRecorderDelegate {
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, speechSuggustionOff status: Bool) {
        
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, showAlert message: String) {
        self.showAlertOntopMostViewController(message: message)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, setText text: String) {
        self.textField.text = text
        self.delegate?.shopItemQuantityOptionView(self, searchText: text)
    }
    
    func speechToTextRecorder(_ speechToTextRecorder: SpeechToTextRecorder, multiChannel count: AVAudioChannelCount) {
    }
}
