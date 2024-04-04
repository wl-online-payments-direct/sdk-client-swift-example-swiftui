//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct TextFieldView: View {

    private enum Constants {
        static let offset: CGFloat = -18
        static let normalTextSize: CGFloat = 16
    }

    // MARK: - Properties
    var placeholder: String
    var errorText: String?
    var isSecureTextEntry: Bool
    var autocorrection: Bool
    var autocapitalization: UITextAutocapitalizationType
    var keyboardType: UIKit.UIKeyboardType
    var isFocused: (Bool) -> Void
    var buttonCallback: (() -> Void)?

    // MARK: - State
    @Binding var text: String
    @State private var isSecureTextOn: Bool = true

    // MARK: - Init
    init(
        placeholder: String = "Placeholder".localized,
        text: Binding<String>,
        errorText: String?,
        isSecureTextEntry: Bool = false,
        isFocused: @escaping (Bool) -> Void,
        autocorrection: Bool = false,
        autocapitalization: UITextAutocapitalizationType = .none,
        keyboardType: UIKit.UIKeyboardType = .default,
        buttonCallback: (() -> Void)? = nil
    ) {
        self._text = text
        self.errorText = errorText
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecureTextEntry
        self.isFocused = isFocused
        self.autocorrection = autocorrection
        self.autocapitalization = autocapitalization
        self.keyboardType = keyboardType
        self.buttonCallback = buttonCallback
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 20) {
                Text(placeholder)
                    .font(text.isEmpty ? .body : .system(size: 8))
                    .foregroundColor(Color(UIColor.darkGray))
                    .offset(y: text.isEmpty ? 0 : Constants.offset)
                    .padding(.leading, 13)
                Spacer()
                if let errorText = errorText {
                    Text(errorText)
                        .font(.system(size: 8))
                        .lineLimit(2)
                        .foregroundColor(.red)
                        .offset(y: Constants.offset)
                        .padding(.trailing, 10)
                }
            }
            HStack {
                if isSecureTextEntry && isSecureTextOn {
                    ZStack {
                        SecureField("", text: $text)
                            .foregroundColor(Color(UIColor.darkGray))
                        TextField("", text: $text, onEditingChanged: self.isFocused)
                            .foregroundColor(.clear)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .font(.system(size: Constants.normalTextSize, design: .monospaced))
                    .padding(.leading, 13)
                    .frame(maxWidth: .infinity)
                    Image(systemName: isSecureTextEntry && isSecureTextOn ? "eye" : "eye.slash")
                        .padding(.trailing, 20)
                        .onTapGesture {
                            isSecureTextOn.toggle()
                        }
                        .opacity(isSecureTextEntry ? 1 : 0)
                } else {
                    TextField("", text: $text, onEditingChanged: self.isFocused)
                        .font(.body)
                        .disableAutocorrection(!autocorrection)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .foregroundColor(Color(UIColor.darkGray))
                        .padding(.leading, 13)
                        .frame(maxWidth: .infinity)
                    InfoButtonView {
                        buttonCallback?()
                    }
                }

            }
            .frame(height: 20)
        }
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(errorText == nil ? Color.gray : .red, lineWidth: 2)
        )
    }
}

// MARK: - Previews
#Preview("ExampleTextWithError") {
    TextFieldView(
        placeholder: "Example text",
        text: .constant("Invalid example text"),
        errorText: "Error message",
        isFocused: { _ in }
    )
    .previewLayout(.sizeThatFits)
}

#Preview("SecureText") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("Your password"),
        errorText: "",
        isSecureTextEntry: true,
        isFocused: { _ in },
        autocorrection: false,
        autocapitalization: .none,
        keyboardType: .default
    )
    .previewLayout(.sizeThatFits)
}

#Preview("SecureTextDarkMode") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("Your password"),
        errorText: "",
        isSecureTextEntry: true,
        isFocused: { _ in },
        autocorrection: false,
        autocapitalization: .none,
        keyboardType: .default
    )
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
}

#Preview("SecureTextWithLongError") {
    TextFieldView(
        placeholder: "Password",
        text: .constant("Your password"),
        errorText: "This is a long error message which will be shown in the TextField",
        isSecureTextEntry: true,
        isFocused: { _ in }
    )
    .previewLayout(.sizeThatFits)
}
