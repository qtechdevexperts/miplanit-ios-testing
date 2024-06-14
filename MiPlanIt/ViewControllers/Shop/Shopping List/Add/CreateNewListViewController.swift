//
//  CreateNewListViewController.swift
//  MiPlanIt
//
//  Created by fsadsmin on 24/08/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol CreateNewListViewControllerDelegate: class {
    func createNewListViewController(_ viewController: CreateNewListViewController, createdUpdatedShoppingList list: PlanItShopList?)
}
class CreateNewListViewController: UIViewController {
    
    var shop: ShopList = ShopList()

    @IBOutlet weak var buttonSave: ProcessingButton!
    @IBOutlet weak var viewImageHolder: UIView!
    @IBOutlet weak var viewShoppingListBG: UIView!
    @IBOutlet weak var textFieldShoppingListName: GrowingSpeechTextView!
    @IBOutlet var arrayShoppingListImageViews: [CalendarImageView]!
    @IBOutlet weak var viewShoppingListBGColor: CalendarColorView!
    @IBOutlet weak var imageViewShoppingListImage: UIImageView!
    
    weak var delegate: CreateNewListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
    }

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.createNewListViewController(self, createdUpdatedShoppingList: nil)
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        self.shop.shopListName = self.shop.shopListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard self.validShopList() else {
            self.showAlertWithAction(message: Message.validTitle, title: Message.warning, items: [Message.cancel], callback: { index in
            })
            return
        }
        if self.hasDuplicateShopListName() {
            self.showAlertWithAction(message: Message.duplicateShopListName, title: Message.warning, items: [Message.cancel], callback: { index in
            })
            return
        }
        self.saveShopListToServerUsingNetwork()
    }
    
    @IBAction func changeButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    
    @IBAction func shopListTextChanges(_ sender: UITextField) {

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is ProfileMediaDropDownViewController:
            let uploadOptionsDropDownViewController = segue.destination as? ProfileMediaDropDownViewController
            uploadOptionsDropDownViewController?.delegate = self
        default: break
        }
    }

}
