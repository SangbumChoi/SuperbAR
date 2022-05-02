//
//  ImageDownloader.swift
//  DynamicImage
//
//  Created By Josh Robbins (∩｀-´)⊃━☆ﾟ.*･｡ﾟ* 27/04/2019.
//  Copyright © 2019 BlackMirrorz. All rights reserved.
//

import Foundation
import UIKit
import ARKit

//-------------------
//MARK:- Media Suffix
//-------------------

enum FileSuffix {
  
  case JPEG, PNG
  
  /// The Type Of Extension
  var name: String{
    switch self {
    case .JPEG: return ".jpg"
    case .PNG:  return ".png"
    }
  }
}

//------------------------------
//MARK:- Reference Image Payload
//------------------------------

/// Constructor For Generating Dynamic Reference Images
struct ReferenceImagePayload{
  
  var name: String
  var extensionType: String
  var orientation: CGImagePropertyOrientation
  var widthInM: CGFloat
  
}

class ImageDownloader{
  static let endpoint = "https://e1mjfyufih.execute-api.ap-northeast-2.amazonaws.com/dev/assets"

  typealias completionHandler = (Result<Set<ARReferenceImage>, Error>) -> ()
  typealias ImageData = (image: UIImage, orientation: CGImagePropertyOrientation, physicalWidth: CGFloat, name: String)
  
  static var receivedImageData = [ImageData]()
  static var assets = [Asset]()
  static var currentImage = -1
  
  //----------------------
  //MARK:- Operation Queue
  //----------------------
  
  /// Downloads Images From A Specified Server And If Succesful Converts Them To A Set Of ARReferenceImages
  ///
  /// - Parameter completion: (Result<[UIImage], Error>)
  class func downloadImagesFromPaths(_ completion: @escaping completionHandler) {
      
      // 1. get download urls
      let url = URL(string: endpoint)
      var request = URLRequest(url: url!)
      request.httpMethod = "GET"
      request.setValue("Bearer dGVzdDEyMyE=", forHTTPHeaderField: "Authorization")
      let session = URLSession.shared
      let task = session.dataTask(with: request) { (data, response, error) in
          if error != nil {
              print(error!)
              return
          }
          let safeData = data!
//          if let json = try? JSONSerialization.jsonObject(with: safeData, options: []) as? [String : Any] {
//              print(json)
//          }

          let download = ImageDownloader.parseDownload(data: safeData)!
          assets = download.assets;
//          print(assets.map({(value: Asset) -> Info in return value.info!}))
          
          // 2. download images
          let operationQueue = OperationQueue()
          
          operationQueue.maxConcurrentOperationCount = 6
          
          let completionOperation = BlockOperation {
            
            OperationQueue.main.addOperation({
              let ids = assets.map({(value: Asset) -> String? in return value.id})
              completion(.success(referenceImageFrom(receivedImageData, ids:ids)))
            })
          }
          
          assets.forEach { (asset) in
            
          guard let url = URL(string: asset.anchor_download_url) else { return }
            
            let operation = BlockOperation(block: {
              
              do{
                
                let imageData = try Data(contentsOf: url)
                
                if let image = UIImage(data: imageData){                    
                    receivedImageData.append(ImageData(image, CGImagePropertyOrientation.up, 0.14, asset.anchor_download_url))
                }
                
              }catch{
                
                completion(.failure(error))
              }
              
            })
            
            completionOperation.addDependency(operation)
            
          }
          
          operationQueue.addOperations(completionOperation.dependencies, waitUntilFinished: false)
          operationQueue.addOperation(completionOperation)
          
      }
      task.resume()
  }
  
    class func parseDownload(data:Data) -> Download? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Download.self, from: data)
            return decodedData
        } catch{
            print(error)
            return nil
        }
    }
    
  //-------------------------------------
  //MARK:- Dynamic ARReference Generation
  //-------------------------------------
  
  /// Creates A Set Of <ARReferenceImage> From An Array Of [ImageData]
  ///
  /// - Parameter downloadedData: [ImageData]
  /// - Returns: Set<ARReferenceImage>
    class func referenceImageFrom(_ downloadedData: [ImageData], ids:[String?]) -> Set<ARReferenceImage>{
    
    var referenceImages = Set<ARReferenceImage>()
    
        downloadedData.enumerated().forEach {
          
          guard let cgImage = $1.image.cgImage else { return }
          let referenceImage = ARReferenceImage(cgImage, orientation: $1.orientation, physicalWidth: $1.physicalWidth)
          referenceImage.name = ids[$0]
          referenceImages.insert(referenceImage)
        }
    
        return referenceImages
    
  }
  
}
