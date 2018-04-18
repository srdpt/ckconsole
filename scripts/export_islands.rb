#!/usr/bin/env ruby
# encoding: UTF-8

require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'
require 'pr_geohash'

SRC = "https://vpc.firebaseio.com/"
KEY = "T3EuQdpb9BCR3RSF2G2z43K7YOgqaD6HcEdjuy1F"
FB = Firebase::Client.new(SRC, KEY); nil

islands = JSON.parse( FB.get("cartography/features").response.content ); nil
result = {}
islands.each{|k,v|
  # puts "MAP: #{v['properties']['maps'].to_a[0]}--\nTYPE: #{v['properties']['type']}--"
  if v['properties']['maps'].to_a[0] == 'debarbari' && v['properties']['type'] == 'island'
    result[k.to_s] = v
  end
}; nil

File.open("islands_20151116.json", "w"){|f| f.puts result.to_json }
