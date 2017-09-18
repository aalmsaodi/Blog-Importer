//
//  PhotosViewController.swift
//  lab
//
//  Created by user on 9/13/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts: [NSDictionary] = []
    
    let refreshController = UIRefreshControl()
    var loadingMoreView:InifiniteProgressIndicator?
    
    var isMoreDataLoading = false
    
    var postsOffsetNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        refreshController.addTarget(self, action: #selector(refreshPosts), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshController, at: 0)
        
        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        self.tableView.tableFooterView = tableFooterView

        refreshPosts()
    }
    
    
    func refreshPosts() {
        
        SVProgressHUD.show()
        
        fetchData(key: "")
        
        refreshController.endRefreshing()
    }
    
    func loadMorePosts() {
        
        postsOffsetNumber += 20
        fetchData(key: "&offset=\(postsOffsetNumber)")
        
    }
    
    func fetchData(key:String) {
        let url = URL(string:"https://api.tumblr.com/v2/blog/lvndscpe.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV\(key)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        if key.contains("offset") {
                            
                            self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                            
                            self.isMoreDataLoading = false
                            self.loadingMoreView?.stopAnimating()

                        } else {
                            self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                            SVProgressHUD.dismiss()
                        }
                        
                        self.tableView.reloadData()
                    }
                }
        });
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! PhotoCell
        let indexPath = tableView.indexPath(for: cell)
        tableView.deselectRow(at: indexPath!, animated: true)
        
        let detailsVC = segue.destination as! DetailsVC
        detailsVC.post = posts[(indexPath?.section)!]
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (!isMoreDataLoading) {
            
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                loadingMoreView?.startAnimating()
                
                loadMorePosts()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 45))
        headerView.backgroundColor = UIColor(colorLiteralRed: 0x95/0xFF, green: 0xA3/0xFF, blue: 0xA4/0xFF, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/lvndscpe.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let label = UILabel(frame: CGRect(x: 50, y: 10, width: 250, height: 30))
        label.text = posts[section].value(forKey: "date") as? String
        label.font = label.font.withSize(12)
        label.textColor = UIColor.white
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        
        let post = posts[indexPath.section]
        
        cell.summary.text = post["summary"] as? String
        
        
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            
            let originalImageURL = photos[0].value(forKeyPath: "original_size.url") as! String
            
            let smallImageURL = (photos[0].value(forKeyPath: "alt_sizes.url") as! NSArray)[3] as! String
                
                cell.pic.setImageWithTwoURLS(smallImageURL: smallImageURL, largeImagURL: originalImageURL)
        }
        
        return cell
    }
   
}
