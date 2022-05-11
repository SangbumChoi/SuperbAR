//
//  BusinessCardData.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 11/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import Foundation

typealias SocialLinkData = (link: String, type: SocialLink)

/// The Information For The Business Card Node & Contact Details
struct ARCardData{
    var firstName: String
    var surname: String
    var website: SocialLinkData
}


/// The Type Of Social Link
///
/// - Website: Business Website
/// - StackOverFlow: StackOverFlow Account
/// - GitHub: Github Account
enum SocialLink: String{
    case Website
}
