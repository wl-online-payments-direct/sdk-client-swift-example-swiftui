//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 09/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import OnlinePaymentsKit
import SwiftUI

struct EndScreen: View {

    // MARK: - State
    @ObservedObject var viewModel: ViewModel

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("SuccessLabel".localized)
                    .font(.largeTitle)
                Text("SuccessText".localized)
                    .font(.headline)
                Button(
                    viewModel.showEncryptedFields ?
                    "HideEncryptedDataResult".localized :
                    "ShowEncryptedDataResult".localized
                ) {
                    viewModel.showEncryptedFields.toggle()
                }

                if viewModel.showEncryptedFields {
                    VStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("EncryptedFieldsHeader".localized)
                                .bold()
                            Text(viewModel.preparedPaymentRequest?.encryptedFields ?? "")
                        }
                        VStack(alignment: .leading) {
                            Text("EncryptedClientMetaInfoHeader".localized)
                                .bold()
                            Text(viewModel.preparedPaymentRequest?.encodedClientMetaInfo ?? "")
                        }
                    }
                }

                Button(action: {
                    viewModel.copyToClipboard()
                }, label: {
                    Text("CopyEncryptedDataLabel".localized)
                        .foregroundColor(.green)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.green, lineWidth: 2)
                        )
                })

                Button(action: {
                    viewModel.returnToStart()
                }, label: {
                    Text("ReturnToStart".localized)
                        .foregroundColor(.red)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 2)
                        )
                })
            }
            .padding()
        }
    }
}

// MARK: - Previews
#Preview {
    EndScreen(viewModel: EndScreen.ViewModel(preparedPaymentRequest: nil))
}
