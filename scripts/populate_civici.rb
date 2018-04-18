#!/usr/bin/env ruby
# encoding: UTF-8

# PARTO DA
# https://portale.comune.venezia.it/node/96/5468707
# Parto poi da layer di piero
# ogr2ogr -f GeoJSON civici_venezia.geojson civici_venezia.shp

require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'
require 'pr_geohash'

SRC = "https://ckdata.firebaseio.com/"
KEY = "6oHOTzpyRjbzO5HP7EQWclxwICXPOOv7UJpZqZFe"
FB = Firebase::Client.new(SRC, KEY); nil

SESTIERI = {
  "CN" => 'Cannaregio',
  "CS" => 'Castello',
  "DD" => 'Dorsoduro',
  "GD" => 'Giudecca',
  "SC" => 'Santa Croce',
  "SM" => 'San Marco',
  "SP" => 'San Polo'
}

geo = JSON.parse(File.open('Street_adresses/civici_venezia.geojson').read); nil

tot = geo['features'].size
i = 0
puts "Vie #{tot}"
geo['features'].each do |item|
  f = item['properties']
  puts "#{i+=1}/#{tot} #{f['CHIAVE']}"
  
  lat = f['Y'].to_f
  lng = f['X'].to_f
  geohash = {}
  geohash['g'] = GeoHash.encode(lat, lng)
  geohash['l'] = [lat, lng]
  geohash['.priority'] = geohash['g']
  FB.set("_geodata_civici/#{f['CHIAVE']}", geohash)
  
  FB.set("civici/#{f['CHIAVE']}", {
    :geohash => geohash['g'],
    :lat => lat,
    :lng => lng,
    :chiave     => f['CHIAVE    '.strip],
    :codice_via => f['CODICE_VIA'.strip],
    :codice_ses => f['Codice_Ses'.strip],
    :sestiere   => SESTIERI[f['Codice_Ses'.strip]],
    :civico     => f['CIVICO    '.strip],
    :et_civ     => f['ET_CIV    '.strip],
    :lettera    => f['LETTERA   '.strip],
    :scala      => f['SCALA     '.strip],
    :interni    => f['INTERNI   '.strip],
    :piano      => f['PIANO     '.strip],
    :sub_cod_vi => f['SUB_COD_VI'.strip],
    :specie     => f['SPECIE    '.strip],
    :denominazi => f['DENOMINAZI'.strip],
    :cod_d_u    => f['COD_D_U   '.strip],
    :anomalie   => f['ANOMALIE  '.strip],
    :data_sopra => f['DATA_SOPRA'.strip],
    :anno_attri => f['ANNO_ATTRI'.strip],
  })
end