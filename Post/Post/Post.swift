//
//  Post.swift
//  Post
//
//  Created by Matthew O'Connor on 9/30/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import Foundation

struct Post: Codable {
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
