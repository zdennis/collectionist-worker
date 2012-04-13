#!/usr/bin/env ruby

require 'fileutils'
require 'date'

STDOUT.sync = true

FileUtils.mkdir "roodi" unless File.exists?("roodi")

results = `git log --reverse --pretty=format:"%h %ad"`
#results = `git log dbdb39a..1aa12e2 --reverse --pretty=format:"%h %ad"`

commits = results.split("\n").map{ |s| s.split(/\s+/, 2) } ; commits.length

puts "Generating metrics for #{commits.length} commits"

count = 0
commits.each do |sha, timestamp|
  puts "On #{count+=1} of #{commits.length}"
  system "git checkout #{sha} >> roodi-log.txt"
  if $?.exitstatus != 0
    `echo "#{sha} bad" >> roodi-log.txt`
    next 
  else
    `echo "#{sha} good" >> roodi-log.txt`
    date = Date.parse(timestamp).to_s
    system %|time roodi "**/*.rb" > roodi/#{File.basename(Dir.pwd)}.#{date}.#{sha}.txt|
  end
end

