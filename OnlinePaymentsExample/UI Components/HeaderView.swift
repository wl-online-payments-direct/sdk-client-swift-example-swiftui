//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct HeaderView: View {

    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            Image("MerchantLogo")
                .resizable()
                .scaledToFit()
                .padding(.top, 40)
                .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.15)
            HStack {
                Spacer()
                HStack {
                    Image("SecurePaymentIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("SecurePayment".localized)
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }.padding(.horizontal, 20)
    }
}

// MARK: - Previews
#Preview {
    HeaderView()
}
