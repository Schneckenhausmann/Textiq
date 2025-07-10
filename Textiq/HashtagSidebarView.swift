//
//  HashtagSidebarView.swift
//  Textiq
//
//  Created by Textiq on 2024.
//

import SwiftUI

struct HashtagSidebarView: View {
    @ObservedObject var postStore: PostStore
    @Binding var selectedHashtags: [String]
    @Binding var showingHashtagInput: Bool
    @State private var hoveredHashtag: String?
    @State private var hoveredAvailableHashtag: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Title and Add Button
            HStack {
                Text("Hashtags")
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
                
                Button(action: { showingHashtagInput = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Selected Hashtags
                    if !selectedHashtags.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Selected (\(selectedHashtags.count))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(selectedHashtags, id: \.self) { hashtag in
                                    HashtagButton(
                                        hashtag: hashtag,
                                        isSelected: true,
                                        showRemove: hoveredHashtag == hashtag,
                                        onSelect: {
                                            selectedHashtags.removeAll { $0 == hashtag }
                                        }
                                    )
                                    .onHover { isHovering in
                                        hoveredHashtag = isHovering ? hashtag : nil
                                    }
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Available Hashtags
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(postStore.availableHashtags.filter { !selectedHashtags.contains($0) }, id: \.self) { hashtag in
                                HashtagButton(
                                    hashtag: hashtag,
                                    isSelected: false,
                                    showRemove: hoveredAvailableHashtag == hashtag,
                                    onSelect: {
                                        selectedHashtags.append(hashtag)
                                    },
                                    onRemove: {
                                        postStore.removeHashtag(hashtag)
                                    }
                                )
                                .onHover { isHovering in
                                    hoveredAvailableHashtag = isHovering ? hashtag : nil
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

struct HashtagButton: View {
    let hashtag: String
    let isSelected: Bool
    let showRemove: Bool
    let onSelect: () -> Void
    let onRemove: (() -> Void)?

    init(hashtag: String, isSelected: Bool, showRemove: Bool, onSelect: @escaping () -> Void, onRemove: (() -> Void)? = nil) {
        self.hashtag = hashtag
        self.isSelected = isSelected
        self.showRemove = showRemove
        self.onSelect = onSelect
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onSelect) {
                Text("#\(hashtag)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .buttonStyle(.plain)

            if showRemove {
                if isSelected {
                    Button(action: onSelect) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, -4)
                } else if let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, -4)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Group {
                if isSelected {
                    LinearGradient(
                        colors: [Color.blue, Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [Color.secondary.opacity(0.15), Color.secondary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        )
        .foregroundColor(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    isSelected ?
                    LinearGradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [Color.secondary.opacity(0.3), Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        var x: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        if !subviews.isEmpty {
            height += rowHeight
        }
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rowHeight: CGFloat = 0
        var x = bounds.minX
        var y = bounds.minY
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}