//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import UIKit
import OnlinePaymentsKit

struct AppConstants {
    static let sdkBundle = Bundle(path: SDKConstants.kSDKBundlePath!)!
    static let applicationIdentifier = "SwiftUI Example Application/v1.0.0"

    // Constants used for saving input to UserDefaults
    static let clientSessionId = "ClientSessionId"
    static let customerId = "CustomerId"
    static let merchantId = "MerchantId"
    static let baseURL = "BaseURL"
    static let assetURL = "AssetURL"
    static let amount = "Amount"
    static let countryCode = "CountryCode"
    static let currencyCode = "CurrencyCode"

    // Apple Pay identifier
    static let applePayIdentifier = "302"

    // Constants used to identify Card product fields
    static let cardField = "cardNumber"
    static let cvvField = "cvv"
    static let securityCodeField = "PinCode"
    static let expiryDateField = "expiryDate"
    static let cardHolderField = "cardholderName"
}
