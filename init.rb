#  init.rb - Initializes the template.
#  Created by Nick Gravelyn.
#
#  This script helps configure the template for use with a game. It does a few things:
#    1. Removes all README.md files in all directories.
#    2. Renames the sublime-project to the game name.
#    3. Does string replacements in Info.plist and conf.lua to configure the game properly.
#    4. Removes this script once complete.
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

# Remove all readmes
if File.exists? 'README.md' then File.delete 'README.md' end
if File.exists? 'build/README.md' then File.delete 'build/README.md' end
if File.exists? 'content/README.md' then File.delete 'content/README.md' end
if File.exists? 'game/README.md' then File.delete 'game/README.md' end
if File.exists? 'lib/README.md' then File.delete 'lib/README.md' end

# Remove the git directory. We leave gitignore in case the user wants it for their project.
if File.exists? '.git' then FileUtils.rm_r '.git' end

# Rename the sublime-project
File.rename('game.sublime-project', "#{gameName}.sublime-project")

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
