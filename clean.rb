require 'fileutils'

# This is destructive. Make sure the user really wants to do it.
erase = false
while true
  print "WARNING: This is a destructive operation and will remove .git directory, all README files, and this script. Are you sure you want to continue? [Y/N] "
  case gets.strip
    when 'Y', 'y', 'yes'
      erase = true
      break
    when 'N', 'n', 'no'
      erase = false
      break
  end
  print "Invalid response. Valid responses: Y, y, yes, N, n, no\n"
end

if erase
  # Remove all readmes
  if File.exists? 'README.md' then File.delete 'README.md' end
  if File.exists? 'build/README.md' then File.delete 'build/README.md' end
  if File.exists? 'content/README.md' then File.delete 'content/README.md' end
  if File.exists? 'game/README.md' then File.delete 'game/README.md' end
  if File.exists? 'lib/README.md' then File.delete 'lib/README.md' end

  # Remove the git directory. We leave gitignore in case the user wants it for their project.
  if File.exists? '.git' then FileUtils.rm_r '.git' end

  # Delete this script
  File.delete __FILE__
end
