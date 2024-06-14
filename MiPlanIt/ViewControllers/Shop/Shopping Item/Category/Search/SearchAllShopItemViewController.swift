//
//  SearchAllShopItemViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 05/11/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol SearchAllShopItemViewControllerDelegate: class {
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, editShopListItem shopItem: PlanItShopListItems, withQuantity quantity: String)
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, selectedShopItem: ShopItem)
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addNew itemName: String)
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, showDetail shopItem: ShopItem)
    func searchAllShopItemViewControllerOnClose(_ searchAllShopItemViewController: SearchAllShopItemViewController)
    func searchAllShopItemViewController(_ searchAllShopItemViewController: SearchAllShopItemViewController, addedNewItem item: ShopListItemDetailModel)
}

class SearchAllShopItemViewController: UIViewController {
    
    lazy var shopAllItems: [ShopItem] = {
        return self.getAllShopListItem()
    }()
    
    var showItems: [ShopItem] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    weak var delegate: SearchAllShopItemViewControllerDelegate?
    var currentSelectedShopItem: ShopItem?
    var currentPlanItShopList: PlanItShopList?
    var planItShopCategory: PlanItShopMainCategory?
    
    lazy var addedShopItems: [PlanItShopListItems]  = {
        if let shopList = self.currentPlanItShopList, let specificShopList = DatabasePlanItShopList().readSpecificShop([shopList.shopListId]).first {
            return specificShopList.readAllAvailableShopListItems()
        }
        return []
    }()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewQuantityOption: ShopItemQuantityOptionView!
    @IBOutlet weak var constraintQuantityBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomCollectionView: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initilizeUIComponent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewQuantityOption.enableTextField()
    }
    
    @IBAction func dismissSearchClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.searchAllShopItemViewControllerOnClose(self)
        }
    }
    
}
