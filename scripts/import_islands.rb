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

# islands = JSON.parse( FB.get("cartography/features").response.content ); nil
islands = JSON.parse( File.open("islands_20151117.json").read ); nil

islands.each{|k,v|
  puts "UPDATE: #{k}"
  FB.update("cartography/features/#{k}", v)
}; nil

