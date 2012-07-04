#!/usr/bin/env ruby

require 'json'
require 'fileutils'

BEGIN_DIR = Dir.pwd
SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))
BASE_DIR = "#{SCRIPT_DIR}/../"
BUILD_DIR = "#{BASE_DIR}/build"
RELEASE_DIR = "#{BUILD_DIR}/Release"
DEBUG_DIR = "#{BUILD_DIR}/Debug"
APP_NAME = "Slate"
APP_FILE = "#{APP_NAME}.app"
GITHUB_API_HOST = 'https://api.github.com'
GITHUB_API_DOWNLOADS_PATH = '/repos/jigish/slate/downloads'
GITHUB_DOWNLOADS_BASE = 'https://github.com/downloads/jigish/slate'
GITHUB_S3_BUCKET_URL = 'https://github.s3.amazonaws.com'
AWS_SUCCESS = '201'
ARCHIVE_MIME_TYPE = 'application/x-gzip'
ARCHIVE_SIZE_THRESHOLD = 800000
APPCAST_FILENAME = 'appcast.xml'
APPCAST_MIME_TYPE = 'text/xml'
APPCAST_SIZE_THRESHOLD = 800
RELEASE_NOTES_FILENAME = 'VERSION'
RELEASE_NOTES_MIME_TYPE = 'text/plain'
RELEASE_NOTES_SIZE_THRESHOLD = 5000

def log(msg)
  puts msg
end

def clean
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
  Dir.chdir(BEGIN_DIR)
  exit 1
end

def upload_file(dir, filename, description, mime_type, size_threshold, delete = false)
  curr_dir = Dir.pwd

  Dir.chdir(dir)
  if (delete)
    cmd = "curl -s -u #{GITHUB_USER}:#{GITHUB_PASS} #{GITHUB_API_HOST}#{GITHUB_API_DOWNLOADS_PATH}"
    json = `#{cmd}`
    resp = []
    begin
      resp = JSON.parse(json)
    rescue
      log "[#{filename}] ERROR: invalid delete json: #{json}"
      log "#{cmd}"
      return -1
    end
    if !resp.is_a?(Array)
      log "[#{filename}] ERROR: delete json not array: #{json}"
      log "#{cmd}"
      return -1
    end
    resp.each do |download|
      if (download['name'] == filename)
        log "[#{filename}] deleting."
        cmd = "curl -s -X DELETE -u #{GITHUB_USER}:#{GITHUB_PASS} #{GITHUB_API_HOST}#{GITHUB_API_DOWNLOADS_PATH}/#{download['id']}"
        `#{cmd}`
        break
      end
    end
  end
  size = File.new(filename).size
  log "[#{filename}] uploading. type: #{mime_type} size: #{size}"
  if (!size || size < size_threshold)
    log "[#{filename}] ERROR: size is below threshold: #{size} < #{size_threshold}"
    Dir.chdir(BEGIN_DIR)
    exit 1
  end
  cmd = "curl -s -X POST -d \"{ \\\"name\\\":\\\"#{filename}\\\",\\\"size\\\":#{size},\\\"description\\\":\\\"#{description}\\\",\\\"content_type\\\":\\\"#{mime_type}\\\" }\" -u #{GITHUB_USER}:#{GITHUB_PASS} #{GITHUB_API_HOST}#{GITHUB_API_DOWNLOADS_PATH}"
  json = `#{cmd}`
  resp = {}
  begin
    resp = JSON.parse(json)
  rescue
    log "[#{filename}] ERROR: invalid json: #{json}"
    log "#{cmd}"
    return -1
  end
  if (!resp['path'] || !resp['acl'] || !resp['name'] || !resp['accesskeyid'] || !resp['policy'] ||
      !resp['signature'] || !resp['mime_type'])
    log "[#{filename}] ERROR: json incomplete: #{json}"
    log "#{cmd}"
    return -1
  end
  cmd = "curl -s -w \"%{http_code}\" -F \"key=#{resp['path']}\" -F \"acl=#{resp['acl']}\" -F \"success_action_status=#{AWS_SUCCESS}\" -F \"Filename=#{resp['name']}\" -F \"AWSAccessKeyId=#{resp['accesskeyid']}\" -F \"Policy=#{resp['policy']}\" -F \"Signature=#{resp['signature']}\" -F \"Content-Type=#{resp['mime_type']}\" -F \"file=@#{filename}\" #{GITHUB_S3_BUCKET_URL} -o /dev/null"
  aws_code = `#{cmd}`.strip
  if (aws_code != AWS_SUCCESS)
    log "[#{filename}] ERROR: Bad response from aws: #{aws_code}"
    log "#{cmd}"
    return -1
  end

  Dir.chdir(curr_dir)

  size
end

def gen
  curr_dir = Dir.pwd

  # Cleanup files from previous build
  clean

  # Build
  Dir.chdir(BASE_DIR)
  `CC="" xcodebuild -scheme "Slate-Debug" clean archive`
  `CC="" xcodebuild -scheme "Slate" clean archive`

  # Copy
  debug_paths_json = File.read("#{BUILD_DIR}/debug_paths.json")
  debug_paths = JSON.parse(debug_paths_json)
  release_paths_json = File.read("#{BUILD_DIR}/release_paths.json")
  release_paths = JSON.parse(release_paths_json)
  { DEBUG_DIR => debug_paths['products'], RELEASE_DIR => release_paths['products'] }.each do |to, from|
    FileUtils.rm_rf "#{to}/#{APP_FILE}"
    FileUtils.cp_r "#{from}/Applications/#{APP_FILE}", "#{to}/#{APP_FILE}"
    File.new("#{to}/#{APP_FILE}/Contents/MacOS/#{APP_NAME}").chmod(0755)
  end

  Dir.chdir(curr_dir)
end

def pub
  curr_dir = Dir.pwd

  gen
  version = `cat "#{RELEASE_DIR}/#{APP_FILE}/Contents/Info.plist" | grep -A 1 CFBundleVersion | tail -1 | sed "s/<string>\\([0-9]*\\.[0-9]*\\.[0-9]*\\)<\\/string>/\\1/"`.strip
  log "Publishing version #{version} ..."
  Dir.chdir(RELEASE_DIR)
  filename = "#{version}.tar.gz"
  `tar -czf #{filename} #{APP_FILE}`

  # app archive
  size = upload_file(RELEASE_DIR, filename, "Slate v#{version}", ARCHIVE_MIME_TYPE, ARCHIVE_SIZE_THRESHOLD, true)
  unless size > ARCHIVE_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

  # release notes
  FileUtils.cp "#{BASE_DIR}/#{RELEASE_NOTES_FILENAME}", "#{RELEASE_DIR}/#{RELEASE_NOTES_FILENAME}"
  size = upload_file(RELEASE_DIR, RELEASE_NOTES_FILENAME, "Release Notes", RELEASE_NOTES_MIME_TYPE, RELEASE_NOTES_SIZE_THRESHOLD, true)

  # appcast
  appcast = <<EOS
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
  <title>Slate App Changelog</title>
  <link>#{GITHUB_DOWNLOADS_BASE}/#{APPCAST_FILENAME}</link>
  <description>Most recent changes with links to updates for Sparkle.</description>
  <language>en</language>
  <item>
    <title>Version #{version}</title>
    <sparkle:releaseNotesLink>#{GITHUB_DOWNLOADS_BASE}/#{RELEASE_NOTES_FILENAME}</sparkle:releaseNotesLink>
    <description>Slate v#{version}</description>
    <pubDate>#{Time.now.to_s}</pubDate>
    <enclosure url="#{GITHUB_DOWNLOADS_BASE}/#{filename}"
               sparkle:version="#{version}"
               length="#{size}"
               type="#{ARCHIVE_MIME_TYPE}" />
  </item>
  </channel>
</rss>
EOS
  File.open(APPCAST_FILENAME, 'w') {|f| f.write(appcast) }
  size = upload_file(RELEASE_DIR, APPCAST_FILENAME, 'Slate Appcast for Sparkle', APPCAST_MIME_TYPE, APPCAST_SIZE_THRESHOLD, true)
  unless size > APPCAST_SIZE_THRESHOLD
    Dir.chdir(BEGIN_DIR)
    exit 1
  end

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
    GITHUB_USER, GITHUB_PASS = ARGV[1].split(':')
    pub
  end
else
  usage
end

Dir.chdir(BEGIN_DIR)
