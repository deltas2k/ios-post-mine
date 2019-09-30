//
//  PostController.swift
//  Post
//
//  Created by Matthew O'Connor on 9/30/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import Foundation

class PostController {
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(completion: @escaping () -> Void) {
        guard let unwrappedURL = baseURL else {return}
        let getterEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            
            guard let data = data else { completion(); return }
            
            let jsonDecoder = JSONDecoder()
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: { $0.timestamp > $1.timestamp })
                self.posts = posts
                completion()
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
        }
        dataTask.resume()
    }
}
