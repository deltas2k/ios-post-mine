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
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970: posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        guard let unwrappedURL = baseURL else {return}
        
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
        
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        
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
                let posts = postsDictionary.compactMap({$0.value})
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void ) {
        let post = Post(username: username, text: text)
        var postData: Data
        do{
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            completion()
            return
        }
        guard let unwrappedURL = baseURL else {return}
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            
            guard let data = data,
                let dataString = String(data: data, encoding: .utf8) else {completion(); return}
            print(dataString)
            
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    
    }
}
