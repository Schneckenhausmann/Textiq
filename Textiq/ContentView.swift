//
//  ContentView.swift
//  Textiq
//
//  Created by Textiq on 2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var postStore = PostStore()
    @State private var sidebarVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedPost: Post?
    @State private var selectedHashtags: [String] = []
    @State private var showingHashtagInput = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            // Left Sidebar - Posts
            SidebarView(postStore: postStore, selectedPost: $selectedPost)
                .frame(minWidth: 250, maxWidth: 300)
        } content: {
        // Main Editor with Header
        VStack(spacing: 0) {
            // App Header with Logo
            VStack(spacing: 8) {
                Image("icon_512x512")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 4)

                Text("Textiq")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Professional Social Media Post Creator")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color(NSColor.controlBackgroundColor),
                        Color(NSColor.controlBackgroundColor).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ),
                alignment: .bottom
            )
            
            Divider()
            
            // Main Editor Content
            MainEditorView(postStore: postStore, selectedPost: $selectedPost, selectedHashtags: $selectedHashtags, showingHashtagInput: $showingHashtagInput)
        }
        .frame(minWidth: 600)
    } detail: {
        // Right Sidebar - Hashtags
        HashtagSidebarView(postStore: postStore, selectedHashtags: $selectedHashtags, showingHashtagInput: $showingHashtagInput)
            .frame(minWidth: 300, maxWidth: 400)
    }
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(.dark)
        .frame(minWidth: 1150, minHeight: 700)
    }
}

#Preview {
    ContentView()
        .frame(width: 1200, height: 800)
}
