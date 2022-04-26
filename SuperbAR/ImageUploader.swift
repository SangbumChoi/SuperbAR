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
    static let endpoint = "https://913kay4rbi.execute-api.ap-northeast-2.amazonaws.com"
    
    class func uploadImage(key:String, image:UIImage){
        
        // 1. get upload url
        print("get upload url")
        let url = URL(string: endpoint + "/uploads")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            let safeData = data!
            let upload = ImageUploader.parseUpload(data: safeData)!
            let uploadUrl = upload.uploadURL
//            let key = upload.Key
            
            // 2. upload image
            print("upload image")
            let imageData = image.jpegData(compressionQuality: 1)!
            print(uploadUrl)
            print(imageData)
//            let _ = AF.upload(multipartFormData: { multipartFormData in
//                multipartFormData.append(imageData, withName: "imageData", fileName: key, mimeType: "image/jpg")
//            }, to: uploadUrl, method: HTTPMethod.put)
            AF.upload(imageData, to: uploadUrl, method: HTTPMethod.put)
                .responseString() { response in
                    switch response.result {
                    case .success:
                        print("done")
                    case .failure(let error):
                        print(error)
                    }
                }
            
        }
        task.resume()
        
    }
    
    class func parseUpload(data:Data) -> Upload? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Upload.self, from: data)
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
