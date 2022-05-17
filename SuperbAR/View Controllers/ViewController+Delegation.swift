//
//  ViewController+Delegation.swift
//  SuperbAR
//
//  Created by Sangbum Choi on 2022/05/03.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import UIKit
import ARKit


//--------------------------
//MARK: -  ARSessionDelegate
//--------------------------

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if menuShown { return }

        //1. Enumerate Our Anchors To See If We Have Found Our Target Anchor
        for anchor in anchors{

            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor{

                //2. If The ImageAnchor Is No Longer Tracked Then Reset The Business Card
                if !imageAnchor.isTracked{
                    arCardPlaced = false
                    arCard.setBaseConfiguration()
                }else{

                    //3. Layout The Card Again
                    if !arCardPlaced{
                        arCard.animateBusinessCard()
                        arCardPlaced = true
                    }
                }
            }
        }
     }
}


extension ViewController: ARSCNViewDelegate{
  
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //1. Check We Have A Valid Image Anchor
        guard let imageAnchor = anchor as? ARImageAnchor, let imageId = imageAnchor.name?.capitalized else { return }
        
        //2. Get The Detected Reference Image
        let referenceImage = imageAnchor.referenceImage
        let image = ImageDownloader.imageDict[imageId.lowercased()]!
        let name = image.assetInfo.name
        let description = image.assetInfo.description
        let website = image.assetInfo.youtubeUrl
            
        //3. Load Our Business Card
        print(website)
        if let _ = referenceImage.name, !arCardPlaced{
            arCardPlaced = true
            arCard.updateBaseConfiguration(firstName: name, surname: description, website: SocialLinkData(link: website, type: .Website))
            node.addChildNode(arCard)
            arCard.animateBusinessCard()
            targetAnchor = imageAnchor
            
        }
    }
}
