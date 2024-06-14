//
//  ShoppingItemDetailViewController.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/10/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol ShoppingItemDetailViewControllerDelegate: class {
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, addUpdateItemDetail: ShopListItemDetailModel)
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onDeleteShopListItem: ShopListItemDetailModel)
    func shoppingItemDetailViewController(_ shoppingItemDetailViewController: ShoppingItemDetailViewController, onAddUserCategory: CategoryData)
}

class ShoppingItemDetailViewController: UIViewController {

    var shopItemDetailModel: ShopListItemDetailModel!
    weak var delegate: ShoppingItemDetailViewControllerDelegate?
    var onAdding: Bool = true
    var cachedImageNormal: UIImage?
    var cachedImageSel: UIImage?
    
    @IBOutlet weak var imageViewItem: UIImageView!
    @IBOutlet weak var textViewItemName: GrowingSpeechTextView!
    @IBOutlet weak var textfieldQuantityCount: UITextField!
    @IBOutlet weak var buttonDelete: ProcessingButton!
    @IBOutlet weak var buttonSave: ProcessingButton!
    @IBOutlet weak var buttonCheckMarkAsComplete: ProcessingButton?
    @IBOutlet weak var viewCompletedOverlay: UIView!
    @IBOutlet weak var buttonFavorite: ProcessingButton!
    @IBOutlet weak var buttonChangeCategory: UIButton!
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var textFieldStoreName: FloatingTextField!
    @IBOutlet weak var textFieldBrandName: FloatingTextField!
    @IBOutlet weak var textFieldTargetPrice: FloatingTextField!
    @IBOutlet weak var textFieldUrl: FloatingTextField!
    @IBOutlet weak var textAreaNotes: GrowingSpeechTextView!
    @IBOutlet weak var labelShopListName: UILabel!
    @IBOutlet weak var buttonUrlLink: UIButton!
    @IBOutlet weak var constraintWithItemImage: NSLayoutConstraint!
    @IBOutlet weak var labelShoppingTagCount: UILabel!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var viewDueDatePicker: UIView!
    @IBOutlet weak var buttonChangeCategoryArrow: UIButton!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonRemoveDueDate: UIButton!
    @IBOutlet weak var viewOverlayReminder: UIView!
    @IBOutlet weak var labelRemindMe: UILabel!
    @IBOutlet weak var buttonRemoveReminder: UIButton!
    @IBOutlet weak var imageViewReminderSideArrow: UIImageView?
    @IBOutlet weak var viewAddAttachment: UIView!
    @IBOutlet weak var collectionViewAttachments: UICollectionView!
    @IBOutlet weak var pageControlAttachment: UIPageControl!
    @IBOutlet weak var dayDatePicker: DayDatePicker?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeUI()
    }
    
    @IBAction func dueDateClicked(_ sender: UIButton) {
        self.viewDueDatePicker.isHidden = !self.viewDueDatePicker.isHidden
        let dueData = self.shopItemDetailModel.dueDate ?? Date().initialHour()
        self.updateDueDate(date: dueData < Date().initialHour() ? Date().initialHour() : dueData)
        self.buttonRemoveDueDate.isHidden = false
        self.viewOverlayReminder.isHidden = true
    }
    
    @IBAction func removeOverdue(_ sender: UIButton) {
        sender.isHidden = true
        self.updateDueDate(date: nil)
        self.labelDueDate.text = "Add Due Date"
        self.labelDueDate.textColor = .lightGray
        self.viewDueDatePicker.isHidden = true
        self.updateRemindMeTitle()
    }
    
    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        self.updateDueDate(date: sender.date)
        self.labelDueDate.text = "Due " + sender.date.stringFromDate(format: DateFormatters.EEEDDHMMMHYYY)
        self.buttonRemoveDueDate.isHidden = false
        self.viewOverlayReminder.isHidden = true
    }
    
    @IBAction func tagButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.pushToTagVC, sender: self.shopItemDetailModel)
    }
    
    @IBAction func updateCompleteStatus(_ sender: UIButton) {
        self.saveShopListItemCompleteToServerUsingNetwotk(with: !sender.isSelected)
    }
    
    @IBAction func favoriteChanged(_ sender: UIButton) {
        self.saveShopListItemFavoriteToServerUsingNetwotk(with: !self.buttonFavorite.isSelected)
    }
    
    @IBAction func changeCategoryClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.showCategoryList, sender: self.shopItemDetailModel)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.validateSave() {
            self.buttonSave.startAnimation()
            self.updateModelWithData()
            self.startPendingUploadOfAttachment()
        }
    }
    
    
    @IBAction func deleteShopListItemClicked(_ sender: UIButton) {
        self.showAlertWithAction(message: Message.deleteShoppingItemMessage, title: Message.deleteShoppingItem, items: [Message.yes, Message.cancel], callback: { buttonindex in
            if buttonindex == 0 {
                self.deleteShopListItemDetailsToServerUsingNetwotk()
            }
        })
    }
    
    @IBAction func quantityChange(_ sender: UITextField) {
//        var quantityValue = "1"
//        if let quantity = sender.text, !quantity.isEmpty {
//            quantityValue = quantity
//        }
    }
    
    @IBAction func showUrlClicked(_ sender: Any) {
        guard let text = self.textFieldUrl.text, !text.isEmpty, let url = URL(string: text) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func attachButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    @IBAction func removeReminderClicked(_ sender: UIButton) {
        self.labelRemindMe.text = "Remind Me On"
        self.shopItemDetailModel.remindValue = nil
        self.updateRemindMeTitle()
    }
    
    @IBAction func reminderButtonClicked(_ sender: UIButton) {
        guard self.shopItemDetailModel.dueDate != nil else {
            return
        }
        self.performSegue(withIdentifier: "seguePushReminder", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AttachmentListViewController:
            let attachmentListViewController = segue.destination as! AttachmentListViewController
            attachmentListViewController.delegate = self
            attachmentListViewController.activityType = .shopping
            attachmentListViewController.attachments = self.shopItemDetailModel.attachments
            attachmentListViewController.itemOwnerId = self.shopItemDetailModel.planItShopList?.createdBy?.readValueOfUserId()
        case is AttachFileDropDownViewController:
            let attachDropDownViewController = segue.destination as? AttachFileDropDownViewController
            attachDropDownViewController?.delegate = self
            attachDropDownViewController?.countofAttachments = self.shopItemDetailModel.attachments.count
        case is AddShoppingTagViewController:
            let addShoppingTagViewController = segue.destination as! AddShoppingTagViewController
            addShoppingTagViewController.delegate = self
            if let shopListItemDetailModel = sender as? ShopListItemDetailModel {
                addShoppingTagViewController.tags = shopListItemDetailModel.tags
                addShoppingTagViewController.textToPredict = shopListItemDetailModel.createTextForPrediction()
            }
        case is CategoryListSectionViewController:
            let categoryListSectionViewController = segue.destination as! CategoryListSectionViewController
            categoryListSectionViewController.delegate = self
            categoryListSectionViewController.shopItemModel = sender
        case is ShopReminderViewController:
            let shopReminderViewController = segue.destination as! ShopReminderViewController
            shopReminderViewController.startDate = self.shopItemDetailModel.dueDate
            shopReminderViewController.toDoReminder = ReminderModel(self.shopItemDetailModel.remindValue, from: .shopping)
            shopReminderViewController.delegate = self
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        default: break
        }
    }
    
    
}
