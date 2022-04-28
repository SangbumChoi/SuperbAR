//
//  Interfaces.swift
//  SuperbAR
//
//  Created by 유용환 on 2022/04/24.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import Foundation
import UIKit

struct Upload: Codable {
    let uploadURL: String
    let Key: String
}

struct Download: Codable {
    let downloadURLs: [String]
}
