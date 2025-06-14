# Kanada Music Player: Enjoy the Ultimate Local Music Experience

![Download for Android](https://img.shields.io/badge/Android-v1.0.0-blue?logo=android)

[简体中文](README.md) | [English](README_EN.md)

## Overview
Kanada Music Player is a local music player specially customized for Android devices. Adhering to the design philosophy of simplicity and usability, it offers users a rich and excellent music playback experience. Whether you prefer to immerse yourself in soothing melodies during your leisure time or feel the exciting rhythms during sports, Kanada can precisely meet your needs. It not only provides comprehensive support for common audio formats but also features powerful lyric display capabilities and intelligent control features, leading you to fully indulge in the wonderful world of music.

## Key Features

### 🎧 Diverse Music Playback Experience
- **Wide Range of Audio Formats Supported**: Kanada seamlessly supports common audio formats such as MP3 and FLAC. Whether you have high - quality lossless music or classic MP3 songs in your collection, they can all be played smoothly on this player, ensuring that you won't miss any of your favorite music.
- **Convenient Playlist Management**: You can easily create and manage your personal playlists. Categorize your favorite songs into different lists according to different moods, scenarios, or music styles. Whether it's creating a focused playlist for work or a lively playlist for parties, you have full control.
- **Abundant Playback Modes**: Three unique playback modes are available. The single - loop mode allows you to savor the charm of a particular song repeatedly; the list - loop mode enables you to enjoy the entire playlist from start to finish; and the shuffle mode brings endless surprises with a different playback order each time, helping you discover new musical highlights continuously.

### 📖 Excellent Lyric Experience
- **Real - Time Scroll Synchronization**: The lyrics will scroll in real - time as the song plays, allowing you to accurately sing along to every lyric. Whether you're singing along with the singer at a concert or enjoying music at home alone, the real - time synchronized lyrics will help you better immerse yourself in the emotions of the music.
- **Support for External Lyric Displays**: If you desire a more unique lyric display experience, Kanada supports external lyric displays (requires compatible software). By connecting an external device, you can view the lyrics clearly on a larger screen, significantly enhancing the visual enjoyment.

### ⚡ Intelligent and Convenient Control Functions
- **Automatic Pause on Mute**: When you set your device to mute mode, Kanada will automatically pause the music playback, preventing power consumption or disturbing others when you don't need the music. You can simply resume playback after turning the sound back on.
- **Automatic Pause on Headphone Disconnection**: When listening to music with headphones, if you accidentally unplug the headphones, the player will automatically pause the playback, preventing the music from playing aloud and causing embarrassment or disturbing others, and also avoiding unnecessary power consumption.
- **Automatic Recognition of Netease Cloud Music Playlists**: Kanada supports the automatic recognition of Netease Cloud Music playlists. You can directly import Netease Cloud playlists into the player without manually adding songs one by one, greatly saving time and helping you quickly build your favorite music list.

## Download and Installation

### Steps to Install the Official Version
1. **Download the APK File**: [Click here to download the latest APK](https://github.com/xiaocaoooo/Kanada/releases/latest/download/app - release.apk). Make sure your device is connected to a stable network to ensure a smooth download.
2. **Enable Installation of Apps from Unknown Sources**: Open your phone's 「Settings」 -> 「Security」, find and enable the 「Install apps from unknown sources」 option. Since apps downloaded from non - app stores require additional permissions to install.
3. **Install the App**: Find the downloaded APK file in your phone's file manager and click to install. The installation process may take some time, so please be patient. After installation, you can find the Kanada Music Player icon on the home screen or in the app list and click to launch the app.

## User Guide

### 1. Importing Music
- **Adding Folders**: After opening the app, click to enter the 「Settings」 page and find the 「Folder Settings」 option. Click on this option, select and add a local music folder. The player will automatically scan all music files in the folder and add them to the music library.
- **Importing Netease Cloud Music Playlists**: Also on the 「Folder Settings」 page, if you have a Netease Cloud Music playlist to import, simply enter the relevant playlist information as prompted. The player will automatically recognize and add the songs in the playlist to the music library.

### 2. Playback Control
- **Starting Playback**: Find the song you want to play in the music library and click to start playing. The player will quickly load the song and start playback, while displaying information such as the song's cover, title, and artist.
- **Adjusting Playback Progress**: On the playback interface, you can adjust the song's playback progress by sliding the progress bar. Slide left to rewind and right to fast - forward, making it easy to find your favorite parts of the song.

### 3. Lyric Display
- **Entering the Lyric Interface**: On the playback page, swipe left on the screen to enter the lyric interface. The lyric interface will display the lyric content in a simple and beautiful way and scroll in real - time according to the song's playback progress.
- **Adjusting Lyric Font Size**: On the lyric interface, you can adjust the lyric font size through the relevant settings options to suit your personal preferences and visual needs.

## Frequently Asked Questions

### ❓ Why can't I find my music files?
👉 This may be because the player does not have the 「Storage Access Permission」. You need to go to the app management or permission management option in your phone's settings, find Kanada Music Player, and grant it the 「Storage Access Permission」. After granting the permission, reopen the player, and it will scan the local music files again, and you should be able to find your music.

### ❓ How do I connect an external lyric display?
👉 To connect an external lyric display, you need to install the supporting 「Lyric - Getter」 app. You can download the app from [Github](https://github.com/xiaowine/Lyric - Getter/releases/latest). After installation, follow the instructions in the 「Lyric - Getter」 app to set it up and connect it to Kanada Music Player. Once connected, you can view the synchronized lyrics on the external lyric display.

### ❓ What should I do if importing a Netease Cloud playlist fails?
👉 First, make sure your network connection is stable. If the network is normal, check if the playlist information you entered is accurate. If the problem persists, it may be due to an issue with the Netease Cloud interface or the playlist is set to private. You can try again later or import a different playlist.

### ❓ How can I solve the卡顿 problem during playback?
👉 The卡顿 may be caused by insufficient device performance or a corrupted music file. You can try closing other running apps to free up device resources. If the problem still exists, check if the music file is intact and try redownloading it or replacing it with another music file for playback.

## Open - Source Declaration
This application is open - source under the [GPLv3 license](LICENSE), which means users can freely use, modify, and share this application. We warmly welcome developers to participate in the project development and jointly improve and optimize Kanada Music Player. Additionally, the official version does not contain any advertisements or paid content, creating a pure and distraction - free music playback environment for you.

## Contribution and Feedback
If you encounter any problems during use or have suggestions and ideas, you are welcome to provide feedback in the following ways:
- Submit Issues in the [GitHub repository](https://github.com/xiaocaoooo/Kanada) and describe the problem or suggestion in detail.
- Directly contribute to the code by submitting Pull Requests to help us improve the code and functionality.

We highly value user feedback and will do our best to provide a better music playback experience for everyone. Thank you for choosing Kanada Music Player. Let's enjoy the beauty of music together!

## Technical Architecture and Dependency Description

### Technical Architecture
Kanada Music Player adopts a modular architecture design, mainly divided into the following core modules:
- **Playback Module**: Responsible for basic operations such as music playback, pause, and progress control. It uses the `just_audio` library to implement audio playback.
- **Lyric Module**: Implements lyric matching, synchronized display, and support for external lyric displays. It is completed through a custom lyric parser and the `kanada_lyric_sender` plugin.
- **Metadata Module**: Responsible for obtaining music metadata, such as title, artist, and album cover. It is implemented through the `Metadata` class.
- **Settings Module**: Manages various user settings, such as lyric display, playback mode, and sound effects settings. It uses the `Settings` class to save and read settings information.

### Main Dependencies
- `just_audio`: Used for audio playback and control.
- `kanada_lyric_sender`: Used for lyric sending and synchronization.
- `http`: Used for network requests, such as obtaining Netease Cloud Music playlist information and lyrics.
- `path_provider`: Used to obtain the application's storage path and implement caching functions for lyrics and covers.

## Future Plans
- **Add Support for More Audio Formats**: Plan to support more niche but high - quality audio formats, such as APE and WAV, to meet the needs of more users.
- **Optimize Lyric Display Effects**: Further improve the lyric display effects by adding more animations and special effects to make the lyric display more vivid.
- **Support More Online Music Platforms**: In addition to Netease Cloud Music, support the import of playlists from other online music platforms, such as QQ Music and Kugou Music, in the future.