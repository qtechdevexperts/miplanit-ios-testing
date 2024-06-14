//
//  AddGiftCouponsViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie

@objc protocol AddGiftCouponsViewControllerDelegate: class {
    @objc optional func addGiftCouponsViewController(_ viewController: AddGiftCouponsViewController, createdNewGiftCoupon giftCoupon: PlanItGiftCoupon)
    @objc optional func addGiftCouponsViewController(_ viewController: AddGiftCouponsViewController, updatedGiftCoupon giftCoupon: PlanItGiftCoupon)
}

class AddGiftCouponsViewController: UIViewController {
    
    var giftCouponModel = GiftCoupon()
    weak var delegate: AddGiftCouponsViewControllerDelegate?
    @IBOutlet weak var labelHeaderCaption: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var labelBillDate: UILabel!
    @IBOutlet weak var buttonSaveGiftCoupon: ProcessingButton!
    @IBOutlet weak var txtfldCouponName: FloatingTextField!
    @IBOutlet weak var txtfldCouponCode: FloatingTextField!
    @IBOutlet weak var txtfldCouponID: FloatingTextField!
    @IBOutlet weak var txtfldReceivedFrom: FloatingTextField!
    @IBOutlet weak var txtfldIssuedBy: FloatingTextField!
    @IBOutlet weak var txtfldAmount: FloatingTextField!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var labelBillDateError: UILabel!
    @IBOutlet weak var viewBillBorder: UIView!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonDoneExpiryDate: UIButton!
    @IBOutlet weak var buttonGiftType: UIButton!
    @IBOutlet weak var buttonCurrencySymbol: UIButton!
    @IBOutlet weak var dayDatePicker: DayDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtfldCouponID.delegate = self
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if self.validateInputFields() {
            self.saveGiftCouponToServerUsingNetwotk(self.giftCouponModel)
        }
    }
    
    @IBAction func attachButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.giftCouponModel.setExpiryDate(date: self.datePicker.date)
        self.labelBillDate.text = self.datePicker.date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
    }
    
    @IBAction func toggleCalendarClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewDatePicker.isHidden = !self.viewDatePicker.isHidden
        if !self.viewDatePicker.isHidden, let stringDate = labelBillDate.text {
//            self.datePicker.setDate(stringDate.toDateStrimg(withFormat: DateFormatters.EEEEMMMDDYYYY) ?? Date(), animated: false)
            self.dayDatePicker?.selectRow(self.dayDatePicker?.selectedDate(date: stringDate.toDateStrimg(withFormat: DateFormatters.EEEEMMMDDYYYY) ?? Date()) ?? 0, inComponent: 0, animated: true)
            self.labelBillDate.text = self.datePicker.date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
            self.giftCouponModel.setExpiryDate(date: self.datePicker.date)
        }
//        self.buttonDoneExpiryDate.isHidden = self.viewDatePicker.isHidden
    }
    
    @IBAction func descriptionButtonCicked(_ sender: UIButton) {
        self.textViewDescription.becomeFirstResponder()
    }
    
    @IBAction func billDateDoneClicked(_ sender: UIButton) {
        self.giftCouponModel.setExpiryDate(date: self.datePicker.date)
        self.labelBillDate.text = self.datePicker.date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
        self.viewBillBorder.backgroundColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        self.labelBillDateError.isHidden = true
        self.viewDatePicker.isHidden = true
//        self.buttonDoneExpiryDate.isHidden = true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
            case is AttachFileDropDownViewController:
            let attachDropDownViewController = segue.destination as? AttachFileDropDownViewController
            attachDropDownViewController?.delegate = self
            attachDropDownViewController?.countofAttachments = self.giftCouponModel.getAttachmentCount()
        case is AttachmentListViewController:
            let attachmentListViewController = segue.destination as! AttachmentListViewController
            attachmentListViewController.delegate = self
            attachmentListViewController.activityType = .giftCoupon
            attachmentListViewController.attachments = self.giftCouponModel.attachments
            attachmentListViewController.itemOwnerId = self.giftCouponModel.giftOwnerId
        case is AddGiftTagViewController:
            let addGiftTagViewController = segue.destination as! AddGiftTagViewController
            addGiftTagViewController.tags = self.giftCouponModel.tags
            addGiftTagViewController.textToPredict = self.giftCouponModel.createTextForPrediction()
            addGiftTagViewController.delegate = self
        case is GiftTypeDropDownViewController:
            let giftTypeDropDownViewController = segue.destination as! GiftTypeDropDownViewController
            giftTypeDropDownViewController.delegate = self
        case is CurrencyCodeViewController:
            let currencyCodeViewController = segue.destination as! CurrencyCodeViewController
            currencyCodeViewController.delegate = self
        default: break
        }
    }
}
