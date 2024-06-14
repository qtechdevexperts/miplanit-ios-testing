//
//  ContentVC.swift
//  PageViewControllerWithTabs
//
//  Created by Leela Prasad on 22/03/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

protocol ContentVCDelegate: class {
    func contentVCDelegate(_ contentVC: ContentVC, selectedItem: ShopItem)
    func contentVCDelegate(_ contentVC: ContentVC, customQuantity: String)
    func contentVCDelegate(_ contentVC: ContentVC, addShopItem: ShopItem)
    func contentVCDelegate(_ contentVC: ContentVC, noSearchData: Bool)
    func contentVCDelegate(_ contentVC: ContentVC, multiSelectedShopItem: [ShopItem])
}

class ContentVC: UIViewController {
    
    var pageIndex: Int = 0
    var strTitle: String!
    var shoppingListOptionType: ShoppingListOptionType?
    var planItShopItems: [PlanItShopItems] = [] {
        didSet {
            self.shopMasterItems = planItShopItems.map({ ShopItem($0) })
        }
    }
    
    var shopMasterItems: [ShopItem] = []
    var showMasterItems: [ShopItem] = [] {
        didSet {
            self.viewNoData?.isHidden = !self.showMasterItems.isEmpty
            self.collectionView?.reloadData()
        }
    }
    var multiSelectedShopItems: [ShopItem] = []
    
    weak var delegate: ContentVCDelegate?
    var searchText: String = Strings.empty {
        didSet {
            self.updateItemWithSearch()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var viewNoData: UIView?
    
    
    
    deinit {
        print("deinit called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initilizeUIComponent()
    }

}
