//
//  UIImage+Ext.swift
//  Dogs
//
//  Created by Nick Nguyen on 10/13/20.
//

import UIKit

extension UIImageView {

    var imageCache: NSCache<NSString,UIImage> {
        return NSCache<NSString, UIImage>()
    } 

    func imageFromServerURL(_ URLString: String, placeHolder: UIImage?) {

        self.image = nil
       
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let cachedImage = imageCache.object(forKey: NSString(string: imageServerUrl)) {
            self.image = cachedImage
            return
        }

        if let url = URL(string: imageServerUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                
                if let data = data {
                    DispatchQueue.global().async { [weak self] in
                        if let downloadedImage = UIImage(data: data) {
                            self?.imageCache.setObject(downloadedImage, forKey: NSString(string: imageServerUrl))
                            DispatchQueue.main.async {
                                self?.image = downloadedImage
                            }
                        }
                    }
                }
            }
            ).resume()
        }
    }
}
