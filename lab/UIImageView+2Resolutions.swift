//
//  UIImage+2Resolutions.swift
//  Flickso
//
//  Created by user on 9/16/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking

extension UIImageView {
    
    func setImageWithTwoURLS(smallImageURL:String, largeImagURL:String) {
        
        guard let smallImageURL = URL(string: smallImageURL) else {return}
        guard let largeImageURL = URL(string: largeImagURL) else {return}
        
        let smallImageReq = URLRequest(url: smallImageURL)
        
        self.setImageWith(smallImageReq, placeholderImage: nil, success: {
            (request, response, smallImage) in
            
            if response != nil {
                
                self.image = smallImage
                
                self.alpha = 0.0
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 1.0
                    
                }, completion: { (success) in
                    self.setImageWith(largeImageURL)
                })
            
            } else {
                self.setImageWith(largeImageURL)
            }
            
        }, failure: { (request, response, error) in
            
            print ("Something happened in loading image")
        })
    }
    
}
