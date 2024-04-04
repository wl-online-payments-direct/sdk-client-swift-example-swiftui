//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

extension Alert {
    static func defaultErrorAlert(errorMessage: String?) -> (() -> Alert) {
        {
            Alert(
                title: Text("DefaultErrorMessage".localized),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
