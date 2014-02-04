The build folder contains build specific files (icons, Mac OS X plist file) and a build script.

Build Script
---

`build.rb` is a simple script for building both Mac OS X and Windows versions of your game. It downloads the latest Löve 0.9.0 binaries and creates a new Mac OS X app bundle and combined/packed Windows executable with your game. By default the build script will build both versions but you can pass either `--osx` or `--win32` to build just a single one.

The build script uses the sublime-project file in the root both for locating the root directory and for determining the name of the game (using the sublime-project file's name). If you choose not to use Sublime Text, you still will need the file for this build script to work without modification.

The build script is written in Ruby but does use some Mac OS X console commands. At this time I'm only supporting it on OS X but if you make it work in Windows, I'd love a pull request to add it in.


Info.plist
---

The Info.plist file is used by the Mac OS X bundle to configure the application. You'll want to modify the values for your game as appropriate.
