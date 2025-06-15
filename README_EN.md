# Kanada Music Player: Enjoy the Ultimate Music Experience

![Android Download](https://img.shields.io/badge/Android-v1.0.0-blue?logo=android)

[简体中文](README.md) | [English](README_EN.md)


## 🌿 Overview
Kanada Music Player is a lightweight music application deeply customized for Android devices. With a core design philosophy of "simplicity and usability", it integrates diverse playback functions and intelligent interactive experiences, perfectly adapting to both relaxing melodies in leisure time and energetic rhythms during workouts. Supporting mainstream audio format parsing, dynamic lyric display, and smart control logic, it creates an immersive music experience for users.


## 🚀 Key Features


### 🎵 Diverse Music Playback System
- **Full-format Audio Support**: Seamlessly compatible with MP3, FLAC, and other mainstream formats. Plans to expand support for lossless formats like APE and WAV to meet the needs of high-quality music enthusiasts.
- **Intelligent Playlist Management**: Allows custom playlists sorted by mood, scenario, or genre, enabling easy creation of personalized collections like "Work Focus Playlist" or "Party Anthems".
- **Flexible Play Modes**: Offers three playback modes—Single Loop, Queue Loop, and Shuffle—to suit different listening scenarios.
- **Cross-platform Playlist Integration**: Supports one-click import of NetEase Cloud Music playlists. Future updates will integrate APIs from QQ Music, Kugou Music, and other platforms for cross-platform playlist synchronization.


### 📝 Immersive Lyric Experience
- **Real-time Lyric Scrolling**: Lyrics scroll precisely in sync with the music, enhancing karaoke-style singing experiences—whether joining a concert chorus or enjoying home karaoke, users can immerse in the music's emotion.
- **External Lyric Display Support**: Compatible with external display devices (e.g., car screens, projectors) via a companion app. Future updates will optimize lyric animations and special effects.


### ⚙️ Smart Interactive Controls
- **Auto Pause on Mute**: When the device is muted, the player automatically pauses to prevent power consumption and disturbance, resuming quickly when sound is reactivated.
- **Intelligent Headphone Detection**: Pauses playback immediately upon detecting headphone disconnection, avoiding unexpected audio外放 and conserving battery.


## 📥 Download & Installation Guide

### Official Version Installation Steps
1. **Get the APK File**: [Download the Latest Version](https://github.com/xiaocaoooo/Kanada/releases/latest/download/app-release.apk). Ensure a stable network connection.
2. **Enable Unknown Sources**: Go to your phone's `Settings` → `Security` and enable "Unknown Sources" (required for installations outside official app stores).
3. **Install the App**: Locate the downloaded APK in your file manager, tap to install. Once installed, launch Kanada from your home screen or app list.


## 📖 Quick Start Guide

### 1. Import Music
- **Local Folder Scanning**: Go to `Settings` → `Folder Management`, add your local music folder, and the system will automatically scan and import audio files.
- **NetEase Cloud Playlist Import**: Enter the playlist link or ID in `Folder Management` to sync NetEase playlists to your local library.

### 2. Playback Controls
- **Instant Playback**: Tap a song in the music library to start playing. The playback interface displays real-time metadata like cover art, title, and artist.
- **Progress Adjustment**: Slide the progress bar on the playback screen to navigate to specific parts of the song.

### 3. Lyric Settings
- **Lyric Interface**: Swipe left on the playback screen to enter the lyric page, supporting real-time scrolling.
- **Font Customization**: Adjust lyric font size in the settings to suit your visual preferences.


## ❓ FAQ

### ▶ Why can't the app find my local music?
Storage permission might be disabled. Go to your phone's `Settings` → `Apps` → `Kanada`, enable "Storage Access Permission", then restart the app to rescan.

### ▶ How to connect an external lyric display?
Install the companion app [Lyric-Getter](https://github.com/xiaowine/Lyric-Getter/releases/latest) first. Follow the in-app instructions to pair it with Kanada.

### ▶ Why is NetEase playlist import failing?
Check your network connection and verify the playlist link/ID. If the issue persists, it may be due to temporary NetEase API exceptions or private playlist settings. Try a different playlist or retry later.

### ▶ How to fix playback lag?
Close background apps to free up memory, or check if audio files are corrupted. For lossless format lag, device performance issues may occur—try converting to MP3 format.


## 📜 Open Source Statement
This project is open source under the [GPLv3 License](LICENSE), allowing users to freely use, modify, and share the code. We welcome developers to contribute by submitting Issues or Pull Requests. The official version ensures a pure experience with no ads or in-app purchases.


## 🤝 Contribution & Feedback
To report issues or suggest improvements:
- Submit an Issue on the [GitHub Repository](https://github.com/xiaocaoooo/Kanada) with detailed descriptions.
- Contribute code directly via Pull Requests to help iterate on features.

We value every user feedback and will continuously optimize the experience. Thank you for choosing Kanada—let music accompany every moment!


## 🔧 Technical Architecture & Dependencies
### Architecture Design
Adopts a modular architecture with core components:
- **Playback Engine**: Implements audio decoding and control based on the `just_audio` library.
- **Lyric Processing**: Custom parser combined with `kanada_lyric_sender` plugin for lyric synchronization and external display.
- **Metadata Management**: Retrieves song information and cover art via the `Metadata` class.
- **Settings System**: Manages user preferences through the `Settings` class.

### Key Dependencies
- `just_audio`: Core audio playback library
- `kanada_lyric_sender`: Lyric synchronization plugin
- `http`: Network module for playlist/lyric fetching
- `path_provider`: Storage path management for lyric/cover caching


## 📌 Future Plans
- **Format Expansion**: Add support for lossless formats like APE and WAV to cater to Hi-Fi users.
- **Visual Enhancement**: Optimize lyric animations and introduce dynamic theme switching.
- **Platform Compatibility**: Integrate playlists from QQ Music, Kugou Music, and other platforms for comprehensive cross-platform music management.