//
//  UpgradeHandler.swift
//  Sudoku3D
//
//  Created by Reid on 2018-12-29.
//  Copyright © 2018 Reid. All rights reserved.
//

import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ product: SKProduct?) -> Void

open class UpgradeHandler: NSObject  {
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()

    private var productRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var product : SKProduct?
    private var initCompleteHandler : (() -> Void)
    private var titleNode : TitleNode

    init(completion : @escaping () -> Void, titleNode: TitleNode) {
        initCompleteHandler = completion
        self.titleNode = titleNode
        super.init()
        SKPaymentQueue.default().add(self)
        requestProducts(completedProductRequest)
    }
    
    public func getPaymentAlertInfo() -> (Bool,String) {
        if UserDefaults.standard.bool(forKey: "hasPaid") {
            return (false, "You've already paid, let me update that for you!")
        }
        if let product = self.product {
            if UpgradeHandler.canMakePayments() {
                return (true, Constants.Scripts.upgrade + "\n" + UpgradeHandler.priceFormatter.string(from: product.price)!)
            } else {
                return (false, Constants.Scripts.cantPay)
            }
        } else {
            return (false, Constants.Scripts.noProductsAvailable)
        }
    }

    public func completedProductRequest(success:Bool, product:SKProduct?) {
        restorePurchases()
        if success {
            self.product = product
        }
    }
}

// MARK: - StoreKit API

extension UpgradeHandler {
    
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productRequest = SKProductsRequest(productIdentifiers: [Constants.AppStore.ProductShort])
        productRequest!.delegate = self
        productRequest!.start()
    }
    
    public func buyProduct() {
        let payment = SKPayment(product: product!)
        SKPaymentQueue.default().add(payment)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension UpgradeHandler: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if products.count == 1 {
            productsRequestCompletionHandler?(true, products[0])
        }
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension UpgradeHandler: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count != 0 {
            UserDefaults.standard.set(true, forKey: "hasPaid")
        }
        if UserDefaults.standard.integer(forKey: "highestLevel") == 6 && UserDefaults.standard.bool(forKey: "beatLevel6") {
            UserDefaults.standard.set(7, forKey: "highestLevel")
            titleNode.setAccessible(level: 7, isAccessible: true)
        }
        initCompleteHandler()
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotification()
        if UserDefaults.standard.integer(forKey: "highestLevel") == 6 && UserDefaults.standard.bool(forKey: "beatLevel6") {
            UserDefaults.standard.set(7, forKey: "highestLevel")
            titleNode.setAccessible(level: 7, isAccessible: true)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        UserDefaults.standard.set(true, forKey: "hasPaid")
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        if transaction.original?.payment.productIdentifier == nil { return }
        deliverPurchaseNotification()
        SKPaymentQueue.default().finishTransaction(transaction)
        UserDefaults.standard.set(true, forKey: "hasPaid")
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotification() {
        NotificationCenter.default.post(Notification(name: NSNotification.Name("Upgrade:Sudoku3D")))
    }
}
