#  init.rb - Initializes the template.
#  Created by Nick Gravelyn.
#
#  This script helps configure the template for use with a game. It does a few things:
#    1. Removes all README.md files in all directories.
#    2. Renames the sublime-project to the game name.
#    3. Removes the .git directory.
#    4. Does string replacements in Info.plist and conf.lua to configure the game properly.
#    5. Removes this script once complete.
#
#  Usage:
#    ruby init.rb "Company Name" "Game Name"
#

require 'fileutils'

if ARGV.size < 2
  puts 'init.rb requires a company name and a game name!'
  exit
end

# Get the parameters
companyName = ARGV[0]
gameName = ARGV[1]

# Form the identifier from the company and game name, after removing spaces and making it all lowercase
identifier = "com.#{companyName}.#{gameName}".gsub(' ', '').downcase

# Remove all ReadMe files
Dir['**/*'].each do |filepath|
  File.delete filepath if filepath.include? 'README.md'
end

# Remove the git directory. We leave gitignore in case the user wants it for their project.
FileUtils.rm_r '.git' if File.exists? '.git'

# Rename the sublime-project
File.rename('game.sublime-project', "#{gameName}.sublime-project")

# Rename the icon files
File.rename('build/game.icns', "build/#{gameName}.icns")
File.rename('build/game.ico', "build/#{gameName}.ico")

# Update conf.lua and Info.plist
[ 'conf.lua', 'build/Info.plist' ].each do |f|
  text = File.read f
  text = text.gsub('$IDENTIFIER$', identifier)
  text = text.gsub('$GAME$', gameName)
  text = text.gsub('$COMPANY$', companyName)
  File.open(f, 'w') { |file| file.write(text) }
end

# Delete this script
File.delete __FILE__
