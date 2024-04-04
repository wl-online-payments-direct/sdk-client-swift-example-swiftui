//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 09/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import UIKit

struct NavigationUtil {
    static func popToRootView() {
        findNavigationController(
            viewController:
                UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
        )?.popToRootViewController(animated: true)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        if !viewController.children.isEmpty {
            let childViewController = viewController.children[0]
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }
}
