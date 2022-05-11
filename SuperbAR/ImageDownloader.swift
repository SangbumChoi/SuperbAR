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
  typealias ImageData = (image: UIImage, orientation: CGImagePropertyOrientation, physicalWidth: CGFloat, name: String, id: String)
  typealias Image = (imageData: ImageData?, assetInfo:Info)

  static var imageDict: [String:Image] = [String: Image]()
  static var receivedImageData = [ImageData]()
  
  //----------------------
  //MARK:- Operation Queue
  //----------------------
  
  /// Downloads Images From A Specified Server And If Succesful Converts Them To A Set Of ARReferenceImages
  ///
  /// - Parameter completion: (Result<[UIImage], Error>)
  class func downloadImagesFromPaths(_ completion: @escaping completionHandler) {
      
//      print(imageDict.keys.count)
//      print(receivedImageData.count)
//
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
          let download = ImageDownloader.parseDownload(data: safeData)!
          let assets = download.assets;
          for asset in assets{
              imageDict[asset.id] = Image(imageData:nil, assetInfo:asset.info!)
          }
          
          // 2. download images
          let operationQueue = OperationQueue()
          
          operationQueue.maxConcurrentOperationCount = 6
          
          let completionOperation = BlockOperation {
            
            OperationQueue.main.addOperation({
              completion(.success(referenceImageFrom(receivedImageData)))
            })
          }
          
          assets.forEach { (asset) in
            
          guard let url = URL(string: asset.anchor_download_url) else { return }
            
            let operation = BlockOperation(block: {
              
              do{
                
                let imageData = try Data(contentsOf: url)
                if let image = UIImage(data: imageData){
                    let imageData = ImageData(image, CGImagePropertyOrientation.up, 0.14, asset.anchor_download_url, asset.id)
                    print(imageData)
                    receivedImageData.append(imageData)
                    imageDict[asset.id]!.imageData = imageData
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
    class func referenceImageFrom(_ downloadedData: [ImageData]) -> Set<ARReferenceImage>{
    var referenceImages = Set<ARReferenceImage>()
    downloadedData.enumerated().forEach { (index, imageData) in
        guard let cgImage = imageData.image.cgImage else { return }
        let referenceImage = ARReferenceImage(cgImage, orientation: imageData.orientation, physicalWidth: imageData.physicalWidth)
        referenceImage.name = imageData.id
        referenceImages.insert(referenceImage)
        }
    return referenceImages
    }
}
