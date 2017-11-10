# Giphy Browser

Giphy Browser is an iOS app that uses the [Giphy public api](https://github.com/Giphy/GiphyAPI) to view trending GIFs and search for GIFs based on keywords.

![Screencast](https://github.com/bgayman/GiphyBrowser/blob/master/screencast1.GIF?raw=true)![Screencast](https://github.com/bgayman/GiphyBrowser/blob/master/screencast2.GIF?raw=true)

## Installation

1. Clone this repo: `git clone https://github.com/bgayman/GiphyBrowser.git`

2. Run `pod install` or `pod update` to download dependencies. (If you don't cocoa pods installed follow the guide [here](https://cocoapods.org).)

3. Open the `.xcworkspace` in Xcode 9+

4. Add a Giphy API key to the top of `GiphyURLConstructor.swift`. (Don't have a Giphy API Key? You can get one [here](https://developers.giphy.com))

5. If building to device, change the Developer Team and Bundle Identifier in the project file.

6. Build and Run


