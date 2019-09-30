//
//  PostListViewController.swift
//  Post
//
//  Created by Matthew O'Connor on 9/30/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let postController = PostController()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var PostListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PostListTableView.delegate = self
        PostListTableView.dataSource = self
        PostListTableView.estimatedRowHeight = 45
        PostListTableView.rowHeight = UITableView.automaticDimension
        PostListTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            // Add networkActivityIndiator to the reloadView function
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.PostListTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }

}
