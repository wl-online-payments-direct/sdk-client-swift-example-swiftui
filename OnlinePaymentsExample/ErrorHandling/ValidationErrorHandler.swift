//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation
import OnlinePaymentsKit

struct ValidationErrorHandler {
    static let errorMessageFormat = "gc.general.paymentProductFields.validationErrors.%@.label"

    static func errorMessage(for error: ValidationError, withCurrency: Bool) -> String {
        let errorClass = error.self
        var errorMessage: String
        if let lengthError = errorClass as? ValidationErrorLength {
            errorMessage = validationErrorLength(lengthError: lengthError)
        } else if let rangeError = errorClass as? ValidationErrorRange {
            errorMessage = validationErrorRange(rangeError: rangeError, withCurrency: withCurrency)

        } else if !errorClass.errorMessage.isEmpty {
            let errorMessageKey = String(format: errorMessageFormat, errorClass.errorMessage)
            let errorMessageValue =
                NSLocalizedString(
                    errorMessageKey,
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: ""
                )
            errorMessage = errorMessageValue
        } else {
            errorMessage = ""
            NSException(
                name: NSExceptionName(rawValue: "InvalidValidationError".localized),
                reason: "Validation error \(error) is invalid",
                userInfo: nil
            ).raise()
        }

        return errorMessage
    }

    private static func validationErrorLength(lengthError: ValidationErrorLength) -> String {
        var errorMessageKey: String

        if lengthError.minLength == lengthError.maxLength {
            errorMessageKey = String(format: errorMessageFormat, "length.exact")
        } else if lengthError.minLength == 0 && lengthError.maxLength > 0 {
            errorMessageKey = String(format: errorMessageFormat, "length.max")
        } else if lengthError.minLength > 0 && lengthError.maxLength > 0 {
            errorMessageKey = String(format: errorMessageFormat, "length.between")
        } else {
            // this case never happens
            errorMessageKey = ""
        }

        let errorMessageValueWithPlaceholders =
            NSLocalizedString(
                errorMessageKey,
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        let errorMessageValueWithPlaceholder =
            errorMessageValueWithPlaceholders.replacingOccurrences(
                of: "{maxLength}",
                with: String(lengthError.maxLength)
            )
        return errorMessageValueWithPlaceholder.replacingOccurrences(
                of: "{minLength}",
                with: String(lengthError.minLength)
            )
    }

    private static func validationErrorRange(rangeError: ValidationErrorRange, withCurrency: Bool) -> String {
        let errorMessageKey = String(format: errorMessageFormat, "length.between")
        let errorMessageValueWithPlaceholders =
            NSLocalizedString(
                errorMessageKey,
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        var minString = ""
        var maxString = ""
        if withCurrency {
            minString = String(format: "%.2f", Double(rangeError.minValue) / 100)
            maxString = String(format: "%.2f", Double(rangeError.maxValue) / 100)
        } else {
            minString = "\(Int(rangeError.minValue))"
            maxString = "\(Int(rangeError.maxValue))"
        }
        let errorMessageValueWithPlaceholder =
            errorMessageValueWithPlaceholders.replacingOccurrences(of: "{maxValue}", with: String(maxString))
        return errorMessageValueWithPlaceholder.replacingOccurrences(of: "{minValue}", with: String(minString))
    }
}
