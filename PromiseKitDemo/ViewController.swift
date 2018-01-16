//
//  ViewController.swift
//  PromiseKitDemo
//
//  Created by Uy Nguyen Long on 1/16/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import PromiseKit

class ViewController: UIViewController {

    @IBOutlet weak var txtKeyword: UITextField!
    @IBOutlet weak var imgImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func searchImageWithKeyword(keyword: String) {
        let imageLoader = ImageLoader()
        firstly {
            imageLoader.fetchImage(keyword: keyword)
        }.then {  downloadLink -> Promise<URL> in
            return imageLoader.downloadImage(url: downloadLink)
        }.then {downloadedURL -> Void in
            self.updateImageAtURL(url: downloadedURL)
        }.catch { error in
            print("Error \(error)")
        }
    }
    
    func updateImageAtURL(url: URL) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateImageAtURL(url: url)
            }
            return
        }
        do {
            let data = try Data.init(contentsOf: url)
            self.imgImage.image = UIImage.gif(data: data)
        }
        catch {
            print("Error \(error)")
        }
    }

    @IBAction func btnSearchTouchDown(_ sender: Any) {
        self.searchImageWithKeyword(keyword: self.txtKeyword.text!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

