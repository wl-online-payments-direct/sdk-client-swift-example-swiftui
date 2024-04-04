//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct InfoButtonView: View {

    // MARK: - Properties
    var buttonCallback: (() -> Void)?

    // MARK: - Body
    var body: some View {
        Image(systemName: "info.circle")
            .padding(.trailing, 20)
            .onTapGesture {
                buttonCallback?()
            }
    }
}

// MARK: - Previews
#Preview {
    InfoButtonView()
}
