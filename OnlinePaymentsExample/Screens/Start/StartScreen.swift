//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct StartScreen: View {
    // MARK: - State
    @ObservedObject var viewModel: ViewModel

    @State private var showBottomSheet: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            LoadingView(isShowing: $viewModel.isLoading) {
                VStack(spacing: 20) {
                    HeaderView()
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            clientSectionDetailsView
                            paymentDetailsView
                            otherOptionsView
                            proceedButtonView
                        }
                        .padding()
                    }
                    NavigationLink("", isActive: $viewModel.showPaymentItemsList) {
                        if let session = viewModel.session,
                           let paymentContext = viewModel.paymentContext,
                           let paymentItems = viewModel.paymentItems {
                            PaymentItemsOverviewScreen(
                                viewModel: .init(
                                    session: session,
                                    paymentContext: paymentContext,
                                    paymentItems: paymentItems
                                )
                            )
                        } else {
                            // This should not never happen since showPaymentList is only true
                            // when paymentItems were retrieved
                            VStack {
                                HeaderView()
                                Text("NavigateToPaymentItemsOverviewErrorMessage".localized)
                            }
                            Spacer()
                        }
                    }
                }
                .alert(
                    isPresented: $viewModel.showAlert,
                    content: Alert.defaultErrorAlert(errorMessage: viewModel.errorMessage)
                )
                .bottomSheet(isPresented: $showBottomSheet,
                             headerType: .handle,
                             height: UIScreen.main.bounds.size.height * 0.2,
                             content: {
                    Text(viewModel.infoText)
                        .padding(.horizontal)
                })
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }.edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Views
    private var clientSectionDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ClientSessionDetails".localized)
                .font(.headline)
            TextFieldView(
                placeholder: "ClientSessionIdentifier".localized,
                text: $viewModel.clientSessionId,
                errorText: viewModel.clientSessionIdError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "ClientSessionIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CustomerIdentifier".localized,
                text: $viewModel.customerId,
                errorText: viewModel.customerIdError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CustomerIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "ClientIdentifier".localized,
                text: $viewModel.clientApiUrl,
                errorText: viewModel.clientApiUrlError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "ClientIdentifierHint".localized)
                }
            )
            TextFieldView(
                placeholder: "AssetURL".localized,
                text: $viewModel.assetUrl,
                errorText: viewModel.assetUrlError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "AssetURLHint".localized)
                }
            )
            HStack {
                Spacer()
                Button(action: {
                    viewModel.pasteFromJson()
                }, label: {
                    Text("Paste".localized)
                        .foregroundColor(.green)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.green, lineWidth: 2)
                        )
                })
            }
        }
    }

    private var paymentDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PaymentDetails".localized)
                .font(.headline)
            TextFieldView(
                placeholder: "AmountInCents".localized,
                text: $viewModel.amount,
                errorText: viewModel.amountError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "AmountInCentsHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CountryCode".localized,
                text: $viewModel.countryCode,
                errorText: viewModel.countryCodeError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CountryCodeHint".localized)
                }
            )
            TextFieldView(
                placeholder: "CurrencyCode".localized,
                text: $viewModel.currencyCode,
                errorText: viewModel.currencyCodeError,
                isSecureTextEntry: false,
                isFocused: { _ in },
                buttonCallback: {
                    showBottomSheet(text: "CurrencyCodeHint".localized)
                }
            )
        }
    }

    private var otherOptionsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("OtherOptions".localized)
                .font(.headline)

            Toggle(isOn: $viewModel.recurringPayment) {
                HStack {
                    Text("RecurringPayment".localized)
                    InfoButtonView {
                        showBottomSheet(text: "RecurringPaymentHint".localized)
                    }
                }
            }

            Toggle(isOn: $viewModel.showApplePayInput) {
                Text("ApplePay".localized)
            }

            if viewModel.showApplePayInput {
                TextFieldView(
                    placeholder: "MerchantId".localized,
                    text: $viewModel.merchantId,
                    errorText: viewModel.merchantIdError,
                    isSecureTextEntry: false,
                    isFocused: { _ in },
                    buttonCallback: {
                        showBottomSheet(text: "MerchantIdHint".localized)
                    }
                )
            }
        }
    }

    private var proceedButtonView: some View {
        Button(action: {
            viewModel.proceedToCheckout()
        }, label: {
            Text("Checkout".localized)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(5)
        })
    }

    // MARK: - Functions
    private func showBottomSheet(text: String) {
        viewModel.infoText = text
        self.showBottomSheet = true
    }
}

// MARK: - Previews
#Preview {
    StartScreen(viewModel: StartScreen.ViewModel())
}
