//
//  Interfaces.swift
//  SuperbAR
//
//  Created by 유용환 on 2022/04/24.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import Foundation
import UIKit

struct Asset: Codable{
    let id: String
    let info: [Info]
}

struct Info: Codable {
    let key: String
    let upload_url: String
}

