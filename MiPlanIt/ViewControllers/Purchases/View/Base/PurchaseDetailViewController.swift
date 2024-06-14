//
//  PurchaseDetailViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

protocol PurchaseDetailViewControllerDelegate: class {
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, deletedPurchase purchase: PlanItPurchase)
    func purchaseDetailViewController(_ viewController: PurchaseDetailViewController, updatedPurchase purchase: PlanItPurchase)
}


class PurchaseDetailViewController: UIViewController {

    var planitPurchase: PlanItPurchase!
    weak var delegate: PurchaseDetailViewControllerDelegate?
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelCardName: UILabel!
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelBillDate: UILabel!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var buttonDelete: ProcessingButton!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBOutlet weak var labelDateType: UILabel?
    @IBOutlet weak var labelPurchaseCategoryType: UILabel?
    
    
    var isModified = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isModified {
            self.delegate?.purchaseDetailViewController(self, updatedPurchase: self.planitPurchase)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        self.openMapForPlace()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func attachmentsButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toAttachments, sender: self)
    }
    @IBAction func editButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toAddPurchase, sender: self)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.deletePurchase()
    }
    
    
//     MARK: - Navigation

//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is AddPurchaseViewController:
            let editPurchaseViewController =  segue.destination as! AddPurchaseViewController
            editPurchaseViewController.purchaseModel = Purchase(with: self.planitPurchase)
            editPurchaseViewController.delegate = self
        case is AttachmentListViewController:
            let attachmentListViewController =  segue.destination as! AttachmentListViewController
            attachmentListViewController.activityType = .none
            let ownerIdValue = self.planitPurchase.createdBy?.readValueOfUserId()
            attachmentListViewController.attachments = self.planitPurchase.readAllAttachments().map({ return UserAttachment(with: $0, type: .purchase, ownerId: ownerIdValue) })
            attachmentListViewController.itemOwnerId = ownerIdValue
        case is AddPurchaseTagViewController:
            let addPurchaseTagViewController = segue.destination as! AddPurchaseTagViewController
            addPurchaseTagViewController.tags = self.planitPurchase.readAllTags().compactMap({ $0.tag })
            addPurchaseTagViewController.canAddTag = false
        default:
            break
        }
    }
}
