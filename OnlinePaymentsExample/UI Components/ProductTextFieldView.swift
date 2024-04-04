//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct ProductTextFieldView: View {

    enum ImageState {
        case none
        case info
        case image(Image)
    }

    // MARK: - State
    @Binding var text: String

    // MARK: - Properties
    var leadingImage: Image
    var trailingImage: ImageState
    var errorText: String?
    var placeholder: String
    var accentColor: Color
    var borderColor: Color
    var keyboardType: UIKit.UIKeyboardType
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    var buttonCallback: (() -> Void)?

    // MARK: - Init
    init(
        leadingImage: Image,
        trailingImage: ImageState = .info,
        placeholder: String = "Placeholder",
        text: Binding<String>,
        accentColor: Color = Color(UIColor.darkGray),
        borderColor: Color = Color(UIColor.gray),
        keyboardType: UIKit.UIKeyboardType = .numberPad,
        errorText: String?,
        onEditingChanged: @escaping (Bool) -> Void,
        onCommit: @escaping () -> Void,
        buttonCallback: (() -> Void)? = nil
    ) {
        self._text = text
        self.accentColor = accentColor
        self.borderColor = borderColor
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.errorText = errorText
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.buttonCallback = buttonCallback
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                leadingImage
                    .foregroundColor(accentColor)
                    .padding(.leading, 10)
                TextField(placeholder, text: $text, onEditingChanged: self.onEditingChanged, onCommit: self.onCommit)
                    .font(.body)
                    .disableAutocorrection(.none)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
                    .foregroundColor(accentColor)
                    .padding(.leading, 13)
                Group {
                    switch trailingImage {
                    case .none:
                        if errorText != nil {
                            errorImage
                        } else {
                            EmptyView()
                        }
                    case .info:
                        if errorText != nil {
                            errorImage
                        } else {
                            infoImage
                        }
                    case .image(let image):
                        if errorText != nil {
                            errorImage
                        } else {
                            cardImage(image: image)
                        }
                    }
                }
            }
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(errorText == nil ? borderColor : .red, lineWidth: 1)
            )
            if let errorText = errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Views
    private func cardImage(image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 25)
            .padding(.trailing, 10)
    }

    private var infoImage: some View {
        Image(systemName: "info.circle")
            .foregroundColor(accentColor)
            .padding(.trailing, 10)
            .onTapGesture {
                if let buttonCallback = buttonCallback {
                    buttonCallback()
                }
            }
    }

    private var errorImage: some View {
        Image(systemName: "exclamationmark.circle.fill")
            .foregroundColor(.red)
            .padding(.trailing, 10)
    }
}

// MARK: - Previews
#Preview("FieldWithPlaceholder") {
    ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                         placeholder: "***** ****",
                         text: .constant(""),
                         errorText: nil,
                         onEditingChanged: { _ in }, onCommit: {})
        .previewLayout(.sizeThatFits)
}

#Preview("FieldWithText") {
    ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                         text: .constant("12345"),
                         errorText: nil,
                         onEditingChanged: { _ in }, onCommit: {})
        .previewLayout(.sizeThatFits)
}

#Preview("FieldWithTextAndError") {
    ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                         text: .constant("******"),
                         errorText: "Error message",
                         onEditingChanged: { _ in }, onCommit: {})
        .previewLayout(.sizeThatFits)
}

#Preview("FieldWithTextAndErrorDarkMode") {
    ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                         text: .constant("******"),
                         errorText: "Error message",
                         onEditingChanged: { _ in }, onCommit: {})
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
}

#Preview("FieldWithTextAndLongError") {
    ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                     text: .constant("******"),
                     errorText: """
                        This is a long error message that will be spread over multiple lines.
                        This is a long error message that will be spread over multiple lines.
                     """,
                     onEditingChanged: { _ in }, onCommit: {})
        .previewLayout(.sizeThatFits)
}
