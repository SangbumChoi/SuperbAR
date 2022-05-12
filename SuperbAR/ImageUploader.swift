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
    static let endpoint = "https://e1mjfyufih.execute-api.ap-northeast-2.amazonaws.com/dev/assets"
    
    class func uploadImage(name:String, image:UIImage, description:String = "some description", youtubeUrl:String = "some url"){
        
        let imageData = image.jpegData(compressionQuality: 1)!
        let imageSize: Int = imageData.count
        
        
        // 1. get upload url
        let url = URL(string: endpoint)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Bearer dGVzdDEyMyE=", forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["anchor_size":imageSize,"info": [ "name": name, "description":description, "youtubeUrl":youtubeUrl]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            let safeData = data!
            
//            let responseJSON = try? JSONSerialization.jsonObject(with: safeData, options: [])
            
            let upload = ImageUploader.parseUpload(data: safeData)!
            let uploadUrl = upload.anchor_upload_url

            // 2. upload image
            AF.upload(imageData, to:uploadUrl, method: HTTPMethod.put) //uploadUrlStr: upload url in your case
                .validate()
                .responseData(emptyResponseCodes: [200, 204, 205]) { response in
                    // Process response.
                    print(response)
                  }
        }
        task.resume()
        
    }
    
//    class func serializeUpload(data:Data) ->  {
//        let encoder = JSONEncoder()
//        do{
//            let encodedData = try encoder.encode(data)
//            return encodedData
//        } catch{
//            print(error)
//            return nil
//        }
//    }

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
