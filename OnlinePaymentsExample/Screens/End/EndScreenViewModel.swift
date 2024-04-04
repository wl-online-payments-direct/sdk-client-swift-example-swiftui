//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 09/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation
import OnlinePaymentsKit
import UIKit

extension EndScreen {

    class ViewModel: ObservableObject {

        // MARK: - Properties
        @Published var showEncryptedFields: Bool = false

        var preparedPaymentRequest: PreparedPaymentRequest?

        // MARK: - Init
        init(preparedPaymentRequest: PreparedPaymentRequest?) {
            self.preparedPaymentRequest = preparedPaymentRequest
        }

        // MARK: - Functions
        func copyToClipboard() {
            UIPasteboard.general.string = self.preparedPaymentRequest?.encryptedFields ?? ""
        }

        func returnToStart() {
            NavigationUtil.popToRootView()
        }

    }
}
