#  build.rb - Ruby script for building OS X and Windows builds of a Löve game from OS X.
#  Created by Nick Gravelyn.
#
#  Builds the game into a single Windows executable file or into a Mac OS X app bundle.
#  This script downloads the latest 0.9.0 packages for Löve and uses them to generate
#  the resulting applications.
#
#  This script depends on the general layout of the template directory but can probably
#  be easily modified to work with other layouts of Löve games.
#
#  Options:
#    --osx      Builds only the OS X version
#    --win32    Builds only the Windows version

require 'fileutils'

#################
# PARSE ARGUMENTS
#################

buildOSX = ARGV.include?('--osx') == true || ARGV.include?('--win32') == false
buildWin32 = ARGV.include?('--win32') == true || ARGV.include?('--osx') == false

############################
# DEFINE SOME HELPER METHODS
############################

def reset_dir(dir)
  if File.directory? dir
    FileUtils.rm_r dir
  end
  FileUtils.mkdir dir
end

def copy_dir_if_not_empty(src, dst)
  # Ensure the source exists and has files in it other than the readme
  if File.exist?(src)
    FileUtils.copy_entry src, dst

    # After copying, delete the readme from the template
    if File.exist?("#{dst}/README.md")
      File.delete("#{dst}/README.md")
    end

    # If the destination is empty, delete it entirely
    if Dir.glob("#{dst}/*").empty?
      FileUtils.rm_r(dst)
    end
  end
end

########################################
# PREPARE SOME VARIABLES AND DIRECTORIES
########################################

currentDir = Dir.pwd

# Get some paths
buildDir = File.expand_path File.dirname(__FILE__)
outputDir = File.join buildDir, 'output'
tempDir = File.join buildDir, 'temp'

# Find the project root by looking for the .sublime-project
rootDir = buildDir
while Dir.glob(File.join(rootDir, '*.sublime-project')).empty?
  rootDir = File.expand_path('..', rootDir)
end

# Use the sublime project name as the name of the game
gameName = File.basename(Dir.glob(File.join(rootDir, '*.sublime-project'))[0], '.*');
gameLoveFile = File.join outputDir, "#{gameName}.love"

# Clear and create the temp and output directories
reset_dir tempDir
reset_dir outputDir

##########################
# BUILD THE .LOVE ZIP FILE
##########################

# Copy over the content, lib, and game directories if they exist and aren't empty
copy_dir_if_not_empty File.join(rootDir, 'content'), File.join(tempDir, 'content')
copy_dir_if_not_empty File.join(rootDir, 'lib'), File.join(tempDir, 'lib')
copy_dir_if_not_empty File.join(rootDir, 'game'), File.join(tempDir, 'game')

# Copy all root level lua files as well
Dir.glob(File.join(rootDir, '*.lua')).each do |f|
  FileUtils.copy_entry f, File.join(tempDir, File.basename(f))
end

# Delete any .DS_Store files OS X makes
Dir["#{tempDir}/**/.DS_Store"].each do |s|
  File.delete s
end

# Compress into a ZIP and rename to .love
Dir.chdir tempDir
%x( zip -9 -q -r #{gameLoveFile} . )
Dir.chdir currentDir

####################
# CREATE THE OSX APP
####################

if buildOSX
  appPath = File.join outputDir, "#{gameName}.app"

  # Clear the temp directory
  reset_dir tempDir

  # Delete the app if it exists in our build directory
  if File.directory? appPath
    FileUtils.rm_r appPath
  end

  # Download the standard build
  Dir.chdir tempDir
  %x( curl -# -L -O https://bitbucket.org/rude/love/downloads/love-0.9.0-macosx-x64.zip )
  %x( unzip love-0.9.0-macosx-x64.zip )
  Dir.chdir currentDir

  # Copy the app to the build
  FileUtils.copy_entry "#{tempDir}/love.app", appPath

  # Remove the standard icons
  File.delete File.join(appPath, 'Contents/Resources/Love.icns')
  File.delete File.join(appPath, 'Contents/Resources/LoveDocument.icns')

  # Replace the app Info.plist with ours
  FileUtils.copy_entry File.join(buildDir, 'Info.plist'), File.join(appPath, 'Contents/Info.plist'), false, false, true

  # Put in our icon
  FileUtils.copy_entry File.join(buildDir, "#{gameName}.icns"), File.join(appPath, "Contents/Resources/#{gameName}.icns")

  # Put our .love file into the app
  FileUtils.copy_entry gameLoveFile, File.join(appPath, "Contents/Resources/#{gameName}.love")

  # Zip up the app for redistribution
  Dir.chdir outputDir
  %x( zip -9 -q -r #{gameName}-OSX.zip #{gameName}.app )
  Dir.chdir currentDir
end

########################
# CREATE THE WIN32 BUILD
########################

if buildWin32
  win32Path = File.join outputDir, gameName
  win32RawPath = File.join tempDir, 'love-0.9.0-win32'

  # Clear the temp directory
  reset_dir tempDir

  # Download the standard build
  Dir.chdir tempDir
  %x( curl -# -L -O https://bitbucket.org/rude/love/downloads/love-0.9.0-win32.zip )
  %x( unzip love-0.9.0-win32.zip )
  Dir.chdir currentDir

  # Remove some files we don't want going with our game
  File.delete "#{win32RawPath}/changes.txt"
  File.delete "#{win32RawPath}/readme.txt"
  File.delete "#{win32RawPath}/game.ico"
  File.delete "#{win32RawPath}/love.ico"

  # Copy all of the win32 pieces into the output directory
  FileUtils.copy_entry win32RawPath, win32Path

  # Copy our icon into the mix
  FileUtils.copy_entry "#{buildDir}/#{gameName}.ico", "#{win32Path}/#{gameName}.ico"

  # Build the final exe
  %x( cat #{win32Path}/love.exe #{gameLoveFile} > #{win32Path}/#{gameName}.exe )

  # Remove the old love exe
  File.delete "#{win32Path}/love.exe"

  # Zip up the loose folder for redistribution
  Dir.chdir outputDir
  %x( zip -9 -q -r #{gameName}-Win32.zip #{gameName} )
  Dir.chdir currentDir

  # Remove the loose directory
  FileUtils.rm_r win32Path
end

################
# FINAL CLEAN UP
################

# Remove the temp directory
FileUtils.rm_r tempDir
