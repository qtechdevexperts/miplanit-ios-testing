//
//  AddPurchaseViewController.swift
//  MiPlanIt
//
//  Created by Aneesh Asokan on 30/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit
import Lottie
import Speech

@objc protocol AddPurchaseViewControllerDelegate: class {
    @objc optional func addPurchaseViewController(_ viewController: AddPurchaseViewController, createdNewPurchase purchase: PlanItPurchase)
    @objc optional func addPurchaseViewController(_ viewController: AddPurchaseViewController, updatedPurchase purchase: PlanItPurchase)
}

class AddPurchaseViewController: UIViewController {
    
    var purchaseModel: Purchase = Purchase()
    weak var delegate: AddPurchaseViewControllerDelegate?
    
    var activeTextField: UITextField?
    
    @IBOutlet weak var labelHeaderCaption: UILabel!
    @IBOutlet var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var textFieldLocation: FloatingTextField!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBOutlet weak var labelBillDate: UILabel!
    @IBOutlet weak var txtfldProductName: FloatingTextField!
    @IBOutlet weak var txtfldStoreName: FloatingTextField!
    @IBOutlet weak var txtfldPrice: FloatingTextField!
    @IBOutlet weak var buttonPaymentType: UIButton!
    @IBOutlet weak var buttonSavePurchase: ProcessingButton!
    @IBOutlet weak var labelAttachmentCount: UILabel!
    @IBOutlet weak var labelBillDateError: UILabel!
    @IBOutlet weak var viewBillBorder: UIView!
    @IBOutlet weak var labelTagCount: UILabel!
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonDoneBillDate: UIButton!
    @IBOutlet weak var buttonPurchaseType: UIButton!
    @IBOutlet weak var buttonCurrencySymbol: UIButton!
    @IBOutlet weak var dayDatePicker: DayDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialiseUIComponents()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func locationValueChanged(_ sender: UITextField) {
        if let location = sender.text, location.isEmpty {
            self.purchaseModel.resetLocation()
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if self.validateInputFields() {
            self.savePurchaseToServerUsingNetwotk()
        }
    }
    
    @IBAction func geoLocationButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.goToMap, sender: nil)
    }
    
    @IBAction func attachButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Segues.toProfileDropDown, sender: self)
    }
    
    @IBAction func datePickerChanger(_ sender: UIDatePicker) {
        self.updateDateChanged(sender.date)
    }
    
    
    @IBAction func toggleCalendarClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewDatePicker.isHidden = !self.viewDatePicker.isHidden
        if !self.viewDatePicker.isHidden, let stringDate = labelBillDate.text {
//            self.datePicker.setDate(stringDate.toDateStrimg(withFormat: DateFormatters.EEEEMMMDDYYYY) ?? Date(), animated: false)
            self.dayDatePicker?.selectRow(self.dayDatePicker?.selectedDate(date: stringDate.toDateStrimg(withFormat: DateFormatters.EEEEMMMDDYYYY) ?? Date()) ?? 0, inComponent: 0, animated: true)
            self.labelBillDate.text = self.datePicker.date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
            self.purchaseModel.setBiilDate(date: self.datePicker.date)
            self.disableBillError()
        }
//        self.buttonDoneBillDate.isHidden = self.viewDatePicker.isHidden
    }
    
    @IBAction func discriptionClicked(_ sender: UIButton) {
        self.textViewDescription.becomeFirstResponder()
    }
    
    @IBAction func billDateDoneClicked(_ sender: UIButton) {
        self.purchaseModel.setBiilDate(date: self.datePicker.date)
        self.labelBillDate.text = self.datePicker.date.stringFromDate(format: DateFormatters.EEEEMMMDDYYYY)
        self.disableBillError()
        self.viewDatePicker.isHidden = true
//        self.buttonDoneBillDate.isHidden = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        switch segue.destination {
        case is MessageViewController:
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.caption = (sender as? [String])?.first
            messageViewController.errorDescription = (sender as? [String])?.last
        case is AttachFileDropDownViewController:
            let attachDropDownViewController = segue.destination as! AttachFileDropDownViewController
            attachDropDownViewController.delegate = self
            attachDropDownViewController.countofAttachments = self.purchaseModel.getAttachmentCount()
        case is PaymentTypeViewController:
            let paymentTypeViewController = segue.destination as! PaymentTypeViewController
            paymentTypeViewController.delegate = self
            paymentTypeViewController.selectedPayment = self.purchaseModel.paymentTypeId
            paymentTypeViewController.selctedCard = self.purchaseModel.paymentCard
            paymentTypeViewController.paymentDescription = self.purchaseModel.paymentDescription
        case is AttachmentListViewController:
            let attachmentListViewController = segue.destination as! AttachmentListViewController
            attachmentListViewController.delegate = self
            attachmentListViewController.attachments = self.purchaseModel.attachments
            attachmentListViewController.activityType = .purchase
            attachmentListViewController.itemOwnerId = self.purchaseModel.planItPurchase?.createdBy?.readValueOfUserId()
        case is AddPurchaseTagViewController:
            let addPurchaseTagViewController = segue.destination as! AddPurchaseTagViewController
            addPurchaseTagViewController.tags = self.purchaseModel.tags
            addPurchaseTagViewController.delegate = self
            addPurchaseTagViewController.textToPredict = self.purchaseModel.createTextForPrediction()
            addPurchaseTagViewController.defaultTags = self.purchaseModel.categoryTag().map({ PredictionTag(with: $0) })
        case is CommonMapViewController:
            let commonMapViewController = segue.destination as! CommonMapViewController
            commonMapViewController.delegate = self
            commonMapViewController.selectedLocation = (self.purchaseModel.location, self.purchaseModel.placeLatitude, self.purchaseModel.placeLongitude)
        case is PurchaseTypeDropDownViewController:
            let purchaseTypeDropDownViewController = segue.destination as! PurchaseTypeDropDownViewController
            purchaseTypeDropDownViewController.delegate = self
        case is CurrencyCodeViewController:
            let currencyCodeViewController = segue.destination as! CurrencyCodeViewController
            currencyCodeViewController.delegate = self
        default:
            break
        }
    }
}
