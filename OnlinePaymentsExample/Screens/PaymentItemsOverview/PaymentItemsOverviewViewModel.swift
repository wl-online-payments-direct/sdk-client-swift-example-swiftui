//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import OnlinePaymentsKit
import Foundation
import PassKit
import SwiftUI

extension PaymentItemsOverviewScreen {

    class ViewModel: NSObject, ObservableObject, PKPaymentAuthorizationViewControllerDelegate {

        // MARK: - Properties
        @Published var paymentProductRows: [PaymentProductRow] = []
        @Published var accountOnFileRows: [PaymentProductRow] = []
        @Published var showSuccessScreen: Bool = false
        @Published var showBottomSheet: Bool = false
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var infoText: String = ""
        @Published var showCardProductScreen: Bool = false

        private var applePayPaymentProduct: PaymentProduct?
        private var summaryItems: [PKPaymentSummaryItem] = []
        private var authorizationViewController: PKPaymentAuthorizationViewController?

        var selectedPaymentItem: PaymentItem?
        var selectedAccountOnFile: AccountOnFile?
        var hasAccountsOnFile: Bool = false
        var preparedPaymentRequest: PreparedPaymentRequest?

        let session: Session
        let paymentContext: PaymentContext

        // MARK: - Init
        init(session: Session, paymentContext: PaymentContext, paymentItems: PaymentItems) {
            self.session = session
            self.paymentContext = paymentContext
            self.hasAccountsOnFile = paymentItems.hasAccountsOnFile

            super.init()

            prepareItems(paymentItems: paymentItems)
        }

        // MARK: - Helpers
        func didSelect(item: PaymentProductRow, isAccountOnFile: Bool) {
            // ***************************************************************************
            //
            // After selecting a payment product or an account on file associated to a
            // payment product in the payment product selection screen, the Session
            // object is used to retrieve all information for this payment product.
            //
            // Afterwards, a screen is shown that allows the user to fill in all
            // relevant information, unless the payment product has no fields.
            // This screen is also not part of the SDK and is offered for demonstration
            // purposes only.
            //
            // If the payment product has no fields, the merchant is responsible for
            // fetching the URL for a redirect to a third party and show the corresponding
            // website.
            //
            // ***************************************************************************

            isLoading = true

            session.paymentProduct(
                withId: item.paymentProductIdentifier,
                context: paymentContext,
                success: { paymentProduct in
                    if item.paymentProductIdentifier.isEqual(AppConstants.applePayIdentifier) {
                        self.isLoading = false
                        self.showApplePayPaymentItem(paymentProduct: paymentProduct)
                    } else {
                        self.isLoading = false

                        if paymentProduct.fields.paymentProductFields.count > 0 {
                            self.selectedAccountOnFile =
                                isAccountOnFile ?
                                    paymentProduct.accountOnFile(withIdentifier: item.accountOnFileIdentifier ?? "") :
                                    nil
                            self.selectedPaymentItem = paymentProduct
                            self.show(paymentItem: paymentProduct)
                        } else {
                            self.showBottomSheet(text: "ProductNotAvailable".localized)
                        }
                    }
                },
                failure: { error in
                    self.showAlert(text: error.localizedDescription)
                    self.isLoading = false
                },
                apiFailure: { errorResponse in
                    self.showAlert(text: errorResponse.message)
                    self.isLoading = false
                }
            )
        }

        private func show(paymentItem: PaymentItem) {
            if (paymentItem as? PaymentProduct)?.paymentMethod == "card" {
                self.showCardProductScreen = true
            } else {
                self.showBottomSheet(text: "ProductNotAvailable".localized)
            }
        }

        private func prepareItems(paymentItems: PaymentItems) {
            if hasAccountsOnFile {
                self.accountOnFileRows =
                    generateRowsFrom(accountsOnFile: paymentItems.accountsOnFile, paymentItems: paymentItems)
            }
            self.paymentProductRows = generateRowsFrom(paymentItems: paymentItems)
        }

        private func generateRowsFrom(paymentItems: PaymentItems) -> [PaymentProductRow] {
            var items: [PaymentProductRow] = []

            for paymentItem in paymentItems.paymentItems.sorted(by: { paymentItemA, paymentItemB in
                return paymentItemA.displayHintsList[0].displayOrder <
                    paymentItemB.displayHintsList[0].displayOrder
            }) {
                let paymentProductLabel = paymentItem.displayHintsList[0].label ?? "UnknownProductLabel".localized
                let row = PaymentProductRow(name: paymentProductLabel,
                                             accountOnFileIdentifier: "",
                                             paymentProductIdentifier: paymentItem.identifier,
                                             logo: paymentItem.displayHintsList[0].logoImage)
                items.append(row)

            }
            return items
        }

        private func generateRowsFrom(
            accountsOnFile: [AccountOnFile],
            paymentItems: PaymentItems
        ) -> [PaymentProductRow] {
            var items: [PaymentProductRow] = []

            for accountOnFile in accountsOnFile.sorted(by: { (accountOnFileA, accountOnFileB) -> Bool in
                let paymentItemA =
                    paymentItems.paymentItem(
                        withIdentifier: accountOnFileA.paymentProductIdentifier
                    )?.displayHintsList[0].displayOrder ?? Int.max
                let paymentItemB =
                    paymentItems.paymentItem(
                        withIdentifier: accountOnFileB.paymentProductIdentifier
                    )?.displayHintsList[0].displayOrder ?? Int.max

                return paymentItemA < paymentItemB
            }) {

                if let product = paymentItems.paymentItem(withIdentifier: accountOnFile.paymentProductIdentifier) {
                    let row = PaymentProductRow(name: accountOnFile.label,
                                                 accountOnFileIdentifier: accountOnFile.identifier,
                                                 paymentProductIdentifier: accountOnFile.paymentProductIdentifier,
                                                 logo: product.displayHintsList[0].logoImage)
                    items.append(row)
                }
            }
            return items
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }

        private func showBottomSheet(text: String) {
            infoText = text
            showBottomSheet = true
        }

        // MARK: - ApplePay selection handling

        private func showApplePayPaymentItem(paymentProduct: PaymentProduct) {
            if PKPaymentAuthorizationViewController.canMakePayments() {
                // ***************************************************************************
                //
                // We retrieve the networks from the paymentProduct and then feed it to the
                // Apple Pay configuration.
                //
                // Then a view controller for Apple Pay will be shown.
                //
                // ***************************************************************************

                guard let networks = paymentProduct.paymentProduct302SpecificData?.networks else {
                    self.showAlert(text: "PaymentProductNetworksErrorMessage".localized)
                    return
                }

                let availableNetworks = networks.map { PKPaymentNetwork(rawValue: $0) }

                self.showApplePaySheet(
                    for: paymentProduct,
                    context: paymentContext,
                    withAvailableNetworks: availableNetworks
                )
            }
        }

        private func showApplePaySheet(
            for paymentProduct: PaymentProduct,
            context: PaymentContext,
            withAvailableNetworks paymentNetworks: [PKPaymentNetwork]
        ) {
            // This merchant should be the merchant id specified in the merchants developer portal.
            guard let merchantId = UserDefaults.standard.value(forKey: AppConstants.merchantId) as? String else {
                self.showAlert(text: "CannotFindMerchantIdErrorMessage".localized)
                return
            }

            generateSummaryItems(context: context)

            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = context.countryCode
            paymentRequest.currencyCode = context.amountOfMoney.currencyCode
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.paymentSummaryItems = summaryItems
            paymentRequest.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]

            // This merchant id is set in the merchants apple developer portal and is linked to a certificate
            paymentRequest.merchantIdentifier = merchantId

            // These shipping contact fields are optional and can be chosen by the merchant
            paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
            authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            authorizationViewController?.delegate = self

            // The authorizationViewController will be nil if the paymentRequest was incomplete or not created correctly
            if let authorizationViewController = authorizationViewController,
               PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
                applePayPaymentProduct = paymentProduct
                UIApplication.shared.rootViewController?.present(
                    authorizationViewController,
                    animated: true,
                    completion: nil
                )
            }
        }

        private func generateSummaryItems(context: PaymentContext) {
            // ***************************************************************************
            //
            // The summaryItems for the paymentRequest is a list of values with the only
            // value being the subtotal. You are able to add more values to the list if
            // desired, like a shipping cost and total. ApplePay expects the last summary
            // item to be the grand total, this will be displayed differently from the
            // other summary items.
            //
            // The value is specified in cents and converted to a NSDecimalNumber with
            // an exponent of -2.
            //
            // ***************************************************************************

            let total = context.amountOfMoney.totalAmount

            var summaryItems = [PKPaymentSummaryItem]()

            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "Merchant Name",
                    amount: NSDecimalNumber(mantissa: UInt64(total), exponent: -2, isNegative: false),
                    type: .final
                )
            )

            self.summaryItems = summaryItems
        }

        // MARK: - Payment request target

        private func didSubmitPaymentRequest(
            _ paymentRequest: PaymentRequest,
            success: (() -> Void)?,
            failure: (() -> Void)?
        ) {
            isLoading = true

            self.session.prepare(
                paymentRequest,
                success: { preparedPaymentRequest in
                    self.isLoading = false

                    // ***************************************************************************
                    //
                    // The information contained in `preparedPaymentRequest.encryptedFields` should
                    // be provided via the S2S Create Payment API, using field `encryptedCustomerInput`.
                    //
                    // ***************************************************************************
                    self.preparedPaymentRequest = preparedPaymentRequest
                    success?()
                    self.showSuccessScreen = true
                }, failure: { error in
                    self.isLoading = false
                    self.showAlert(text: error.localizedDescription)

                    failure?()
                },
                apiFailure: { errorResponse in
                    self.isLoading = false
                    self.showAlert(text: errorResponse.message)

                    failure?()
                }
            )
        }

        // MARK: - PKPaymentAuthorizationViewControllerDelegate
        // Sent to the delegate after the user has acted on the payment request.  The application
        // should inspect the payment to determine whether the payment request was authorized.
        //
        // If the application requested a shipping address then the full addresses is now part of the payment.
        //
        // The delegate must call completion with an appropriate authorization status, as may be determined
        // by submitting the payment credential to a processing gateway for payment authorization.
        //
        // MARK: - PKPaymentAuthorizationViewControllerDelegate
        // Sent to the delegate after the user has acted on the payment request.  The application
        // should inspect the payment to determine whether the payment request was authorized.
        //
        // If the application requested a shipping address then the full addresses is now part of the payment.
        //
        // The delegate must call completion with an appropriate authorization status, as may be determined
        // by submitting the payment credential to a processing gateway for payment authorization.
        func paymentAuthorizationViewController(
            _ controller: PKPaymentAuthorizationViewController,
            didAuthorizePayment payment: PKPayment,
            completion: @escaping (PKPaymentAuthorizationStatus) -> Void
        ) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                execute: {() -> Void in

                    // ***************************************************************************
                    //
                    // The information contained in preparedPaymentRequest is stored in such a way
                    // that it can be sent to the Ingenico ePayments platform via your server.
                    //
                    // ***************************************************************************

                    guard let applePayPaymentProduct = self.applePayPaymentProduct else {
                        Macros.DLog(message: "InvalidApplePayErrorMessage".localized)
                        return
                    }

                    let request = PaymentRequest(paymentProduct: applePayPaymentProduct)
                    guard let paymentDataString =
                            String(data: payment.token.paymentData, encoding: String.Encoding.utf8) else {
                        completion(.failure)
                        return
                    }
                    request.setValue(forField: "encryptedPaymentData", value: paymentDataString)
                    request.setValue(forField: "transactionId", value: payment.token.transactionIdentifier)

                    self.didSubmitPaymentRequest(
                        request,
                        success: {() -> Void in
                            completion(.success)
                        },
                        failure: {() -> Void in
                            completion(.failure)
                        }
                    )
                }
            )
        }

        // Sent to the delegate when payment authorization is finished.  This may occur when
        // the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
        // paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
        //
        // The delegate is responsible for dismissing the view controller in this method.

        @objc func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            applePayPaymentProduct = nil
            controller.dismiss(animated: true, completion: { return })
        }

        // ***************************************************************************
        // Sent when the user has selected a new payment card.
        // Use this delegate callback if you need to update the summary items in response to the card type changing
        // (for example, applying credit card surcharges).
        // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
        // until it has invoked the completion block.
        // ***************************************************************************

        func paymentAuthorizationViewController(
            _ controller: PKPaymentAuthorizationViewController,
            didSelect paymentMethod: PKPaymentMethod,
            completion: @escaping ([PKPaymentSummaryItem]) -> Void
        ) {
            completion(summaryItems)
        }
    }
}
