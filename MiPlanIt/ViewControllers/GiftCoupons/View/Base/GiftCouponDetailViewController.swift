//
//  PurchaseDetailViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 29/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
protocol GiftCouponDetailViewControllerDelegate: class {
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, deletedGiftCoupon giftCoupon: PlanItGiftCoupon)
    func giftCouponDetailViewController(_ viewController: GiftCouponDetailViewController, updatedGiftCoupon giftCoupon: PlanItGiftCoupon)
}

class GiftCouponDetailViewController: UIViewController {
    var isModified = false
    var planItGiftCoupon: PlanItGiftCoupon!
    weak var delegate: GiftCouponDetailViewControllerDelegate?
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelBillDate: UILabel!
    @IBOutlet weak var labelCouponName: UILabel!
    @IBOutlet weak var labelCouponCode: UILabel!
    @IBOutlet weak var labelCouponID: UILabel!
    @IBOutlet weak var labelReceivedFrom: UILabel!
    @IBOutlet weak var labelIssuedBy: UILabel!
    @IBOutlet weak var buttonRedeem: ProcessingButton!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var buttonDelete: ProcessingButton!
    @IBOutlet weak var labelCategory: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isModified {
            self.delegate?.giftCouponDetailViewController(self, updatedGiftCoupon: self.planItGiftCoupon)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func appShareButtonClicked(_ sender: UIButton) {
        self.appShareGiftCard()
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.deleteGiftCoupon()
    }
    
    
    @IBAction func attachmentsButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toAttachments, sender: self)
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.toAddGiftCoupon, sender: self)
    }
    
    @IBAction func markAsRedeemButtonaTapped(_ sender: ProcessingButton) {
        self.markAsRedeem()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is AddGiftCouponsViewController:
            let editGiftCouponsViewController =  segue.destination as! AddGiftCouponsViewController
            editGiftCouponsViewController.giftCouponModel = GiftCoupon(with: self.planItGiftCoupon)
            editGiftCouponsViewController.delegate = self
        case is AttachmentListViewController:
            let attachmentListViewController =  segue.destination as! AttachmentListViewController
            attachmentListViewController.activityType = .none
            let ownerIdValue = self.planItGiftCoupon.createdBy?.readValueOfUserId()
            attachmentListViewController.attachments = self.planItGiftCoupon.readAllAttachments().map({ return UserAttachment(with: $0, type: .giftCoupon, ownerId: ownerIdValue) })
            attachmentListViewController.itemOwnerId = ownerIdValue
        case is AddGiftTagViewController:
            let addGiftTagViewController = segue.destination as! AddGiftTagViewController
            addGiftTagViewController.tags = self.planItGiftCoupon.readAllTags().compactMap({ $0.tag })
            addGiftTagViewController.canAddTag = false
        default:
            break
        }
    }
}
