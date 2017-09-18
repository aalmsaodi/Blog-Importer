//
//  DetailsVC.swift
//  lab
//
//  Created by user on 9/15/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var post:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        navigationItem.title = post["summary"] as? String

        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            
            let originalImageURL = photos[0].value(forKeyPath: "original_size.url") as! String
            
            let smallImageURL = (photos[0].value(forKeyPath: "alt_sizes.url") as! NSArray)[3] as! String
            
            pic.setImageWithTwoURLS(smallImageURL: smallImageURL, largeImagURL: originalImageURL)
        }
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pic
    }
}
