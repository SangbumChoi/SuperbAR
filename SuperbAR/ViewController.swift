//
//  ViewController.swift
//  DynamicImage
//
//  Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ* 27/04/2019.
//  Copyright © 2019 BlackMirrorz. All rights reserved.
//

import UIKit
import ARKit

//------------------------
//MARK:- ARSCNViewDelegate
//------------------------

extension ViewController: ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

    guard let imageAnchor = anchor as? ARImageAnchor, let imageName = imageAnchor.name?.capitalized else { return }
      
          
    let referenceImage = imageAnchor.referenceImage
    // create a plan that has the same real world height and width as our detected image
    let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
    let planeNode = SCNNode(geometry: plane)
    // plane.cornerRadius = 1
    plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.9)

    /*
    `SCNPlane` is vertically oriented in its local coordinate space, but
    `ARImageAnchor` assumes the image is horizontal in its local space, so
    rotate the plane to match.
    */
    planeNode.position.x -= Float(imageAnchor.referenceImage.physicalSize.width)
      
    let profileDescriptions = ["minion":"I says) I don't work here",
                              "ljh":"I says) Alcohol is bad",
                              "Test":"O says) This is yoosful",
                              "nts":"O says) Why am I here?"]

    let text = SCNText(string: profileDescriptions[imageAnchor.referenceImage.name!], extrusionDepth: 1)
    text.font = UIFont (name: "Arial", size: 1)
    text.firstMaterial!.diffuse.contents = UIColor.black
    let textNode = SCNNode(geometry: text)

    let (min, max) = (text.boundingBox.min, text.boundingBox.max)
    let dx = min.x + 0.5 * (max.x - min.x)
    let dy = min.y + 0.5 * (max.y - min.y)
    let dz = min.z + 0.5 * (max.z - min.z)
    textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    let fontScale: Float = 0.01
    textNode.scale = SCNVector3(fontScale, fontScale, fontScale)

    // textNode.position.z -= Float(imageAnchor.referenceImage.physicalSize.height)

    textNode.eulerAngles.x = -.pi / 2
    node.addChildNode(textNode)
      
    trackingLabel.showText("\(imageName) Detected", andHideAfter: 5)
    node.addChildNode(VideoNode(withReferenceImage: imageAnchor.referenceImage))

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("test")

        }
        
        dismiss(animated: false, completion: nil)
    }
    
  
}

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



class ViewController: UIViewController {
  
    @IBOutlet weak var contentStackView: UIStackView!{
    didSet{
      contentStackView.subviews.forEach { $0.isHidden = true }
    }
    }

    @IBOutlet weak var trackingLabel: UILabel!

    @IBOutlet weak var downloadButton: UIButton!{
    didSet{
      downloadButton.layer.cornerRadius = 10
      downloadButton.layer.borderWidth = 2
      downloadButton.layer.borderColor = UIColor.white.cgColor
      downloadButton.layer.masksToBounds = true
    }
    }

    @IBOutlet weak var downloadSpinner: UIActivityIndicatorView!{
    didSet{
      downloadSpinner.alpha = 0
    }
    }

    @IBOutlet weak var downloadLabel: UILabel!{
    didSet{
      downloadLabel.text = ""
    }
    }

    @IBOutlet weak var augmentedRealityView: ARSCNView!

    var augmentedRealityConfiguration = ARImageTrackingConfiguration()
    var augmentedRealitySession = ARSession()

    //---------------------
    //MARK:- View LifeCycle
    //---------------------

    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        startARSession()
    }
  
  //-----------------------------------------
  //MARK:- Dynamic Reference Image Generation
  //-----------------------------------------
  
    /// Downloads Our Images From The Server And Initializes Our ARSession
    @IBAction func  generateImagesFromServer(){

    self.contentStackView.subviews[0].isHidden = false
    self.contentStackView.subviews[1].isHidden = true
    self.downloadSpinner.alpha = 1
    self.downloadSpinner.startAnimating()
    self.downloadLabel.text = "Downloading Images From Server"

    ImageDownloader.downloadImagesFromPaths { (result) in
      
      print(result)
        
      switch result{
        
      case .success(let dynamicConent):
        
        self.augmentedRealityConfiguration.maximumNumberOfTrackedImages = 10
        self.augmentedRealityConfiguration.trackingImages = dynamicConent
        self.augmentedRealitySession.run(self.augmentedRealityConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        
        DispatchQueue.main.async {
          
          self.downloadSpinner.alpha = 0
          self.downloadSpinner.stopAnimating()
          self.contentStackView.subviews[0].isHidden = true
          self.contentStackView.subviews[1].isHidden = false
          self.trackingLabel.showText("Images Generated Sucesfully", andHideAfter: 5)
          
        }
       
      case .failure(let error):
        
        print("An Error Occured Generating The Dynamic Reference Images \(error)")
      }
    }

    }

    @IBAction func generateImagesFromCamera(){
        self.imagePickerController.sourceType = .camera
        self.present(self.imagePickerController, animated: false, completion: nil)
    }

  //----------------
  //MARK:- ARSession
  //----------------
  func startARSession(){
    
    augmentedRealityView.session = augmentedRealitySession
    augmentedRealityView.delegate = self

    augmentedRealitySession.run(augmentedRealityConfiguration, options: [.resetTracking, .removeExistingAnchors])
    
  }
  

}
