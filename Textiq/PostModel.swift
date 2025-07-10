//
//  PostModel.swift
//  Textiq
//
//  Created by Textiq on 2024.
//

import Foundation
import SwiftUI

struct Post: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var film: String
    var label: String
    var hashtags: [String]
    var createdAt: Date
    
    init(title: String, film: String, label: String, hashtags: [String] = []) {
        self.title = title
        self.film = film
        self.label = label
        self.hashtags = hashtags
        self.createdAt = Date()
    }
    
    var formattedPost: String {
        let filmSuffix = film.isEmpty ? "" : " \(film)"
        let titleLine = "「 \(title) 」\(filmSuffix)"
        let dots = "\n.\n.\n.\n"
        let hashtagLine = hashtags.map { "#\($0)" }.joined(separator: " ")
        return titleLine + dots + hashtagLine
    }
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var availableFilms: [String] = [
        "Kodak Gold 200",
        "Kodak Portra 400",
        "Kodak Portra 800",
        "Fuji C200",
        "Fuji Pro 400H",
        "Ilford HP5",
        "Kodak Tri-X",
        "Cinestill 800T",
        "Kodak Ektar 100",
        "Fuji Velvia 50"
    ]
    @Published var availableLabels: [String] = []
    
    @Published var availableHashtags: [String] = [
        "example", "hashtags", "here"
    ]
    
    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
        saveToUserDefaults()
    }
    
    func updatePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            saveToUserDefaults()
        }
    }
    
    func deletePost(_ post: Post) {
        posts.removeAll { $0.id == post.id }
        saveToUserDefaults()
    }
    
    func addFilm(_ film: String) {
        if !availableFilms.contains(film) {
            availableFilms.append(film)
            saveToUserDefaults()
        }
    }
    
    func addLabel(_ label: String) {
        if !availableLabels.contains(label) {
            availableLabels.append(label)
            saveToUserDefaults()
        }
    }
    
    func addHashtag(_ hashtag: String) {
        let cleanHashtag = hashtag.replacingOccurrences(of: "#", with: "")
        if !availableHashtags.contains(cleanHashtag) {
            availableHashtags.append(cleanHashtag)
            saveToUserDefaults()
        }
    }
    
    func removeHashtag(_ hashtag: String) {
        availableHashtags.removeAll { $0 == hashtag }
        saveToUserDefaults()
    }
    
    func clearLabels() {
        availableLabels.removeAll()
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encoded, forKey: "SavedPosts")
        }
        UserDefaults.standard.set(availableFilms, forKey: "AvailableFilms")
        UserDefaults.standard.set(availableLabels, forKey: "AvailableLabels")
        UserDefaults.standard.set(availableHashtags, forKey: "AvailableHashtags")
    }
    
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "SavedPosts"),
           let decodedPosts = try? JSONDecoder().decode([Post].self, from: data) {
            posts = decodedPosts
        }
        
        if let films = UserDefaults.standard.array(forKey: "AvailableFilms") as? [String] {
            availableFilms = films
        }
        
        if let labels = UserDefaults.standard.array(forKey: "AvailableLabels") as? [String] {
            availableLabels = labels
        }
        
        if let hashtags = UserDefaults.standard.array(forKey: "AvailableHashtags") as? [String] {
            availableHashtags = hashtags
        }
    }
    
    init() {
        loadFromUserDefaults()
    }
}