#!/usr/bin/env ruby
# encoding: UTF-8

require 'firebase'
require 'active_support/all'
require 'pr_geohash'

FB_SRC_APP  = 'https://cityknowledge.firebaseio.com'
FB_SRC_KEY  = 'RF4IryD4TK2NdpsDQEC4oo0fJOVsriej98NuSkmH'
FB_DST_APP = 'https://ckdata.firebaseio.com'
FB_DST_KEY = '6oHOTzpyRjbzO5HP7EQWclxwICXPOOv7UJpZqZFe'

BV_URL = 'http://jlleitschuh.github.io/BetterCKConsoleViewer/#/group-uiGrid'

CHUNK_SIZE  = 100

group_name = ARGV.join(' ')
if group_name.to_s.size < 2
  puts "Specify a group name"
  exit
end

puts "Processing Group #{group_name}"
puts "  URL #{FB_SRC_APP}/groups/#{URI.encode(group_name)}"
puts "  URL #{BV_URL}/#{URI.encode(group_name)}"

fire_src = Firebase::Client.new(FB_SRC_APP, FB_SRC_KEY); nil
fire_dst = Firebase::Client.new(FB_DST_APP, FB_DST_KEY); nil

puts "Export the group info"
group_json = fire_src.get("groups/#{URI.encode(group_name)}").response.content
group_json.gsub!(FB_SRC_APP, FB_DST_APP)
group_json.gsub!(FB_SRC_APP.gsub('https://', 'http://'), FB_DST_APP.gsub('https://', 'http://'))
group_json = JSON.parse( group_json )
group_json['member_list'] = group_json['members'].keys.join(',')
fire_dst.set("groups/#{URI.encode(group_name)}", group_json)

tot = group_json['members'].keys.size
puts "Export #{tot} keys"
group_json['members'].keys.each_with_index do |k, i|
  puts "  #{i+1}/#{tot} export #{k}"
  data_json = fire_src.get("data/#{URI.encode(k)}").response.content
  data_json.gsub!(FB_SRC_APP, FB_DST_APP)
  data_json.gsub!(FB_SRC_APP.gsub('https://', 'http://'), FB_DST_APP.gsub('https://', 'http://'))
  data_json = JSON.parse( data_json )
  
  actual_data = fire_dst.get("data/#{URI.encode(k)}").response.content
  if (actual_data != 'null')
    actual_data = JSON.parse( actual_data )
    data_json.merge!(actual_data)
  end
  
  data_json['migrated_at'] = Time.now
  
  data_json['group_list'] ||= ''
  data_json['group_list'] = (data_json['group_list'].split(',') + [group_name]).sort.join(',')
  
  if data_json['birth_certificate']
    lat = data_json['birth_certificate']['lat'].to_f
    lng = data_json['birth_certificate']['lon'].to_f
    if (lat + lng) != 0
      tmp = {}
      tmp['g'] = GeoHash.encode(lat, lng)
      tmp['l'] = [lat, lng]
      tmp['.priority'] = tmp['g']
      data_json['g'] = tmp['g']
      puts "  GeoHash #{tmp['g']}"
      fire_dst.set("_geodata/data:#{CGI.escape k}", tmp)
    end
  end
  
  fire_dst.set("data/#{URI.encode(k)}", data_json)
end

puts "\n\nCompleted!"