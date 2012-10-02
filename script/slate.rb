#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'net/ftp'

BEGIN_DIR = Dir.pwd
SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))
BASE_DIR = File.join(SCRIPT_DIR, "..")
BUILD_DIR = File.join(BASE_DIR, "build")
RELEASE_DIR = File.join(BUILD_DIR, "Release")
DEBUG_DIR = File.join(BUILD_DIR, "Debug")
APP_NAME = "Slate"
APP_FILE = "#{APP_NAME}.app"
DMG_FILE = "#{APP_NAME}.dmg"
DMG_SIZE_THRESHOLD = 1000000
DMG_ICON = File.join(BASE_DIR, APP_NAME, 'icon.icns')
DMG_BACKGROUND = File.join(BUILD_DIR, 'dmg_background.png')
FTP_HOST = 'www.ninjamonkeysoftware.com'
FTP_DIR = 'slate'
WEB_HOST = 'www.ninjamonkeysoftware.com/slate'
ARCHIVE_SIZE_THRESHOLD = 800000
ARCHIVE_MIME_TYPE = 'application/x-gzip'
APPCAST_FILENAME = 'appcast.xml'
APPCAST_SIZE_THRESHOLD = 800
RELEASE_NOTES_FILENAME = 'VERSION'
RELEASE_NOTES_SIZE_THRESHOLD = 5000
SPARKLE_FRAMEWORK = 'Sparkle.framework'
FINISH_INSTALL = 'finish_installation'
CREATE_DMG = File.join(SCRIPT_DIR, "create-dmg", "create-dmg")
DMG_STAGING_DIR = File.join(BUILD_DIR, "dmg_staging")
README_MD_NAME = "README.md"
README_MD = File.join(BASE_DIR, README_MD_NAME)
README_TXT_NAME = "README.txt"
README_TXT = File.join(DMG_STAGING_DIR, README_TXT_NAME)

def log(msg)
  puts msg
end

def clean
  log "Cleaning ..."
  Dir.glob("#{BUILD_DIR}/*.json").each { |f| File.delete(f) }
  Dir.glob("#{RELEASE_DIR}/*.tar.gz").each { |f| File.delete(f) }
  Dir.glob("#{RELEASE_DIR}/VERSION").each { |f| File.delete(f) }
  Dir.glob("#{RELEASE_DIR}/*.xml").each { |f| File.delete(f) }
end

def usage
  log "./#{File.basename(__FILE__)} <task> <options>"
  log "  tasks:"
  log "    gen : generate the release"
  log "    pub : publish the release (required parameter: <github user>:<github pass>"
  log "    dmg : create the dmg"
  Dir.chdir(BEGIN_DIR)
  exit 1
end

def upload_file(from_dir, to_dir, filename, size_threshold, binary = false)
  curr_dir = Dir.pwd

  Dir.chdir(from_dir)
  size = File.new(filename).size
  log "[#{filename}] uploading #{size} bytes."
  if (!size || size < size_threshold)
    log "[#{filename}] ERROR: size is below threshold: #{size} < #{size_threshold}"
    Dir.chdir(BEGIN_DIR)
    return -1
  end
  Net::FTP.open(FTP_HOST, FTP_USER, FTP_PASS) do |ftp|
    ftp.passive = true
    ftp.chdir(to_dir)
    if (binary)
      ftp.putbinaryfile(filename)
    else
      ftp.puttextfile(filename)
    end
  end
  size
end

def dmgify
  curr_dir = Dir.pwd

  log "DMGifying..."
  Dir.chdir(BASE_DIR)

  # Copy things to staging dir
  FileUtils.rm_rf(DMG_STAGING_DIR) if File.directory?(DMG_STAGING_DIR)
  Dir.mkdir(DMG_STAGING_DIR)
  FileUtils.cp_r File.join(RELEASE_DIR, APP_FILE), File.join(DMG_STAGING_DIR, APP_FILE)
  File.open(README_TXT, 'w') { |f| f.write("Please visit http://github.com/jigish/slate") }

  FileUtils.rm_rf(File.join(RELEASE_DIR, DMG_FILE));
  `#{CREATE_DMG} --volname #{APP_NAME} --volicon #{DMG_ICON} --icon #{APP_NAME} 10 0 --icon #{README_TXT_NAME} 360 0 --app-drop-link 185 0 --background #{DMG_BACKGROUND} #{File.join(RELEASE_DIR, DMG_FILE)} #{DMG_STAGING_DIR}`

  FileUtils.rm_rf(DMG_STAGING_DIR)

  log "DMGified."

  Dir.chdir(curr_dir)
end

def gen
  curr_dir = Dir.pwd

  # Cleanup files from previous build
  clean

  # Build
  log "Building ..."
  Dir.chdir(BASE_DIR)
  `CC="" xcodebuild -scheme "Slate-Debug" clean archive`
  `CC="" xcodebuild -scheme "Slate" clean archive`

  # Copy
  debug_paths_json = File.read(File.join(BUILD_DIR, "debug_paths.json"))
  debug_paths = JSON.parse(debug_paths_json)
  release_paths_json = File.read(File.join(BUILD_DIR, "release_paths.json"))
  release_paths = JSON.parse(release_paths_json)
  { DEBUG_DIR => debug_paths['products'], RELEASE_DIR => release_paths['products'] }.each do |to, from|
    FileUtils.rm_rf File.join(to, APP_FILE)
    FileUtils.cp_r File.join(from, "Applications", APP_FILE), File.join(to, APP_FILE)
    File.new(File.join(to, APP_FILE, "Contents", "MacOS", APP_NAME)).chmod(0755)
    File.new(File.join(to, APP_FILE, "Contents", "Frameworks", SPARKLE_FRAMEWORK, "Resources", "#{FINISH_INSTALL}.app", "Contents", "MacOS", FINISH_INSTALL)).chmod(0755)
  end

  dmgify

  Dir.chdir(curr_dir)
end

def pub
  curr_dir = Dir.pwd

  gen
  version = `cat "#{File.join(RELEASE_DIR, APP_FILE, "Contents", "Info.plist")}" | grep -A 1 CFBundleVersion | tail -1 | sed "s/<string>\\([0-9]*\\.[0-9]*\\.[0-9]*\\)<\\/string>/\\1/"`.strip
  log "Publishing version #{version} ..."
  Dir.chdir(RELEASE_DIR)
  filename = "slate-#{version}.tar.gz"
  `tar -czf #{filename} #{APP_FILE}`

  # app archive
  size = upload_file(RELEASE_DIR, File.join(FTP_DIR, "versions"), filename, ARCHIVE_SIZE_THRESHOLD, true)
  unless size > ARCHIVE_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

  # release notes
  FileUtils.cp File.join(BASE_DIR, RELEASE_NOTES_FILENAME), File.join(RELEASE_DIR, RELEASE_NOTES_FILENAME)
  size = upload_file(RELEASE_DIR, FTP_DIR, RELEASE_NOTES_FILENAME, RELEASE_NOTES_SIZE_THRESHOLD)
  unless size > RELEASE_NOTES_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

  # appcast
  appcast = <<EOS
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
  <title>Slate App Changelog</title>
  <link>https://#{WEB_HOST}/#{APPCAST_FILENAME}</link>
  <description>Most recent changes with links to updates for Sparkle.</description>
  <language>en</language>
  <item>
    <title>Version #{version}</title>
    <sparkle:releaseNotesLink>https://#{WEB_HOST}/#{RELEASE_NOTES_FILENAME}</sparkle:releaseNotesLink>
    <description>Slate v#{version}</description>
    <pubDate>#{Time.now.to_s}</pubDate>
    <enclosure url="https://#{WEB_HOST}/versions/#{filename}"
               sparkle:version="#{version}"
               length="#{size}"
               type="#{ARCHIVE_MIME_TYPE}" />
  </item>
  </channel>
</rss>
EOS
  File.open(APPCAST_FILENAME, 'w') {|f| f.write(appcast) }
  size = upload_file(RELEASE_DIR, FTP_DIR, APPCAST_FILENAME, APPCAST_SIZE_THRESHOLD)
  unless size > APPCAST_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

  # DMG
  size = upload_file(RELEASE_DIR, FTP_DIR, DMG_FILE, DMG_SIZE_THRESHOLD)
  unless size > DMG_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

  log ""
  log "Done. Don't forget to update the latest symlink and Slate.dmg!"
  log ""

  Dir.chdir(curr_dir)
end

if (ARGV.length == 0)
  usage
end

if (ARGV[0] == 'gen')
  gen
elsif (ARGV[0] == 'pub')
  if (ARGV.length < 2)
    usage
  else
    FTP_USER, FTP_PASS = ARGV[1].split(':')
    pub
  end
elsif (ARGV[0] == 'dmg')
  dmgify
else
  usage
end

Dir.chdir(BEGIN_DIR)
