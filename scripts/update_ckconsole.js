#!/usr/bin/env ruby
# encoding: UTF-8

require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'

FB_APP = 'https://ckconsole.firebaseio.com'
FB_KEY = 'npiiJLa6TchiVhDLxAsomVXHJ5LwrP1PMWT7tsuN'

fire_app = Firebase::Client.new(FB_APP, FB_KEY)

fire_app.set('update_start_at', Time.now)
puts "Acquisisco Gruppi"
res = JSON.parse( fire_app.get('groups').response.content )

res.keys.each{|k|
  print "#{(k + ' '*80)[0...80].size}\r"
  fire_dst.set("groups/#{CGI.escape k}/member_list", res[k]['members'].keys.join(','))
}

fire_dst.set('update_end_at', Time.now)

# JSON.parse( fire_src.get('groups', :startAt => 3, :endAt => 11, :orderBy => '\$key'.to_json).response.content )

# SRC="https://cityknowledge.firebaseio.com/"
# firebase = Firebase::Client.new(SRC)
# 
# w = JSON.parse(File.open(d).read)
# puts "Aggiungo info su #{w['id']}"
# firebase.set("widgets/#{w['id']}", w)
# 
# res = JSON.parse(firebase.get('dashboards/widgets').response.content)
# 
# FB_APP = 'cityknowledge.firebaseio.com'
# FB_KEY = 'RF4IryD4TK2NdpsDQEC4oo0fJOVsriej98NuSkmH'
# ITEMS  = %w{maps layers forms groups data}
# FB_DEST     = 'ckconsole.firebaseio.com'
# FB_DEST_KEY = 'npiiJLa6TchiVhDLxAsomVXHJ5LwrP1PMWT7tsuN'
# ts = Time.now.strftime('%Y%m%d_%H%M')
# 
# ITEMS.each do |item|
#   cmd_line  = "wget -O bk_#{item}_#{ts}.json "
#   cmd_line += "\"https://#{FB_APP}/#{item}.json?print=pretty&auth=#{FB_KEY}\""
#   puts "Eseguo #{cmd_line}"
#   # `#{cmd_line}`
# end
# 
# ITEMS.each do |item|
#   cmd_line  = "firebase-import "
#   cmd_line += "--firebase_url=\"https://#{FB_DEST}/#{item}\" "
#   cmd_line += "--json=\"bk_#{item}_#{ts}.json\" "
#   cmd_line += "--merge --auth=#{FB_DEST_KEY} "
#   puts "Eseguo #{cmd_line}"
#   # `#{cmd_line}`
# end
# 
# require 'json'
# require 'active_support/all'
# 
# puts "Reading data (whait almost 30 secs...)"
# dati = JSON.parse(File.open('backup_ck.json').read); nil
# 
# dati.keys.each do |k|
#   puts "Exporting #{k}..."
#   File.open("backup_#{k}.json", 'w'){|f| f.puts JSON.pretty_generate(dati[k]) }
# end
# 
# puts "Completed!"
# 
#