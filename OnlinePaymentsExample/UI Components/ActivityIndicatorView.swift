//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        uiView.startAnimating()
    }
}
