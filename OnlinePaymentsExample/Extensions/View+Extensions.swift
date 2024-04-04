//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 08/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path =
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
        return Path(path.cgPath)
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        headerType: BottomSheetHeaderType,
        height: CGFloat,
        topBarHeight: CGFloat = 30,
        topBarCornerRadius: CGFloat? = nil,
        contentBackgroundColor: Color = Color(.systemBackground),
        topBarBackgroundColor: Color = Color(.systemBackground),
        showTopIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        // Starting from iOS 16, there is a modifier which allows you to show the sheet only on part of the screen
        if #available(iOS 16, *) {
            return sheet(isPresented: isPresented) {
                content()
                    .padding(.horizontal)
                    .presentationDetents([.medium, .fraction(0.2)])
            }
        } else {
            // This is a workaround for iOS 15 and below to show a sheet only on part of the screen
            return ZStack {
                self
                BottomSheetView(isPresented: isPresented,
                                height: height,
                                headerType: headerType,
                                topBarHeight: topBarHeight,
                                topBarCornerRadius: topBarCornerRadius,
                                topBarBackgroundColor: topBarBackgroundColor,
                                contentBackgroundColor: contentBackgroundColor,
                                showTopIndicator: showTopIndicator,
                                content: content)
            }
        }
    }
}
