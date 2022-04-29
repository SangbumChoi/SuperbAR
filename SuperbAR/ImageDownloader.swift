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
  static let endpoint = "https://913kay4rbi.execute-api.ap-northeast-2.amazonaws.com"

  typealias completionHandler = (Result<Set<ARReferenceImage>, Error>) -> ()
  typealias ImageData = (image: UIImage, orientation: CGImagePropertyOrientation, physicalWidth: CGFloat, name: String)
  
  static var receivedImageData = [ImageData]()
  
  //----------------------
  //MARK:- Operation Queue
  //----------------------
  
  /// Downloads Images From A Specified Server And If Succesful Converts Them To A Set Of ARReferenceImages
  ///
  /// - Parameter completion: (Result<[UIImage], Error>)
  class func downloadImagesFromPaths(_ completion: @escaping completionHandler) {
      
      // 1. get download urls
      let ep =  endpoint + "/downloads"
      print(ep)
      let url = URL(string: ep)
      var request = URLRequest(url: url!)
      request.httpMethod = "GET"
      let session = URLSession.shared
      let task = session.dataTask(with: request) { (data, response, error) in
          if error != nil {
              print(error!)
              return
          }
          let safeData = data!
          print(safeData)
          
          let download = ImageDownloader.parseDownload(data: safeData)!
          let downloadURLs = download.downloadURLs;
          print(downloadURLs)
          // 2. download images
          let operationQueue = OperationQueue()
          
          operationQueue.maxConcurrentOperationCount = 6
          
          let completionOperation = BlockOperation {
            
            OperationQueue.main.addOperation({
              
              completion(.success(referenceImageFrom(receivedImageData)))
              
            })
          }
          
          downloadURLs.forEach { (downloadURL) in
            
            guard let url = URL(string: downloadURL) else { return }
            
            let operation = BlockOperation(block: {
              
              do{
                
                let imageData = try Data(contentsOf: url)
                
                if let image = UIImage(data: imageData){
//                image: UIImage, orientation: CGImagePropertyOrientation, physicalWidth: CGFloat, name: String
                    
                    receivedImageData.append(ImageData(image, CGImagePropertyOrientation.up, 0.14, downloadURL))
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
    
    downloadedData.forEach {
      
      guard let cgImage = $0.image.cgImage else { return }
      let referenceImage = ARReferenceImage(cgImage, orientation: $0.orientation, physicalWidth: $0.physicalWidth)
      referenceImage.name = $0.name
      referenceImages.insert(referenceImage)
    }
    
    return referenceImages
    
  }
  
}
