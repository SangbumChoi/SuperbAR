//
//  ImageUploader.swift
//  SuperbAR
//
//  Created by 유용환 on 2022/04/24.
//  Copyright © 2022 Bilguun. All rights reserved.
//

import Foundation
import UIKit
import Alamofire



class ImageUploader{
    static let vc = ViewController()
    static let endpoint = "http://some-url"
    
    class func uploadImage(key:String){
        
        // 1. get upload url
        print("get upload url")
        let paramData = key.data(using: .utf8)
        let url = URL(string: endpoint + "/assets")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramData
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            let safeData = data!
            let asset = ImageUploader.parseAsset(data: safeData)
            let uploadUrl = asset!.info[0].upload_url
            
            // 2. upload image
            print("upload image")
            let screenshot = vc.outputImageView.image
            let imageData = screenshot!.jpegData(compressionQuality: 1)!
            let _ = AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(key.utf8), withName: "key")
                multipartFormData.append(imageData, withName: "imageData", fileName: key, mimeType: "image/jpg")
            }, to: uploadUrl)
            
        }
        task.resume()
        
    }
    
    class func parseAsset(data:Data) -> Asset? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Asset.self, from: data)
            return decodedData
        } catch{
            print(error)
            return nil
        }
    }
    
    class func generateBoundary() -> String {
       return "Boundary-\(NSUUID().uuidString)"
    }
}
