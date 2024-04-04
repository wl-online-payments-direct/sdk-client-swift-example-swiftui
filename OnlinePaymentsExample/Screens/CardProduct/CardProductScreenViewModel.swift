//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 
// swiftlint:disable file_length

import OnlinePaymentsKit
import SwiftUI

extension CardProductScreen {

    // swiftlint: disable type_body_length
    class ViewModel: ObservableObject {

        // MARK: - Properties
        private var creditCardFirstSixDigits: String = ""
        private var tokenize = false

        private var displayedValues = [String: String]()
        private var fieldValues = [String: String]()
        private var paymentRequest: PaymentRequest?
        private let cardFieldLimit: Int = 6

        var accountOnFile: AccountOnFile?
        var paymentItem: PaymentItem?
        var preparedPaymentRequest: PreparedPaymentRequest?

        // MARK: - State
        var hasCardField: Bool = false
        @Published var cardField: PaymentProductField?
        @Published var cardFieldEnabled: Bool = true
        @Published var cardError: String?

        var hasExpiryDateField: Bool = false
        @Published var expiryDateField: PaymentProductField?
        @Published var expiryDateFieldEnabled: Bool = true
        @Published var expiryDateError: String?

        var hasCvvField: Bool = false
        @Published var cvvField: PaymentProductField?
        @Published var cvvError: String?

        var hasSecurityCodeField: Bool = false
        @Published var securityCodeField: PaymentProductField?
        @Published var securityCodeError: String?

        var hasCardHolderField: Bool = false
        @Published var cardHolderField: PaymentProductField?
        @Published var cardHolderFieldEnabled: Bool = true
        @Published var cardHolderError: String?

        @Published var rememberPaymentDetails: Bool = false

        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var isLoading: Bool = false
        @Published var showEndScreen: Bool = false
        @Published var liveValidationEnabled: Bool = false
        @Published var payIsActive: Bool = false

        private let session: Session
        private let paymentContext: PaymentContext

        // MARK: - Init
        init(
            session: Session,
            paymentContext: PaymentContext,
            paymentItem: PaymentItem?,
            accountOnFile: AccountOnFile?
        ) {
            self.session = session
            self.paymentContext = paymentContext
            self.paymentItem = paymentItem
            self.accountOnFile = accountOnFile

            self.configurePaymentItemFields()
            self.configureAccountOnFileFields()
        }

        // MARK: - Fields callbacks
        func onCreditCardFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cardField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled {
                self.validateCard()
            }

            let inputData = self.unmaskedValue(forField: self.cardField)
            if inputData.count == self.cardFieldLimit &&
               self.creditCardFirstSixDigits != inputData &&
               hasCardHolderField {
                self.creditCardFirstSixDigits = inputData
                self.getIinDetails()
            }
        }

        func onExpiryDateFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.expiryDateField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled {
                self.validateExpiryDate()
            }
        }

        func onCVVFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cvvField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled {
                self.validateCVV()
            }
        }

        func onSecurityCodeFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.securityCodeField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled {
                self.validateSecurityCode()
            }
        }

        func onCardHolderNameFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cardHolderField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled {
                self.validateCardHolderName()
            }
        }

        // MARK: - Fields helpers
        private func setFieldValue(
            value: String,
            forField paymentProductField: PaymentProductField?,
            updatePaymentRequestFieldValues: Bool
        ) {
            let fieldId = paymentProductField?.identifier ?? ""

            displayedValues[fieldId] = value
            if updatePaymentRequestFieldValues {
                fieldValues[fieldId] = value
            }
        }

        private func displayValue(forField paymentProductField: PaymentProductField?) -> String {
            let fieldId = paymentProductField?.identifier ?? ""

            guard let value = displayedValues[fieldId] else {
                return ""
            }

            return value
        }

        func maskedValue(forField paymentProductField: PaymentProductField?) -> String {
            let value = self.displayValue(forField: paymentProductField)
            guard let paymentProductField else {
                return value
            }

            return paymentProductField.applyMask(value: value)
        }

        private func unmaskedValue(forField paymentProductField: PaymentProductField?) -> String {
            let value = self.displayValue(forField: paymentProductField)
            guard let paymentProductField else {
                return value
            }

            let unmaskedValue = paymentProductField.removeMask(value: value)
            return unmaskedValue
        }

        func getCreditCardValue() -> String {
            // If accountOnFile cardNumber value equals current input,
            // then return the (unmasked) value, otherwise the masked value.
            // This is to ensure that the accountOnFile cardNumber is displayed correctly.
            if accountOnFile?.attributes.value(forField: AppConstants.cardField) ==
               displayValue(forField: cardField) {
                return displayValue(forField: cardField)
            } else {
                return maskedValue(forField: cardField)
            }
        }

        private func fieldIsPartOfAccountOnFile(paymentProductFieldId: String) -> Bool {
            return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
        }

        private func fieldIsReadOnly(paymentProductField: PaymentProductField?) -> Bool {
            let fieldId = paymentProductField?.identifier ?? ""
            if !fieldIsPartOfAccountOnFile(paymentProductFieldId: fieldId) {
                return false
            } else {
                return accountOnFile?.isReadOnly(field: fieldId) ?? false
            }
        }

        func placeholder(forField paymentProductField: PaymentProductField?) -> String {
            guard let paymentProductField else {
                return ""
            }

            let field = self.paymentItem?.paymentProductField(withId: paymentProductField.identifier)

            return field?.displayHints.label ?? ""
        }

        // MARK: - Validators
        private func evaluatePayButton() {
            // Only validate if field is in product
            let validCardField =
                hasCardField ?
                    (!displayValue(forField: cardField).isEmpty && cardError == nil) :
                    true
            let validExpiryDateField =
                hasExpiryDateField ?
                    (!displayValue(forField: expiryDateField).isEmpty && expiryDateError == nil) :
                    true
            let validCvvField =
                hasCvvField ?
                    (!displayValue(forField: cvvField).isEmpty && cvvError == nil) :
                    true
            let validSecurityCodeField =
                hasSecurityCodeField ?
                    (!displayValue(forField: securityCodeField).isEmpty && securityCodeError == nil) :
                    true
            let validCardHolderField =
                hasCardHolderField ?
                    (!displayValue(forField: cardHolderField).isEmpty && cardHolderError == nil) :
                    true

            if validCardField &&
               validExpiryDateField &&
               validCvvField &&
               validSecurityCodeField &&
               validCardHolderField {
                payIsActive = true
            } else {
                payIsActive = false
            }
        }

        private func validateFields() {
            // Credit card number should not be validated when using an account on file,
            // since the value cannot be modified
            if accountOnFile == nil { validateCard()}
            if hasExpiryDateField { validateExpiryDate() }
            if hasCvvField { validateCVV() }
            if hasSecurityCodeField { validateSecurityCode() }
            if hasCardHolderField { validateCardHolderName() }
        }

        private func validateCard() {
            guard let cardField else {
                return
            }

            let errorMessageIds =
                cardField.validateValue(value: self.unmaskedValue(forField: self.cardField))

            cardError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateExpiryDate() {
            guard let expiryDateField,
                  !fieldIsReadOnly(paymentProductField: expiryDateField)
                    else {
                return
            }

            let errorMessageIds =
                expiryDateField.validateValue(value: self.unmaskedValue(forField: self.expiryDateField))

            expiryDateError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateCVV() {
            guard let cvvField,
                  !fieldIsReadOnly(paymentProductField: cvvField) else {
                return
            }

            let errorMessageIds = cvvField.validateValue(value: self.unmaskedValue(forField: self.cvvField))

            cvvError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateSecurityCode() {
            guard let securityCodeField,
                  !fieldIsReadOnly(paymentProductField: securityCodeField) else {
                return
            }

            let errorMessageIds =
                securityCodeField.validateValue(
                    value: self.unmaskedValue(forField: self.securityCodeField)
                )

            securityCodeError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateCardHolderName() {
            guard let cardHolderField,
                  cardHolderField.dataRestrictions.isRequired,
                  !fieldIsReadOnly(paymentProductField: cardHolderField) else {
                return
            }

            let errorMessageIds =
                cardHolderField.validateValue(value: self.unmaskedValue(forField: self.cardHolderField))

            cardHolderError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func getErrorMessage(validationErrors: [ValidationError]) -> String? {
            return !validationErrors.isEmpty ?
                ValidationErrorHandler.errorMessage(for: validationErrors[0], withCurrency: false) :
                nil
        }

        // MARK: - General Helpers
        private func createPaymentRequest() -> PaymentRequest {
            guard let paymentProduct = paymentItem as? PaymentProduct else {
                fatalError("Invalid paymentItem")
            }

            let paymentRequest =
                PaymentRequest(
                    paymentProduct: paymentProduct,
                    accountOnFile: accountOnFile,
                    tokenize: self.tokenize
                )

            let keys = Array(fieldValues.keys)

            for key: String in keys {
                if let value = fieldValues[key] {
                    paymentRequest.setValue(forField: key, value: value)
                }
            }

            return paymentRequest
        }

        private func configurePaymentItemFields() {
            guard let paymentItem else {
                return
            }

            self.cardField = paymentItem.paymentProductField(withId: AppConstants.cardField)
            if cardField != nil { self.hasCardField = true }

            self.expiryDateField = paymentItem.paymentProductField(withId: AppConstants.expiryDateField)
            if expiryDateField != nil { self.hasExpiryDateField = true }

            self.cvvField = paymentItem.paymentProductField(withId: AppConstants.cvvField)
            if cvvField != nil { self.hasCvvField = true }

            self.securityCodeField = paymentItem.paymentProductField(withId: AppConstants.securityCodeField)
            if securityCodeField != nil { self.hasSecurityCodeField = true }

            self.cardHolderField = paymentItem.paymentProductField(withId: AppConstants.cardHolderField)
            if cardHolderField != nil { self.hasCardHolderField = true }
        }

        private func configureAccountOnFileFields() {
            guard let accountOnFile else {
                return
            }

            setCreditCardFieldAccountOnFile(accountOnFile: accountOnFile)
            setExpiryDateFieldAccountOnFile(accountOnFile: accountOnFile)
            setCardHolderFieldAccountOnFile(accountOnFile: accountOnFile)
        }

        private func setCreditCardFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = cardField?.identifier ?? ""
            let value = accountOnFile.maskedValue(forField: fieldId)
            self.setFieldValue(value: value, forField: cardField, updatePaymentRequestFieldValues: false)
            // Always disable credit card field when using an account on file, the card number should never be modified
            cardFieldEnabled = false
        }

        private func setExpiryDateFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = expiryDateField?.identifier ?? ""
            let value = accountOnFile.maskedValue(forField: fieldId)
            self.setFieldValue(value: value, forField: expiryDateField, updatePaymentRequestFieldValues: false)
            expiryDateFieldEnabled = !accountOnFile.isReadOnly(field: fieldId)
        }

        private func setCardHolderFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = cardHolderField?.identifier ?? ""
            let value = accountOnFile.maskedValue(forField: fieldId)
            self.setFieldValue(value: value, forField: cardHolderField, updatePaymentRequestFieldValues: false)
            cardHolderFieldEnabled = !accountOnFile.isReadOnly(field: fieldId)
        }

        // MARK: - Actions
        func pay() {
            self.paymentRequest = self.createPaymentRequest()

            validateFields()

            guard cardError == nil &&
                    expiryDateError == nil &&
                    cvvError == nil &&
                    securityCodeError == nil &&
                    cardHolderError == nil else {
                        liveValidationEnabled = true
                        return
                    }

            self.tokenize = rememberPaymentDetails

            guard let paymentRequest = self.paymentRequest else {
                return
            }

            self.isLoading = true

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
                    self.showEndScreen = true
                },
                failure: { error in
                    self.isLoading = false
                    self.showAlert(text: error.localizedDescription)
                },
                apiFailure: { errorResponse in
                    self.isLoading = false
                    self.showAlert(text: errorResponse.message)
                }
            )
        }

        private func getIinDetails() {
            session.iinDetails(
                forPartialCreditCardNumber: self.unmaskedValue(forField: self.cardField),
                context: paymentContext,
                success: { iinDetailsResponse in
                    switch iinDetailsResponse.status {
                    case .supported:
                        self.switchToPaymentProduct(paymentProductId: iinDetailsResponse.paymentProductId)
                    case .existingButNotAllowed:
                        self.cardError =
                            NSLocalizedString(
                                "gc.general.paymentProductFields.validationErrors.allowedInContext.label",
                                tableName: SDKConstants.kSDKLocalizable,
                                bundle: AppConstants.sdkBundle,
                                value: "",
                                comment:
                                    """
                                    The card you entered is not supported.
                                    Please enter another card or try another payment method.
                                    """
                            )
                    default:
                        self.showAlert(text: "IINUnknown".localized)
                    }
                },
                failure: { error in
                    self.showAlert(text: error.localizedDescription)
                },
                apiFailure: { errorResponse in
                    self.showAlert(text: errorResponse.message)
                }
            )
        }

        private func switchToPaymentProduct(paymentProductId: String?) {
            if let paymentProductId,
               paymentProductId != paymentItem?.identifier {
                session.paymentProduct(
                    withId: paymentProductId,
                    context: paymentContext,
                    success: { paymentProduct in
                        self.paymentItem = paymentProduct
                        self.cardError = nil
                        self.configurePaymentItemFields()
                    },
                    failure: { error in
                        self.showAlert(text: error.localizedDescription)
                    },
                    apiFailure: { errorResponse in
                        self.showAlert(text: errorResponse.message)
                    }
                )
            }
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }
    }
    // swiftlint: enable type_body_length
}
