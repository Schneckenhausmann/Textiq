//
//  SidebarView.swift
//  Textiq
//
//  Created by Textiq on 2024.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var postStore: PostStore
    @Binding var selectedPost: Post?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Posts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                Button(action: { createNewPost() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("Create new post template")
            }
            .padding(.horizontal)
            
            // Posts List
            if postStore.posts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.below.ecg")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        Text("No posts yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Create your first social media post")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(postStore.posts) { post in
                            PostRowView(post: post, isSelected: selectedPost?.id == post.id)
                                .onTapGesture {
                                    selectedPost = post
                                }
                                .contextMenu {
                                    Button("Copy Post") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(post.formattedPost, forType: .string)
                                    }
                                    
                                    Divider()
                                    
                                    Button("Delete", role: .destructive) {
                                        postStore.deletePost(post)
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(24)
    }
    
    private func createNewPost() {
        let newPost = Post(title: "New Post Template", film: "", label: "")
        postStore.addPost(newPost)
        selectedPost = newPost
    }
}

struct PostRowView: View {
    let post: Post
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        if !post.label.isEmpty {
                            Text(post.label)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(colorForLabel(post.label))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(post.createdAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(post.createdAt, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !post.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(post.hashtags.prefix(5), id: \.self) { hashtag in
                            Text("#\(hashtag)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        if post.hashtags.count > 5 {
                            Text("+\(post.hashtags.count - 5)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(isSelected ? .accentColor : .clear),
            alignment: .leading
        )
        .contentShape(Rectangle())
    }
    
    private func colorForLabel(_ label: String) -> Color {
        let colors: [Color] = [.blue, .cyan, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .yellow]
        var hash: Int = 0
        for char in label {
            hash = Int(char.asciiValue ?? 0) + ((hash << 5) - hash)
        }
        let index = abs(hash % colors.count)
        return colors[index]
    }
}

#Preview {
    SidebarView(postStore: PostStore(), selectedPost: .constant(nil))
        .frame(width: 300, height: 600)
}