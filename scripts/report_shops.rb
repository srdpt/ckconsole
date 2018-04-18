#!/usr/bin/env ruby
# encoding: UTF-8

require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'
require 'pr_geohash'

SRC = "https://ckdata.firebaseio.com/"
KEY = "6oHOTzpyRjbzO5HP7EQWclxwICXPOOv7UJpZqZFe"
FB = Firebase::Client.new(SRC, KEY); nil

members = FB.get("groups/#{URI.encode('MERGE Stores 2012')}/member_list").response.content.split(',')

tot = members.size
shops_ok = 0
shops_ko = 0
result = []
members.each{|m|
  tmp = FB.get("data/#{URI.encode(m)}").response.content
  if tmp.size > 0
    data = JSON.parse( tmp ) rescue data={}
    if data['2015']
      shops_ok += 1
    else
      shops_ko += 1
      result << "#{m}|#{(data['data'] || {})['street_and_number']}"
    end
  else
    puts "KO #{m}"
  end
  puts "Total #{tot}, OK #{shops_ok}, KO #{shops_ko}"
}
File.open('shops.csv', 'w'){|f| f.puts result.join("\n") }
puts "Total #{tot}, OK #{shops_ok}, KO #{shops_ko}"cd ..
