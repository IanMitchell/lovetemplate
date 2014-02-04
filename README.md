Just a little template/starter for [Löve2D](http://love2d.org) games. Comes by default with the `conf.lua` and `main.lua` files, directories for additional game and third party code, a directory for content, and a build system for packaging the game up for distribution<sup>1</sup>. Each directory contains a README you can see for further information.

The sublime-project included has a build system that can be used. It will appear in the menu as "Löve2D Game". It assumes an executable named 'love' is available. In OS X you achieve this by making a link to the application into /usr/bin using the Terminal:

    sudo ln -s /Applications/love.app/Contents/MacOS/love /usr/bin/love

<sup>1</sup> The build system is written in Ruby but currently leverages OS X shell commands. Work would need to be done to make the script work appropriately in Windows.


Getting Started
---

Clone the template and move into the directory:

    git clone https://github.com/nickgravelyn/lovetemplate.git GAMENAME
    cd GAMENAME

Initialize the template:

    ruby init.rb "Company Name" "Game Name"

Now you can open up the project in Sublime Text (or your favorite editor) and get to work.


License
---

This template is provided for free with the included Ruby scripts available under the zlib license:

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

