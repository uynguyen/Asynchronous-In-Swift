//
//  ImageLoader.swift
//  PromiseKitDemo
//
//  Created by Uy Nguyen Long on 1/16/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class ImageLoader {
    func fetchImage(keyword: String) -> Promise<URL>  {
        return Promise { fullfil, reject in
            let endPoint = "http://api.giphy.com/v1/gifs/search?q=\(keyword)&limit=1&api_key=q4N1oD5jw3xvH2hIOkFAyHXWTTrh0D30"
            let headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            Alamofire.request(endPoint, headers: headers).responseData { (response) in
                if let error = response.error {
                    return reject(error)
                }
                
                let jsonData = JSON.init(data: response.data!)
                let dataArray = jsonData["data"].array
                if let dataArray = dataArray, dataArray.count > 0 {
                    let imagesList = dataArray[0]["images"]
                    let fixed_height_still = imagesList["downsized_large"]["url"].stringValue
                    return fullfil(URL.init(string: fixed_height_still)!)
                }
                return reject(NSError.init(domain: "myDomain", code: 0, userInfo: nil))
            }
        }
    }
    
    func downloadImage(url: URL) -> Promise<URL> {
        return Promise { fullfil, reject in
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(url, to: destination).downloadProgress(closure: { (progress) in
                print("\(progress)")
            }).responseData(completionHandler: { (response) in
                if let error = response.error {
                    return reject(error)
                }
                
                if let destinationURL = response.destinationURL {
                    return fullfil(destinationURL)
                }
                reject(NSError.init(domain: "myDomain", code: 0, userInfo: nil))
            })
        }
    }
}
