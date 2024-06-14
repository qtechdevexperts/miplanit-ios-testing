//
//  ShopListItemViewDetails.swift
//  MiPlanIt
//
//  Created by Febin Paul on 14/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class ShopListItemViewDetails: UIViewController {
    
    var shopItemDetailModel: ShopListItemDetailModel!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeData()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func attachButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.toAttachments, sender: self)
    }
    
    @IBAction func showUrlClicked(_ sender: Any) {
        guard let text = self.textFieldUrl.text, !text.isEmpty, let url = URL(string: text) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func tagButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.pushToTagVC, sender: self.shopItemDetailModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
        case is AttachmentListViewController:
            let attachmentListViewController = segue.destination as! AttachmentListViewController
            attachmentListViewController.delegate = self
            attachmentListViewController.activityType = .none
            attachmentListViewController.attachments = self.shopItemDetailModel.attachments
            attachmentListViewController.itemOwnerId = self.shopItemDetailModel.planItShopList?.createdBy?.readValueOfUserId()
        case is NotificationShopTagsViewController:
            let notificationShopTagsViewController = segue.destination as! NotificationShopTagsViewController
            notificationShopTagsViewController.tags = self.shopItemDetailModel.tags
            notificationShopTagsViewController.textToPredict = self.shopItemDetailModel.createTextForPrediction()
            notificationShopTagsViewController.canAddTag = false
            notificationShopTagsViewController.delegate = self
        default: break
        }
    }
    
}
