//
//  ViewController.swift
//  DynamicImage
//
//  Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ* 27/04/2019.
//  Copyright © 2019 BlackMirrorz. All rights reserved.
//

import UIKit
import ARKit
import WebKit
import Foundation
import SideMenu


//------------------------
//MARK:- Making UILabel custom function
//------------------------

extension UILabel{
  
    /// Updates The Text And Hides It After A Delay
    ///
    /// - Parameters:
    ///   - text: String
    ///   - delay: Double
    func showText(_ text: String, andHideAfter delay: Double){
    DispatchQueue.main.async {
        self.text = text
        self.alpha = 1
        UIView.animate(withDuration: delay, animations: { self.alpha = 0 } )
    }
    }
}


class ViewController: UIViewController, SideMenuNavigationControllerDelegate {
    @IBOutlet weak var augmentedRealityView: ARSCNView!
    
    var augmentedRealityConfiguration = ARImageTrackingConfiguration()
    var augmentedRealitySession = ARSession()
    var referenceImages = Set<ARReferenceImage>()
    var targetAnchor: ARImageAnchor?
    
    var arCardPlaced = false
    var arCard: ARCard!
    var socialLinkData: SocialLinkData?
    
    var menuShown = false
    
    //---------------------
    //MARK:- View LifeCycle
    //---------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        //1. Format The SideMenu Which Will Be Used To Display The Associates WebSites
//        SideMenuManager.default.menuWidth = self.view.bounds.width * 0.5
//        SideMenuManager.default.menuPresentMode = .menuSlideIn
//        SideMenuManager.default.menuFadeStatusBar = false
        
        // outputImageView.isHidden = true
        setupBusinessCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !menuShown {setupARSession()}
        socialLinkData = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SecondViewController{
            guard let vc = segue.destination as? SecondViewController else {return}
            vc.snapshotImage = augmentedRealityView.snapshot()
        }
        
        if segue.identifier == "webViewr",
           let sideMenu = segue.destination as? SideMenuNavigationController,
           let mapWebView = sideMenu.children.first as? MapWebViewController{
           
           sideMenu.sideMenuDelegate = self
           
           if let validLink = socialLinkData{
        
               switch validLink.type{
                   
               case .Website:
                   mapWebView.webAddress = arCard.cardData.website.link
                   mapWebView.navigationItem.title = "Website"
               }
               
           }
       }
    }

    @IBAction func takeScreenshotAction(_ sender: Any) {
        performSegue(withIdentifier: "FirstToSecond", sender: nil)
    }
    
    //-----------------------------------------
    //MARK:- Dynamic Reference Image Generation
    //-----------------------------------------
  
    /// Downloads Our Images From The Server And Initializes Our ARSession
    @IBAction func  generateImagesFromServer(){

        ImageDownloader.receivedImageData.removeAll()
        ImageDownloader.imageDict.removeAll()
    
        ImageDownloader.downloadImagesFromPaths { (result) in
            switch result{
                case .success(let dynamicConent):
                    self.augmentedRealityConfiguration.maximumNumberOfTrackedImages = 5
                    self.augmentedRealityConfiguration.trackingImages = dynamicConent
                    self.augmentedRealitySession.run(self.augmentedRealityConfiguration, options: [.resetTracking, .removeExistingAnchors])

                case .failure(let error):
                    print("An Error Occured While Downloading Images \(error)")
            }
        }
    }

    //----------------
    //MARK:- ARSession
    //----------------
    func setupARSession(){
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        augmentedRealitySession.run(augmentedRealityConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /// Create A Business Card
    func setupBusinessCard(){
        //1. Create Our Business Card
        let arCardData = ARCardData(firstName: "",
                                    surname: "",
                                    website: SocialLinkData(link: "", type: .Website)
        )
        
        //2. Assign It To The Business Card Node
        arCard = ARCard(data: arCardData, cardType: .noProfileImage)
    }
    
}
