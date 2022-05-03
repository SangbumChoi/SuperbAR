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
        let description = image.assetInfo.description
        let website = image.assetInfo.youtubeUrl
            
        //3. Load Our Business Card
        print(referenceImage.name)
        if let matchedBusinessCardName = referenceImage.name, matchedBusinessCardName == "e2ade859-6474-4b58-86e5-5c2fe0b77f61" && !arCardPlaced{
            arCardPlaced = true
//            arCard. = description
//            arCard.firstNameText =
            node.addChildNode(arCard)
            arCard.animateBusinessCard()
            targetAnchor = imageAnchor
            
        }
    }
}
