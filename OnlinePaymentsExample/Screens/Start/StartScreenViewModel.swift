//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation
import OnlinePaymentsKit
import UIKit

extension StartScreen {
    class ViewModel: ObservableObject {

        // MARK: - Properties
        @Published var clientSessionId: String = ""
        @Published var clientSessionIdError: String?

        @Published var customerId: String = ""
        @Published var customerIdError: String?

        @Published var clientApiUrl: String = ""
        @Published var clientApiUrlError: String?

        @Published var assetUrl: String = ""
        @Published var assetUrlError: String?

        @Published var amount: String = ""
        @Published var amountError: String?

        @Published var countryCode: String = ""
        @Published var countryCodeError: String?

        @Published var currencyCode: String = ""
        @Published var currencyCodeError: String?

        @Published var merchantId: String = ""
        @Published var merchantIdError: String?

        @Published var recurringPayment: Bool = false
        @Published var showApplePayInput: Bool = false

        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var infoText: String = ""
        @Published var showPaymentItemsList: Bool = false
        @Published var isLoading: Bool = false

        private let emptyFieldError = "EmptyField".localized

        var session: Session?
        var paymentContext: PaymentContext?
        var paymentItems: PaymentItems?

        // MARK: - Init
        init() {
            clientSessionId = UserDefaults.standard.string(forKey: AppConstants.clientSessionId) ?? ""
            customerId = UserDefaults.standard.string(forKey: AppConstants.customerId) ?? ""
            clientApiUrl = UserDefaults.standard.string(forKey: AppConstants.baseURL) ?? ""
            assetUrl = UserDefaults.standard.string(forKey: AppConstants.assetURL) ?? ""

            amount = UserDefaults.standard.string(forKey: AppConstants.amount) ?? ""
            countryCode = UserDefaults.standard.string(forKey: AppConstants.countryCode) ?? ""
            currencyCode = UserDefaults.standard.string(forKey: AppConstants.currencyCode) ?? ""
            merchantId = UserDefaults.standard.string(forKey: AppConstants.merchantId) ?? ""

            showApplePayInput = UserDefaults.standard.bool(forKey: AppConstants.applePayIdentifier)
        }

        // MARK: - Session functions
        func proceedToCheckout() {
            isLoading = true

            self.validateInput()
            self.initializeSession()

            if session != nil {
                // Only attempt to retrieve payment items when Session was succesfully initialized
                self.retrievePaymentItems()
            }
        }

        private func initializeSession() {
            guard clientSessionIdError == nil &&
                customerIdError == nil &&
                clientApiUrlError == nil &&
                assetUrlError == nil &&
                amountError == nil &&
                countryCodeError == nil &&
                currencyCodeError == nil &&
                (!showApplePayInput || showApplePayInput && merchantIdError == nil) else {
                isLoading = false
                return
            }

            // ***************************************************************************
            //
            // The Online Payments SDK supports processing payments with instances of the
            // Session class. The code below shows how such an instance chould be
            // instantiated.
            //
            // The Session class uses a number of supporting objects. There is an
            // initializer for this class that takes these supporting objects as
            // arguments. This should make it easy to replace these additional objects
            // without changing the implementation of the SDK. Use this initializer
            // instead of the factory method used below if you want to replace any of the
            // supporting objects.
            //
            // You can log requests made to the server and responses received from the server
            // by passing the `loggingEnabled` parameter to the Session constructor.
            // In the constructor below, the logging is disabled.
            // You are also able to disable / enable logging at a later stage
            // by calling `session.loggingEnabled = `, as shown below.
            // Logging should be disabled in production.
            // To use logging in debug, but not in production, you can set `loggingEnabled` within a DEBUG flag.
            // If you use the DEBUG flag, you can take a look at this app's build settings
            // to see the setup you should apply to your own app.
            // ***************************************************************************

            session =
                Session(
                    clientSessionId: clientSessionId,
                    customerId: customerId,
                    baseURL: clientApiUrl,
                    assetBaseURL: assetUrl,
                    appIdentifier: AppConstants.applicationIdentifier,
                    loggingEnabled: false
                )

            #if DEBUG
                session?.loggingEnabled = true
            #endif

            self.saveInputToUserDefaults()
        }

        private func retrievePaymentItems() {
            // ***************************************************************************
            //
            // To retrieve the available payment products, the information stored in the
            // following PaymentContext object is needed.
            //
            // After the Session object has retrieved the payment products that match
            // the information stored in the PaymentContext object, a
            // selection screen is shown. This screen itself is not part of the SDK and
            // only illustrates a possible payment product selection screen.
            //
            // ***************************************************************************
            let amountOfMoney = AmountOfMoney(
                totalAmount: Int(amount) ?? 0,
                currencyCode: currencyCode
            )

            paymentContext =
                PaymentContext(
                    amountOfMoney: amountOfMoney,
                    isRecurring: recurringPayment,
                    countryCode: countryCode
                )

            guard let paymentContext else { return }

            session?.paymentItems(
                for: paymentContext,
                groupPaymentProducts: false,
                success: { paymentItems in
                    self.paymentItems = paymentItems
                    self.isLoading = false
                    self.showPaymentItemsList = true
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

        // MARK: - Helpers
        private func validateInput() {
            validateClientSessionId()
            validateCustomerID()
            validateClientApiUrl()
            validateAssetUrl()
            validateAmount()
            validateCountryCode()
            validateCurrencyCode()
            if showApplePayInput {
                validateMerchantId()
            }
        }

        func pasteFromJson() {
            guard let value = UIPasteboard.general.string,
                  let result = parseJson(value) else {
                return
            }

            clientSessionId = result.clientSessionId ?? ""
            customerId = result.customerId ?? ""
            clientApiUrl = result.clientApiUrl ?? ""
            assetUrl = result.assetUrl ?? ""
        }

        private func parseJson(_ jsonString: String) -> ParsedJsonData? {
            guard let jsonData = jsonString.data(using: .utf8) else {
                showAlert(text: "ParsedJsonNilErrorMessage".localized)
                return nil
            }

            guard let parsedJsonData = try? JSONDecoder().decode(ParsedJsonData.self, from: jsonData) else {
                showAlert(text: "JsonErrorMessage".localized)
                return nil
            }

            return parsedJsonData
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }

        private func saveInputToUserDefaults() {
            UserDefaults.standard.set(clientSessionId, forKey: AppConstants.clientSessionId)
            UserDefaults.standard.set(customerId, forKey: AppConstants.customerId)
            UserDefaults.standard.set(clientApiUrl, forKey: AppConstants.baseURL)
            UserDefaults.standard.set(assetUrl, forKey: AppConstants.assetURL)

            UserDefaults.standard.set(amount, forKey: AppConstants.amount)
            UserDefaults.standard.set(countryCode, forKey: AppConstants.countryCode)
            UserDefaults.standard.set(currencyCode, forKey: AppConstants.currencyCode)
            UserDefaults.standard.set(merchantId, forKey: AppConstants.merchantId)

            UserDefaults.standard.set(showApplePayInput, forKey: AppConstants.applePayIdentifier)
        }

        // MARK: - Field Validation
        private func validateClientSessionId() {
            clientSessionIdError = clientSessionId.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateCustomerID() {
            customerIdError =
                customerId.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateClientApiUrl() {
            clientApiUrlError =
                clientApiUrl.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateAssetUrl() {
            assetUrlError =
                assetUrl.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateAmount() {
            amountError =
                amount.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateCountryCode() {
            countryCodeError =
                countryCode.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateCurrencyCode() {
            currencyCodeError =
                currencyCode.isEmpty ?
                    emptyFieldError :
                    nil
        }

        private func validateMerchantId() {
            merchantIdError =
                merchantId.isEmpty ?
                    emptyFieldError :
                    nil
        }
    }
}
