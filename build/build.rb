#  build.rb - Ruby script for building OS X and Windows builds of a Löve game from OS X.
#  Created by Nick Gravelyn.
#
#  Builds the game into a single Windows executable file or into a Mac OS X app bundle.
#  This script downloads the latest 0.9.1 packages for Löve and uses them to generate
#  the resulting applications.
#
#  This script depends on the general layout of the template directory but can probably
#  be easily modified to work with other layouts of Löve games.

require 'rubygems'
require 'fileutils'
require 'open-uri'
require 'zip'

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

def download_love_build(file)
  zipPath = "#{$tempDir}/#{file}"
  baseName = File.basename file, '.*'

  File.write(zipPath, open("http://cdn.bitbucket.org/rude/love/downloads/#{file}").read, {mode: 'wb'})

  Zip::File.open(zipPath) do |zipfile|
    zipfile.each do |entry|
      if not entry.name.start_with? '__MACOSX'
        entryPath = "#{$tempDir}/#{entry.name}"
        FileUtils.mkdir_p(File.dirname(entryPath))
        entry.extract entryPath
      end
    end
  end

  File.delete zipPath
end

def create_zip_file(directory, zipFilePath)
  # Ensure the path ends with a trailing slash
  directory = "#{directory}/" unless directory.end_with? '/'

  Zip::File.open(zipFilePath, Zip::File::CREATE) do |zipfile|
    Dir[File.join(directory, '**', '**')].each do |file|
      zipfile.add(file.sub(directory, ''), file)
    end
  end
end

########################################
# PREPARE SOME VARIABLES AND DIRECTORIES
########################################

$currentDir = Dir.pwd

# Get some paths
$buildDir = File.expand_path File.dirname(__FILE__)
$outputDir = File.join $buildDir, 'output'
$tempDir = File.join $buildDir, 'temp'

# Find the project root by looking for the .sublime-project
rootDir = $buildDir
while Dir.glob(File.join(rootDir, '*.sublime-project')).empty?
  rootDir = File.expand_path('..', rootDir)
end

# Use the sublime project name as the name of the game
$gameName = File.basename(Dir.glob(File.join(rootDir, '*.sublime-project'))[0], '.*');
$gameLoveFile = File.join $outputDir, "#{$gameName}.love"

# Clear and create the temp and output directories
reset_dir $tempDir
reset_dir $outputDir

##########################
# BUILD THE .LOVE ZIP FILE
##########################

# Copy over the content, lib, and game directories if they exist and aren't empty
copy_dir_if_not_empty File.join(rootDir, 'content'), File.join($tempDir, 'content')
copy_dir_if_not_empty File.join(rootDir, 'lib'), File.join($tempDir, 'lib')
copy_dir_if_not_empty File.join(rootDir, 'game'), File.join($tempDir, 'game')

# Copy all root level lua files as well
Dir.glob(File.join(rootDir, '*.lua')).each do |f|
  FileUtils.copy_entry f, File.join($tempDir, File.basename(f))
end

# Delete any .DS_Store files OS X makes
Dir["#{$tempDir}/**/.DS_Store"].each do |s|
  File.delete s
end

# Compress into a ZIP and rename to .love
create_zip_file $tempDir, $gameLoveFile

####################
# CREATE THE OSX APP
####################
def create_mac_build()
  # Clear the temp directory
  reset_dir $tempDir

  osxAppPath = File.join $tempDir, "#{$gameName}.app"

  # Download the standard build
  download_love_build 'love-0.9.1-macosx-x64.zip'

  # Mark the app as executable since the unzip messes that up
  FileUtils.chmod '+x', "#{$tempDir}/love.app/Contents/MacOS/love"

  # Rename the app to our game's name
  FileUtils.mv "#{$tempDir}/love.app", osxAppPath

  # Remove the standard icons
  File.delete File.join(osxAppPath, 'Contents/Resources/Love.icns')
  File.delete File.join(osxAppPath, 'Contents/Resources/LoveDocument.icns')

  # Replace the app Info.plist with ours
  FileUtils.copy_entry File.join($buildDir, 'Info.plist'), File.join(osxAppPath, 'Contents/Info.plist'), false, false, true

  # Put in our icon
  FileUtils.copy_entry File.join($buildDir, "#{$gameName}.icns"), File.join(osxAppPath, "Contents/Resources/#{$gameName}.icns")

  # Put our .love file into the app
  FileUtils.copy_entry $gameLoveFile, File.join(osxAppPath, "Contents/Resources/#{$gameName}.love")

  # Zip up the app for redistribution
  create_zip_file $tempDir, "#{$outputDir}/#{$gameName}-OSX.zip"
end

create_mac_build()

###########################
# CREATE THE WINDOWS BUILDS
###########################
def create_windows_build(version)
  zipFile = "love-0.9.1-win#{version}.zip"
  rawDir = File.join $tempDir, File.basename(zipFile, '.*')
  looseRoot = File.join $outputDir, $gameName
  loosePath = File.join looseRoot, $gameName

  # Clear the temp directory
  reset_dir $tempDir

  # Ensure our loose root exists and is empty
  reset_dir looseRoot

  # Download the standard build
  download_love_build "love-0.9.1-win#{version}.zip"

  # Remove some files we don't want going with our game
  File.delete "#{rawDir}/changes.txt"
  File.delete "#{rawDir}/readme.txt"
  File.delete "#{rawDir}/game.ico"
  File.delete "#{rawDir}/love.ico"

  # Copy all of the win32 pieces into the output directory
  FileUtils.copy_entry rawDir, loosePath

  # Copy our icon into the mix
  FileUtils.copy_entry "#{$buildDir}/#{$gameName}.ico", "#{loosePath}/#{$gameName}.ico"

  # Build the final exe
  File.open("#{loosePath}/#{$gameName}.exe", 'wb') do |outfile|
    outfile.write(File.open("#{loosePath}/love.exe", 'rb').read)
    outfile.write(File.open("#{$gameLoveFile}", 'rb').read)
  end

  # Remove the old love exe
  File.delete "#{loosePath}/love.exe"

  # Zip up the loose folder for redistribution
  create_zip_file looseRoot, "#{$outputDir}/#{$gameName}-Win#{version}.zip"

  # Remove the loose directory
  FileUtils.rm_r looseRoot
end

# Build both versions
create_windows_build "32"
create_windows_build "64"

################
# FINAL CLEAN UP
################

# Remove the temp directory
FileUtils.rm_r $tempDir
