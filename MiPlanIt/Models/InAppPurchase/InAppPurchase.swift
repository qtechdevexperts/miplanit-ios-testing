//
//  Purchase.swift
//  BookReader
//
//  Created by Richin.C on 22/10/18.
//  Copyright © 2018 ARUN. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchase: NSObject, SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate {
    
    var receiptRequestType: PurchaseRequestType = .none
    var purchaseType: PurchseType = .none
    var purchaseIdentifier: String?
    var priceResult: ((SKProduct?, String?, String?, String?)->())?
    var purchaseResult: ((Bool?, Date?, Bool?, String?) -> ())?
    var autoSyncRenewResult: ((Bool?, Date?, Bool?, String?) -> ())?
    var purchasePrice = Strings.empty
    var currencyFormat = Strings.empty
    
    static let shared = InAppPurchase()
    
    enum PurchaseFailedStatus: String {
        case itunesFailed = "Itunes Service Failed"
        case paymentCancelled = "Payment Cancelled"
        case failedTransaction = "Failed Transaction"
        case receiptError = "Receipt Error"
    }
    
    func addPaymentObserver() {
       SKPaymentQueue.default().add(self)
    }
    
//    func removePaymentObserver() {
//        SKPaymentQueue.default().remove(self)
//    }
    
    //MARK: - Purchase
    func completed(purchase: Bool, recieptExpiryDate: Date?, transactionIdExist: Bool?, with error: String?) {
        self.purchaseType = .none
        self.receiptRequestType = .none
        self.purchaseIdentifier = nil
        self.purchaseResult?(purchase, recieptExpiryDate, transactionIdExist, error)
        if self.purchaseResult == nil {
            self.autoSyncRenewResult?(purchase, recieptExpiryDate, transactionIdExist, error)
        }
        if self.priceResult != nil {
            self.priceResult?(nil, nil, nil, error)
        }
        self.priceResult = nil
        self.purchaseResult = nil
        self.purchaseIdentifier = nil
        self.purchasePrice = Strings.empty
        self.currencyFormat = Strings.empty
    }
    
    func doSuddenAutoRenewSubscription(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.autoSyncRenewResult = result
    }
    
    
    //MARK: Refresh Reciept
    func refreshPurchaseRecieptFromStore(type: PurchaseRequestType) {
        self.receiptRequestType = type
        let refreshRequest = SKReceiptRefreshRequest()
        refreshRequest.delegate = self
        refreshRequest.start()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if self.isObtainedReceipt() {
            self.sendCompletedTransaction()
        }
        else {
            self.sendFailedTransaction()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.sendFailedItunesStatusToServer(with: error.localizedDescription)
    }
    
    func isObtainedReceipt() -> Bool {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL?.path, FileManager.default.fileExists(atPath: receiptUrl) else { return false }
        return true
    }
    
    //MARK:- Price
    func itunesPricingModel(result: @escaping (SKProduct?, String?, String?, String?)->()) {
        self.priceResult = result
        let prodRequest = SKProductsRequest(productIdentifiers: ConfigureKeys.productIdentifiers)
        prodRequest.delegate = self
        prodRequest.start()
    }
    func itunesPricingModelMonthly(result: @escaping (SKProduct?, String?, String?, String?)->()) {
        self.priceResult = result
        let prodRequest = SKProductsRequest(productIdentifiers: ConfigureKeys.productIdentifiersMonthly)
        prodRequest.delegate = self
        prodRequest.start()
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var formattedPrice = Strings.empty
        var currencyType = Strings.empty
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        var product: SKProduct?
        for result in response.products {
            product = result
            formattedPrice = "\(result.price)"
            currencyType = result.priceLocale.currencyCode!
            break
        }
        self.priceResult?(product, formattedPrice, currencyType, nil)
        self.priceResult = nil

    }
    
    
    //MARK:- Restore Purchase
    func restoreInAppPurchase(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseType = .restore
        self.purchaseResult = result
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if isObtainedReceipt() {
            self.verifyRestoreReciept()
        }
        else {
            self.refreshPurchaseRecieptFromStore(type: .new)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.inCompleteWithErrorMessage(error.localizedDescription)
    }
    
    func verifyRestoreReciept() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyRestoreDataWithItunes(recieptData)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    func verifyAppstoreRestoreDataWithServer(_ data: Data) {
        self.verifyAppstoreDataWithServer(data)
    }
    
    //MARK:- InApp Purchase
    func purchaseProduct(_ product: SKProduct, format: String, result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.currencyFormat = format
        self.purchaseType = .purchase
        self.purchaseResult = result
        self.startPaymentProcess(skProduct: product)
    }
    
    func startPaymentProcess(skProduct: SKProduct) {
        let payment = SKPayment(product: skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
              self.complete(transaction: transaction, with: true)
              break
            case .failed:
              self.complete(transaction: transaction, with: false)
              break
            case .restored:
                self.finishedTransaction(transaction)
//                self.complete(transaction: transaction, with: true)
              break
            case .deferred:
              debugPrint("deferred")
            case .purchasing:
              break
            @unknown default:
                break
            }
        }
    }
    
    func finishedTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func complete(transaction: SKPaymentTransaction, with result: Bool) {
        self.finishedTransaction(transaction)
        if result {
            if isObtainedReceipt() {
                self.sendCompletedTransaction()
            }
            else {
                self.refreshPurchaseRecieptFromStore(type: .new)
            }
        }
        else {
            self.sendFailedTransactionState(transaction: transaction)
        }
    }
    
    func sendCompletedTransaction() {
        switch self.purchaseType {
        case .purchase:
            self.verifyReciept()
        case .restore:
            self.verifyRestoreReciept()
        default:
            break
        }
    }
    
    func sendFailedTransaction() {
        switch self.purchaseType {
        case .purchase:
            self.inCompleteWithErrorStatus(.failedTransaction)
        case .restore:
            self.inCompleteWithErrorStatus(.failedTransaction)
        default:
            break
        }
    }
    
    func sendFailedTransactionState(transaction: SKPaymentTransaction) {
        switch self.purchaseType {
        case .purchase:
            self.failedTransaction(transaction)
        case .restore:
            self.inCompleteWithErrorStatus(.failedTransaction)
        default:
            break
        }
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        guard let errror = transaction.error as? SKError else {
            self.inCompleteWithErrorStatus(.failedTransaction)
            return
        }
        if errror.code == .paymentCancelled {
            self.inCompleteWithErrorStatus(.paymentCancelled)
        }
        else {
            self.inCompleteWithErrorStatus(.failedTransaction)
        }
    }
    
    func inCompleteWithErrorStatus(_ status: PurchaseFailedStatus) {
        self.completed(purchase: false, recieptExpiryDate: nil, transactionIdExist: false, with: status.rawValue)
    }
    
    func inCompleteWithErrorMessage(_ message: String) {
        self.completed(purchase: false, recieptExpiryDate: nil, transactionIdExist: false, with: message)
    }
    
    func verifyReciept() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyRestoreDataWithItunes(recieptData)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    func verifyAppstoreDataWithServer(_ data: Data, switchReciept flag: Bool = false) {
        guard let user = Session.shared.readUser() else {
            self.inCompleteWithErrorStatus(.failedTransaction)
            return
        }
        InAppPurchaseService().verifyRecieptDataWithServer(data: data, user: user, switchReciept: flag) { (expiryData, transactionIdExist, error) in
            if transactionIdExist {
                self.completed(purchase: true, recieptExpiryDate: nil, transactionIdExist: true, with: nil)
            }
            else {
                if let date = expiryData {
                    self.completed(purchase: true, recieptExpiryDate: date, transactionIdExist: false, with: nil)
                }
                else {
                    self.inCompleteWithErrorMessage(error ?? Strings.empty)
                }
            }
        }
    }
    
    func switchTransactionReceipt(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseResult = result
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyAppstoreDataWithServer(recieptData, switchReciept: true)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    //MARK:- Verify Purchase Reciept
    func verifyAppReceipt(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseResult = result
        self.verifyReciept()
    }
    
    //MARK:- iTunes  Validation
    func verifyRestoreDataWithItunes(_ data: Data) {
        InAppPurchaseService().verifyRecieptDataWithItunes(data: data, callback: { response, error in
            if let result = response {
                if result.status != .failed {
                    if result.status == .success {
                        self.sendSuccessItunesStatusToServer(with: data)
                    }
                    else {
                        if self.receiptRequestType != .expired {
                            self.refreshPurchaseRecieptFromStore(type: .expired)
                        }
                        else {
                            self.sendFailedItunesStatusToServer(with: Message.restoreSubscriptionFailed)
                        }
                    }
                }
                else {
                    self.sendFailedItunesStatusToServer(with: result.error)
                }
            }
            else {
                self.sendFailedItunesStatusToServer(with: error?.message)
            }
        })
    }
    
    func sendSuccessItunesStatusToServer(with data: Data) {
        if self.purchaseType == .purchase {
            self.verifyAppstoreDataWithServer(data)
        }
        else {
            self.verifyAppstoreRestoreDataWithServer(data)
        }
    }
    
    func sendFailedItunesStatusToServer(with message: String?) {
        if self.purchaseType == .restore {
            self.inCompleteWithErrorMessage(message ?? Strings.empty)
        }
        else {
            self.inCompleteWithErrorStatus(.itunesFailed)
        }
    }
}
//
//  Purchase.swift
//  BookReader
//
//  Created by Richin.C on 22/10/18.
//  Copyright © 2018 ARUN. All rights reserved.
//


class InAppPurchase2: NSObject, SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate {
    
    var receiptRequestType: PurchaseRequestType = .none
    var purchaseType: PurchseType = .none
    var purchaseIdentifier: String?
    var priceResult: ((SKProduct?, String?, String?, String?)->())?
    var purchaseResult: ((Bool?, Date?, Bool?, String?) -> ())?
    var autoSyncRenewResult: ((Bool?, Date?, Bool?, String?) -> ())?
    var purchasePrice = Strings.empty
    var currencyFormat = Strings.empty
    
    static let shared = InAppPurchase()
    
    enum PurchaseFailedStatus: String {
        case itunesFailed = "Itunes Service Failed"
        case paymentCancelled = "Payment Cancelled"
        case failedTransaction = "Failed Transaction"
        case receiptError = "Receipt Error"
    }
    
    func addPaymentObserver() {
       SKPaymentQueue.default().add(self)
    }
    
//    func removePaymentObserver() {
//        SKPaymentQueue.default().remove(self)
//    }
    
    //MARK: - Purchase
    func completed(purchase: Bool, recieptExpiryDate: Date?, transactionIdExist: Bool?, with error: String?) {
        self.purchaseType = .none
        self.receiptRequestType = .none
        self.purchaseIdentifier = nil
        self.purchaseResult?(purchase, recieptExpiryDate, transactionIdExist, error)
        if self.purchaseResult == nil {
            self.autoSyncRenewResult?(purchase, recieptExpiryDate, transactionIdExist, error)
        }
        if self.priceResult != nil {
            self.priceResult?(nil, nil, nil, error)
        }
        self.priceResult = nil
        self.purchaseResult = nil
        self.purchaseIdentifier = nil
        self.purchasePrice = Strings.empty
        self.currencyFormat = Strings.empty
    }
    
    func doSuddenAutoRenewSubscription(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.autoSyncRenewResult = result
    }
    
    
    //MARK: Refresh Reciept
    func refreshPurchaseRecieptFromStore(type: PurchaseRequestType) {
        self.receiptRequestType = type
        let refreshRequest = SKReceiptRefreshRequest()
        refreshRequest.delegate = self
        refreshRequest.start()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if self.isObtainedReceipt() {
            self.sendCompletedTransaction()
        }
        else {
            self.sendFailedTransaction()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.sendFailedItunesStatusToServer(with: error.localizedDescription)
    }
    
    func isObtainedReceipt() -> Bool {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL?.path, FileManager.default.fileExists(atPath: receiptUrl) else { return false }
        return true
    }
    
    //MARK:- Price
    func itunesPricingModel(result: @escaping (SKProduct?, String?, String?, String?)->()) {
        self.priceResult = result
        let prodRequest = SKProductsRequest(productIdentifiers: ConfigureKeys.productIdentifiers)
        prodRequest.delegate = self
        prodRequest.start()
    }
    func itunesPricingModelMonthly(result: @escaping (SKProduct?, String?, String?, String?)->()) {
        self.priceResult = result
        let prodRequest = SKProductsRequest(productIdentifiers: ConfigureKeys.productIdentifiersMonthly)
        prodRequest.delegate = self
        prodRequest.start()
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var formattedPrice = Strings.empty
        var currencyType = Strings.empty
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        var product: SKProduct?
        for result in response.products {
            product = result
            formattedPrice = "\(result.price)"
            currencyType = result.priceLocale.currencyCode!
            break
        }
        self.priceResult?(product, formattedPrice, currencyType, nil)
        self.priceResult = nil

    }
    
    
    //MARK:- Restore Purchase
    func restoreInAppPurchase(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseType = .restore
        self.purchaseResult = result
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if isObtainedReceipt() {
            self.verifyRestoreReciept()
        }
        else {
            self.refreshPurchaseRecieptFromStore(type: .new)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.inCompleteWithErrorMessage(error.localizedDescription)
    }
    
    func verifyRestoreReciept() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyRestoreDataWithItunes(recieptData)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    func verifyAppstoreRestoreDataWithServer(_ data: Data) {
        self.verifyAppstoreDataWithServer(data)
    }
    
    //MARK:- InApp Purchase
    func purchaseProduct(_ product: SKProduct, format: String, result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.currencyFormat = format
        self.purchaseType = .purchase
        self.purchaseResult = result
        self.startPaymentProcess(skProduct: product)
    }
    
    func startPaymentProcess(skProduct: SKProduct) {
        let payment = SKPayment(product: skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
              self.complete(transaction: transaction, with: true)
              break
            case .failed:
              self.complete(transaction: transaction, with: false)
              break
            case .restored:
                self.finishedTransaction(transaction)
//                self.complete(transaction: transaction, with: true)
              break
            case .deferred:
              debugPrint("deferred")
            case .purchasing:
              break
            @unknown default:
                break
            }
        }
    }
    
    func finishedTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func complete(transaction: SKPaymentTransaction, with result: Bool) {
        self.finishedTransaction(transaction)
        if result {
            if isObtainedReceipt() {
                self.sendCompletedTransaction()
            }
            else {
                self.refreshPurchaseRecieptFromStore(type: .new)
            }
        }
        else {
            self.sendFailedTransactionState(transaction: transaction)
        }
    }
    
    func sendCompletedTransaction() {
        switch self.purchaseType {
        case .purchase:
            self.verifyReciept()
        case .restore:
            self.verifyRestoreReciept()
        default:
            break
        }
    }
    
    func sendFailedTransaction() {
        switch self.purchaseType {
        case .purchase:
            self.inCompleteWithErrorStatus(.failedTransaction)
        case .restore:
            self.inCompleteWithErrorStatus(.failedTransaction)
        default:
            break
        }
    }
    
    func sendFailedTransactionState(transaction: SKPaymentTransaction) {
        switch self.purchaseType {
        case .purchase:
            self.failedTransaction(transaction)
        case .restore:
            self.inCompleteWithErrorStatus(.failedTransaction)
        default:
            break
        }
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        guard let errror = transaction.error as? SKError else {
            self.inCompleteWithErrorStatus(.failedTransaction)
            return
        }
        if errror.code == .paymentCancelled {
            self.inCompleteWithErrorStatus(.paymentCancelled)
        }
        else {
            self.inCompleteWithErrorStatus(.failedTransaction)
        }
    }
    
    func inCompleteWithErrorStatus(_ status: PurchaseFailedStatus) {
        self.completed(purchase: false, recieptExpiryDate: nil, transactionIdExist: false, with: status.rawValue)
    }
    
    func inCompleteWithErrorMessage(_ message: String) {
        self.completed(purchase: false, recieptExpiryDate: nil, transactionIdExist: false, with: message)
    }
    
    func verifyReciept() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyRestoreDataWithItunes(recieptData)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    func verifyAppstoreDataWithServer(_ data: Data, switchReciept flag: Bool = false) {
        guard let user = Session.shared.readUser() else {
            self.inCompleteWithErrorStatus(.failedTransaction)
            return
        }
        InAppPurchaseService().verifyRecieptDataWithServer(data: data, user: user, switchReciept: flag) { (expiryData, transactionIdExist, error) in
            if transactionIdExist {
                self.completed(purchase: true, recieptExpiryDate: nil, transactionIdExist: true, with: nil)
            }
            else {
                if let date = expiryData {
                    self.completed(purchase: true, recieptExpiryDate: date, transactionIdExist: false, with: nil)
                }
                else {
                    self.inCompleteWithErrorMessage(error ?? Strings.empty)
                }
            }
        }
    }
    
    func switchTransactionReceipt(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseResult = result
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            do {
                let recieptData = try Data(contentsOf: appStoreReceiptURL)
                self.verifyAppstoreDataWithServer(recieptData, switchReciept: true)
            } catch {
                self.inCompleteWithErrorMessage(error.localizedDescription)
            }
        }
        else {
            self.inCompleteWithErrorStatus(.receiptError)
        }
    }
    
    //MARK:- Verify Purchase Reciept
    func verifyAppReceipt(result: @escaping (Bool?, Date?, Bool?, String?) -> ()) {
        self.purchaseResult = result
        self.verifyReciept()
    }
    
    //MARK:- iTunes  Validation
    func verifyRestoreDataWithItunes(_ data: Data) {
        InAppPurchaseService().verifyRecieptDataWithItunes(data: data, callback: { response, error in
            if let result = response {
                if result.status != .failed {
                    if result.status == .success {
                        self.sendSuccessItunesStatusToServer(with: data)
                    }
                    else {
                        if self.receiptRequestType != .expired {
                            self.refreshPurchaseRecieptFromStore(type: .expired)
                        }
                        else {
                            self.sendFailedItunesStatusToServer(with: Message.restoreSubscriptionFailed)
                        }
                    }
                }
                else {
                    self.sendFailedItunesStatusToServer(with: result.error)
                }
            }
            else {
                self.sendFailedItunesStatusToServer(with: error?.message)
            }
        })
    }
    
    func sendSuccessItunesStatusToServer(with data: Data) {
        if self.purchaseType == .purchase {
            self.verifyAppstoreDataWithServer(data)
        }
        else {
            self.verifyAppstoreRestoreDataWithServer(data)
        }
    }
    
    func sendFailedItunesStatusToServer(with message: String?) {
        if self.purchaseType == .restore {
            self.inCompleteWithErrorMessage(message ?? Strings.empty)
        }
        else {
            self.inCompleteWithErrorStatus(.itunesFailed)
        }
    }
}
