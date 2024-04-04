//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct PaymentItemListRowView: View {
    // MARK: - Properties
    var image: UIImage?
    var text: String

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(12)
            HStack(spacing: 20) {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(text)
                Spacer()
            }
            .padding(.leading, 15)
            .padding(10)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Previews
#Preview {
    List {
        ForEach(0...5, id: \.self ) { index in
            PaymentItemListRowView(image: UIImage(), text: "Payment Item \(index)")
        }
    }
}
