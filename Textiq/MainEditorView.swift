//
//  MainEditorView.swift
//  Textiq
//
//  Created by Textiq on 2024.
//

import SwiftUI

struct MainEditorView: View {
    @ObservedObject var postStore: PostStore
    @Binding var selectedPost: Post?
    @Binding var selectedHashtags: [String]
    @Binding var showingHashtagInput: Bool
    @State private var selectedLabel = ""
    @State private var selectedFilm = ""
    @State private var titleText = ""
    @State private var newHashtag = ""
    @State private var showingLabelInput = false
    @State private var showingFilmInput = false
    @State private var newLabel = ""
    @State private var newFilm = ""
    @State private var justCopied = false

    
    var body: some View {
        HStack(spacing: 0) {
            // Main Content Area
            ScrollView {
                VStack(spacing: 24) {
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button("Clear All") {
                                titleText = ""
                                selectedHashtags.removeAll()
                                selectedFilm = ""
                                selectedLabel = ""
                                selectedPost = nil
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            
                            Spacer()
                            
                            Button("Save Post") {
                                if let existingPost = selectedPost {
                                    // Update existing post
                                    let updatedPost = createUpdatedPost(from: existingPost)
                                    postStore.updatePost(updatedPost)
                                } else {
                                    // Create new post
                                    let post = createCurrentPost()
                                    postStore.addPost(post)
                                }
                                
                                // Clear form
                                titleText = ""
                                selectedHashtags.removeAll()
                                selectedFilm = ""
                                selectedLabel = ""
                                selectedPost = nil
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(titleText.isEmpty)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Post Preview
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Preview")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            if justCopied {
                                Text("Copied!")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .transition(.opacity.combined(with: .scale))

                            }
                            
                            Button(justCopied ? "" : "Copy") {
                                let post = createCurrentPost()
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(post.formattedPost, forType: .string)
                                
                                withAnimation {
                                    justCopied = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        justCopied = false
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(titleText.isEmpty)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            let previewTitle = createCurrentPost().formattedPost.components(separatedBy: "\n").first ?? ""
                            Text(previewTitle.isEmpty ? "「 Your title here 」" : previewTitle)
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(titleText.isEmpty ? .secondary : .primary)
                            
                            Text(".\n.\n.")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if !selectedHashtags.isEmpty {
                                Text(selectedHashtags.map { "#\($0)" }.joined(separator: " "))
                                    .font(.body)
                                    .foregroundColor(.blue)
                            } else {
                                Text("Add hashtags below")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Color(NSColor.textBackgroundColor), Color(NSColor.textBackgroundColor).opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        HStack {
                            TextField("Enter your title", text: $titleText)
                                .textFieldStyle(.roundedBorder)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(NSColor.textBackgroundColor).opacity(0.8))
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                            
                            Button("Add Spacer") {
                                titleText += " ‎ ‎ "
                            }
                            .buttonStyle(.bordered)
                            .help("Add special spacing for social media posts")
                        }
                        
                        Text("Tip: Use the 'Add Spacer' button to insert special spacing for social media posts.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        

                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(NSColor.controlBackgroundColor).opacity(0.5), Color(NSColor.controlBackgroundColor).opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Film and Label Selection
                    HStack(spacing: 16) {
                        // Film Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Film")
                                .font(.headline)
                                .fontWeight(.semibold)

                            HStack {
                                Picker("Select Film", selection: $selectedFilm) {
                                    Text("No Film").tag("")
                                    ForEach(postStore.availableFilms, id: \.self) { film in
                                        Text(film).tag(film)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()

                                Spacer()

                                Button(action: { showingFilmInput = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.controlBackgroundColor))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Label Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Label")
                                .font(.headline)
                                .fontWeight(.semibold)

                            HStack {
                                Picker("Select Label", selection: $selectedLabel) {
                                    Text("No Label").tag("")
                                    ForEach(postStore.availableLabels, id: \.self) { label in
                                        Text(label).tag(label)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()

                                Spacer()

                                Button(action: { showingLabelInput = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.controlBackgroundColor))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(24)
            }
            

        }

        .sheet(isPresented: $showingLabelInput) {
            LabelInputSheet(postStore: postStore, newLabel: $newLabel)
        }
        .sheet(isPresented: $showingFilmInput) {
            FilmInputSheet(postStore: postStore, newFilm: $newFilm)
        }
        .sheet(isPresented: $showingHashtagInput) {
            HashtagInputSheet(postStore: postStore, newHashtag: $newHashtag)
        }
        .onChange(of: selectedPost) { _, newPost in
            if let post = newPost {
                loadPost(post)
            }
        }
    }
    
    private func createCurrentPost() -> Post {
        return Post(title: titleText, film: selectedFilm, label: selectedLabel, hashtags: selectedHashtags)
    }
    
    private func createUpdatedPost(from existingPost: Post) -> Post {
        var updatedPost = existingPost
        updatedPost.title = titleText
        updatedPost.film = selectedFilm
        updatedPost.label = selectedLabel
        updatedPost.hashtags = selectedHashtags
        return updatedPost
    }
    
    private func loadPost(_ post: Post) {
        titleText = post.title
        selectedFilm = post.film
        selectedLabel = post.label
        selectedHashtags = post.hashtags
    }
}




struct LabelInputSheet: View {
    @ObservedObject var postStore: PostStore
    @Binding var newLabel: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Custom Label")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Enter label", text: $newLabel)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addLabel()
                }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add") {
                    addLabel()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    private func addLabel() {
        let cleanLabel = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanLabel.isEmpty {
            postStore.addLabel(cleanLabel)
            newLabel = ""
            dismiss()
        }
    }
}

struct HashtagInputSheet: View {
    @ObservedObject var postStore: PostStore
    @Binding var newHashtag: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Custom Hashtag")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Enter hashtag (without #)", text: $newHashtag)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addHashtag()
                }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add") {
                    addHashtag()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newHashtag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    private func addHashtag() {
        let cleanHashtag = newHashtag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanHashtag.isEmpty {
            postStore.addHashtag(cleanHashtag)
            newHashtag = ""
            dismiss()
        }
    }
}

struct FilmInputSheet: View {
    @ObservedObject var postStore: PostStore
    @Binding var newFilm: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Custom Film")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Enter film name", text: $newFilm)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addFilm()
                }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add") {
                    addFilm()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newFilm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    private func addFilm() {
        let cleanFilm = newFilm.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanFilm.isEmpty {
            postStore.addFilm(cleanFilm)
            newFilm = ""
            dismiss()
        }
    }
}

#Preview {
    MainEditorView(postStore: PostStore(), selectedPost: .constant(nil), selectedHashtags: .constant([]), showingHashtagInput: .constant(false))
        .frame(width: 900, height: 800)
}