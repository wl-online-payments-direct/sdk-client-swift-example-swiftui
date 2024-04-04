//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 07/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import Foundation

struct ParsedJsonData: Decodable {
    let clientSessionId: String?
    let customerId: String?
    let clientApiUrl: String?
    let assetUrl: String?
}
