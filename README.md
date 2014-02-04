Just a little template/starter for [Löve2D](http://love2d.org) games. Comes by default with the `conf.lua` and `main.lua` files, directories for additional game and third party code, a directory for content, and a build system for packaging the game up for distribution<sup>1</sup>. Each directory contains a README you can see for further information.

The sublime-project included has a build system configured for use on OS X with the default love.app placed in the root /Applications directory. You can use this to run your game directly within Sublime Text. The command will need modification on other platforms, however.

This template and all files within are available under the zlib license:

    Copyright (c) 2014 Nick Gravelyn

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

       1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software
       in a product, an acknowledgment in the product documentation would be
       appreciated but is not required.

       2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.

       3. This notice may not be removed or altered from any source
       distribution.



<sup>1</sup> The build system is written in Ruby but currently leverages OS X shell commands. Work would need to be done to make the script work appropriately in Windows.
