# AudioFetchGPT Documentation

## Overview

AudioFetchGPT is an iOS application designed to interact with ChatGPT, allowing users to download and manage audio content from conversations. The app provides a web interface to ChatGPT, audio playback capabilities, and a download management system.

## Key Features

1. Web Interface: Integrates a WebView to interact with ChatGPT.
2. Audio Download: Captures and downloads audio content from ChatGPT conversations.
3. Audio Playback: Allows users to play, pause, and seek through downloaded audio files.
4. Download Management: Provides a list view of downloaded audio files with editing and deletion capabilities.
5. Search Functionality: Enables users to search within the ChatGPT interface.
6. Background Audio: Supports background audio playback and control through the iOS audio session.

## Main Components

### WebView

- `WebView.swift`: UIViewRepresentable struct that wraps a WKWebView for displaying ChatGPT.
- `WebViewModel.swift`: Manages the WebView's configuration and JavaScript interactions.
- `ScriptMessageHandler.swift`: Handles messages from JavaScript for audio download.

### Audio Management

- `AudioManager.swift`: Central manager for audio playback and control.
- `AudioPlayerManager.swift`: Manages the AVAudioPlayer for actual audio playback.
- `AudioProgressManager.swift`: Tracks and stores progress for each audio file.
- `AudioTimerManager.swift`: Manages timers for updating audio progress.

### Models

- `DownloadedAudio.swift`: Represents a downloaded audio file.
- `DownloadedAudios.swift`: Manages the collection of downloaded audio files.

### Views

- `ContentView.swift`: Main view of the application.
- `DownloadListView.swift`: Displays the list of downloaded audio files.
- `AudioRowView.swift`: Individual row view for each audio file in the list.
- `AudioDetailsView.swift`: Detailed view for a single audio file.

## Key Functionalities

1. **Audio Download**: The app injects a JavaScript script into the WebView to intercept audio synthesis requests. When an audio file is generated, it's captured and downloaded to the device.

2. **Audio Playback**: Users can play, pause, and seek through downloaded audio files. The app supports background audio and integrates with the iOS audio session for system-wide audio controls.

3. **Download Management**: Users can view, rename, and delete downloaded audio files. The app maintains a list of downloads and their metadata.

4. **Web Interaction**: The app provides a custom interface for interacting with ChatGPT, including search functionality and the ability to navigate to specific messages.

5. **State Management**: The app uses SwiftUI's state management features (@State, @ObservedObject, @EnvironmentObject) to maintain and update the UI based on user interactions and audio playback status.

## Input and Output

### Inputs
- User interactions with the ChatGPT interface
- Audio playback controls (play, pause, seek)
- Download management actions (rename, delete)
- Search queries

### Outputs
- Rendered WebView of ChatGPT
- List of downloaded audio files
- Audio playback
- Visual feedback for user actions (notifications, UI updates)

## Usage

The app is designed to be used as a ChatGPT client with enhanced audio capabilities. Users can interact with ChatGPT as normal, with the added ability to download and manage audio content generated during conversations. The downloaded audio can be played back at any time, even without an internet connection.
