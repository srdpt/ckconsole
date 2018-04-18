#!/usr/bin/env ruby
# encoding: UTF-8

require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'
require 'pr_geohash'

FB_SRC_APP  = 'https://cityknowledge.firebaseio.com'
FB_SRC_KEY  = 'RF4IryD4TK2NdpsDQEC4oo0fJOVsriej98NuSkmH'
FB_DEST     = 'https://ckconsole.firebaseio.com'
FB_DEST_KEY = 'npiiJLa6TchiVhDLxAsomVXHJ5LwrP1PMWT7tsuN'
# ITEMS     = %w{maps layers forms groups data}
# ITEMS     = %w{maps layers forms}
CHUNK_SIZE  = 100

fire_src = Firebase::Client.new(FB_SRC_APP, FB_SRC_KEY); nil
fire_dst = Firebase::Client.new(FB_DEST, FB_DEST_KEY)  ; nil

def ts
  Time.now.strftime("%Y%m%d %H:%M:%S")
end

fire_dst.set('dump_start_at', Time.now)
# %w{maps layers forms}.each do |item|
#   puts "Acquisisco #{item}"
#   res = JSON.parse( fire_src.get(item).response.content )
#   puts "  Invio aggiornamenti"
#   fire_dst.update("#{CGI.escape item}", res)
# end

# %w{groups data}.each do |item|
#   last_item = nil
#   ciclo = 0
#   while true do
#     puts "Acquisisco #{item} (DA #{last_item || '0'})"
#     options = {
#       :orderBy      => '$key'.to_json,
#       :limitToFirst => CHUNK_SIZE
#     }
#     options[:startAt] = last_item.to_json if last_item
#     res = JSON.parse( fire_src.get(item, options).response.content )
#     last_item = res.keys.last
#     puts "  Invio aggiornamenti #{ciclo * CHUNK_SIZE}"
#     res.keys.each{|k|
#       print "#{k}\r"
#       fire_dst.update("#{CGI.escape item}/#{CGI.escape k}", res[k])
#     }
#     break if res.keys.size < CHUNK_SIZE
#     ciclo += 1
#   end
# end

member_groups = {}
puts "#{ts} Acquisisco GRUPPI"
# res = JSON.parse( fire_src.get('groups').response.content ); nil
# cmd_line  = "wget -O bk_groups.json "
# cmd_line += "\"https://cityknowledge.firebaseio.com/groups.json?print=pretty&auth=#{FB_SRC_KEY}\""
# puts "Eseguo #{cmd_line}"
# `#{cmd_line}`
res = JSON.parse( File.open('bk_groups.json').read ); nil
puts "#{ts}   Aggiorno i Gruppi"
i = 0; tot = res.keys.size
res.keys.each{|k|
  print "#{i+=1}/#{tot} #{(k + ' '*80)[0...80]}\r"
  if res[k]['members']
    res[k]['member_list'] = res[k]['members'].keys.join(',')
    res[k]['members'].keys.each do |m|
      member_groups[m] ||= []
      member_groups[m] << k
    end
  end
  # fire_dst.update("groups/#{CGI.escape k}", res[k])
}; nil
puts "#{ts}   Completato"

options = {
  :orderBy      => '$key'.to_json,
  # :limitToFirst => 1000,
  # :startAt      => '4fc5321d-6bca-0ae8-861f-5f0bd80c675d'
}
start_key = fire_dst.get('last_updated').response.content.to_s.gsub('"', '')
if start_key.size > 1
  options[:startAt] = start_key
end

puts "#{ts} Acquisisco DATI"
# res = JSON.parse( fire_src.get('data', options).response.content ); nil
# cmd_line  = "wget -O bk_data.json "
# cmd_line += "\"https://cityknowledge.firebaseio.com/data.json?print=pretty&auth=#{FB_SRC_KEY}\""
# puts "Eseguo #{cmd_line}"
# `#{cmd_line}`
res = JSON.parse( File.open('bk_data.json').read ); nil
puts "#{ts}   Aggiorno i Dati"
i = 0; tot = res.keys.size
res.keys.sort.each{|k|
  print "#{i+=1}/#{tot} #{(k + ' '*80)[0...80]}\r"
  if k > start_key
    res[k]['group_list'] = member_groups[k].join(',') if member_groups[k]
    if res[k]['birth_certificate']
      lat = res[k]['birth_certificate']['lat'].to_f
      lng = res[k]['birth_certificate']['lon'].to_f
      if (lat + lng) != 0
        tmp = {}
        tmp['g'] = GeoHash.encode(lat, lng)
        tmp['l'] = [lat, lng]
        tmp['.priority'] = res[k]['g']
        fire_dst.set("_geodata/data:#{CGI.escape k}", tmp)
      end
    end
    fire_dst.set("data/#{CGI.escape k}", res[k])
    fire_dst.set('last_updated', k) if i % 10 == 0
  end
}; nil
pust "#{ts}  COMPLETATO"
fire_dst.set('dump_end_at', Time.now)

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