#!/usr/bin/env ruby
# encoding: UTF-8

require 'firebase'
require 'active_support/all'
require 'pr_geohash'

FB_SRC_APP  = 'https://cityknowledge.firebaseio.com'
FB_SRC_KEY  = 'RF4IryD4TK2NdpsDQEC4oo0fJOVsriej98NuSkmH'
FB_DST_APP = 'https://ckdata.firebaseio.com'
FB_DST_KEY = '6oHOTzpyRjbzO5HP7EQWclxwICXPOOv7UJpZqZFe'

fire_src = Firebase::Client.new(FB_SRC_APP, FB_SRC_KEY); nil
fire_dst = Firebase::Client.new(FB_DST_APP, FB_DST_KEY); nil

# shallow permit to retrive ONLY keys
groups = JSON.parse( fire_src.get("groups", :shallow => true).response.content )
groups = groups.keys.grep(/^MERGE Stores [12]/).sort
i = 0
groups.each do |g|
  puts "#{i+=1}/#{groups.size} Export group #{g}\n  ruby cityknowledge2ckdata.rb #{g}"
  `ruby cityknowledge2ckdata.rb #{g}`
end
