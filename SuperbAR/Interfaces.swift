//
//  Interfaces.swift
//  SuperbAR
//
//  Created by 유용환 on 2022/04/24.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import Foundation
import UIKit

struct Info: Codable {
    let name: String
    let description: String
    let youtubeUrl: String
}

struct Upload: Codable {
    let id: String
    let anchor_upload_url: String
}

struct Download: Codable {
    let assets: [Asset]
    let last_id: String?
}

struct Asset: Codable{
    let id: String
    let anchor_download_url: String
    let info: Info?
}
