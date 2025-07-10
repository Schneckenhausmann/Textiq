# Textiq Technical Documentation

## 1. Introduction

Textiq is a SwiftUI-based macOS application designed to streamline the process of creating formatted text posts for social media. It provides a user-friendly interface for composing a title, adding relevant metadata like film stock and labels, and managing a collection of hashtags. The application's primary function is to generate a formatted string that can be easily copied and pasted into various social media platforms, preserving specific spacing and structure.

## 2. Architecture

The application follows a data flow pattern similar to MVVM (Model-View-ViewModel), leveraging SwiftUI's declarative syntax and data-binding features.

-   **Model**: The `Post` struct (`PostModel.swift`) represents the core data object of the application.
-   **View**: The UI is composed of several SwiftUI `View`s (`ContentView`, `MainEditorView`, `SidebarView`, etc.) that are responsible for presenting the data and capturing user input.
-   **ViewModel/Store**: The `PostStore` class (`PostModel.swift`) acts as the single source of truth for the application's data. It is an `ObservableObject` that manages the collection of posts and other shared data, handling all data manipulation and persistence logic.

### Data Flow

Data flow is managed through a combination of SwiftUI property wrappers:

-   `@State`: Manages transient, view-specific state (e.g., the text in an input field).
-   `@ObservedObject`: Used to subscribe to the `PostStore`, allowing views to react to changes in the application's data.
-   `@Binding`: Creates a two-way connection between a parent view's state and a child view's property, allowing child views to modify the state of their parent.

## 3. Core Components

### `TextiqApp.swift`

This is the main entry point for the application.

-   **`@main`**: The `TextiqApp` struct conforms to the `App` protocol, marking it as the application's launch point.
-   **`WindowGroup`**: It defines the main scene for the application, which contains the root view, `ContentView`.
-   **View Modifiers**: It sets global properties for the window, such as the default size and hiding the title bar for a cleaner, more modern UI.

### `ContentView.swift`

This view serves as the main container for the application's UI, structuring the different components.

-   **`NavigationSplitView`**: This is the root layout element, creating a multi-column interface that is ideal for this type of application.
-   **View Integration**: It instantiates and coordinates the three main panels of the app:
    1.  `SidebarView`: For listing and managing posts.
    2.  `MainEditorView`: The primary content creation and editing area.
    3.  `HashtagSidebarView`: For managing hashtags.
-   **State Management**: It holds the state for the currently `selectedPost` and the `selectedHashtags` for the post being edited, passing this state down to child views using `@Binding`.

### `SidebarView.swift`

This view displays the list of all created posts.

-   **`@ObservedObject var postStore`**: It observes the `PostStore` to get the list of posts.
-   **`List`**: It iterates over `postStore.posts` to display each post. Tapping a post updates the `selectedPost` binding in `ContentView`.
-   **Functionality**: Provides buttons to add a new post (which clears the editor) and to delete the currently selected post.

### `MainEditorView.swift`

This is the most complex view and the central workspace for the user.

-   **State**: Manages local state for the editor fields, such as `titleText`, `selectedFilm`, and `selectedLabel`.
-   **Post Preview**: Displays a real-time preview of the formatted post. It calls `createCurrentPost()` to generate a temporary `Post` object and then accesses its `formattedPost` property.
-   **Title Input**: A `TextField` bound to `titleText`.
-   **Add Spacer Button**: A crucial feature that inserts a special Unicode character string (`" ‎ ‎ "`). This string is often used on platforms like Instagram to create line breaks or visual separation where standard spaces might be collapsed.
-   **Pickers**: Uses `Picker` views to select a film and a label from the lists provided by `PostStore`.
-   **Sheet Views**: Implements `.sheet` modifiers to present modal views for adding new, custom films, labels, or hashtags to the `PostStore`.
-   **Methods**:
    -   `createCurrentPost() -> Post`: Creates a new `Post` instance from the current data in the editor fields.
    -   `loadPost(_ post: Post)`: Populates the editor fields with the data from an existing `Post` when it's selected in the sidebar.

### `HashtagSidebarView.swift`

This view provides an interface for managing hashtags for the current post.

-   **Layout**: It's split into two sections: "Selected Hashtags" and "Available Hashtags".
-   **`FlowLayout`**: A custom layout container is used to display the hashtags as a collection of dynamically wrapping tags, which is more space-efficient than a simple `HStack` or `VStack`.
-   **`HashtagButton`**: A reusable button view for each hashtag. Tapping a hashtag moves it between the "selected" and "available" lists.

### `PostModel.swift`

This file contains the data model and the data management logic for the entire application.

-   **`Post` Struct**:
    -   Conforms to `Identifiable` (for use in `List`), `Codable` (for persistence), and `Equatable`.
    -   Properties: `id`, `title`, `film`, `label`, `hashtags`, `createdAt`.
    -   **`formattedPost: String`**: A computed property that assembles the final, formatted string. It combines the title, film, a static series of dots, and the list of hashtags into the desired output format.

-   **`PostStore` Class**:
    -   Conforms to `ObservableObject` to allow SwiftUI views to subscribe to its changes.
    -   **`@Published` Properties**: All arrays (`posts`, `availableFilms`, `availableLabels`, `availableHashtags`) are marked as `@Published`, so any modification to them will automatically trigger a UI update in any observing view.
    -   **CRUD Operations**: Contains methods to add, update, and delete posts, as well as manage the lists of available films, labels, and hashtags.
    -   **Persistence**: Implements `saveToUserDefaults()` and `loadFromUserDefaults()`.
        -   The `posts` array is encoded to JSON data using `JSONEncoder` before being saved.
        -   On load, the JSON data is read and decoded back into an array of `Post` objects using `JSONDecoder`.
        -   Other arrays are saved directly to `UserDefaults`.