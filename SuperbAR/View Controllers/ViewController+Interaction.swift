//
//  ViewController+Interaction.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 12/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit


extension ViewController{
    
    //-----------------------
    //MARK: - UserInteraction
    //-----------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location & Perform An SCNHitTest To Detect Which Nodes We Have Touched
        guard let currentTouchLocation = touches.first?.location(in: self.augmentedRealityView),
            let hitTestResult = self.augmentedRealityView.hitTest(currentTouchLocation, options: nil).first?.node.name
            else { return }
        
        //2. Perform The Neccessary Action Based On The Hit Node
        switch hitTestResult {
        case "Website":
            socialLinkData = arCard.cardData.website
            displayWebSite()
        default: ()
        }
    
    }
    
    /// Loads One Of The Website From Business Card
    func displayWebSite() {
        self.performSegue(withIdentifier: "webViewer", sender: nil)
    }
}
