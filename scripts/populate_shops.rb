#!/usr/bin/env ruby
# encoding: UTF-8

# PARTO DA
# https://portale.comune.venezia.it/node/96/5468707
# Parto poi da layer di piero
# ogr2ogr -f GeoJSON civici_venezia.geojson civici_venezia.shp
# http://www.wpi.edu/Pubs/E-project/Available/E-project-122610-202225/unrestricted/FinalReport_B10.pdf
# https://sites.google.com/site/ve12stores/


require 'httpclient'
require 'firebase'
require 'json'
require 'active_support/all'
require 'pr_geohash'
require 'simple_xlsx_reader'

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
# DA 
CAP = {
  30121 => 'CN',
  30122 => 'CS',
  30123 => 'DD',
  30124 => 'SM',
  30125 => 'SP',
  30135 => 'SC'
}

# dati = CSV.read("Botteghe.csv"); nil
doc = SimpleXlsxReader.open('Botteghe.xlsx'); nil
geo = JSON.parse(File.open('Street_adresses/civici_venezia.geojson').read)['features'].map{|f|
  res = f['properties']
  res['Codice_Ses'] = 'DD' if res['Codice_Ses'].to_s == 'GD'
  res
}; nil

tot = doc.sheets.first.rows[1..-1].size
i = 0
doc.sheets.first.rows[1..-1].sort{|a,b| a[2] <=> b[2] }.each do |r|
  puts "#{i+=1}/#{tot} #{r[2]}"
  riga = {
    'PRV              '.strip.downcase.gsub('-', '_').to_sym => r[ 0],
    'N-REG-IMP        '.strip.downcase.gsub('-', '_').to_sym => r[ 1],
    'N-REA            '.strip.downcase.gsub('-', '_').to_sym => r[ 2],
    'UL-SEDE          '.strip.downcase.gsub('-', '_').to_sym => r[ 3],
    'N-ALBO-AA        '.strip.downcase.gsub('-', '_').to_sym => r[ 4],
    'SEZ-REG-IMP      '.strip.downcase.gsub('-', '_').to_sym => r[ 5],
    'NG               '.strip.downcase.gsub('-', '_').to_sym => r[ 6],
    'DT-ISCR-RI       '.strip.downcase.gsub('-', '_').to_sym => r[ 7],
    'DT-ISCR-RD       '.strip.downcase.gsub('-', '_').to_sym => r[ 8],
    'DT-ISCR-AA       '.strip.downcase.gsub('-', '_').to_sym => r[ 9],
    'DT-APER-UL       '.strip.downcase.gsub('-', '_').to_sym => r[10],
    'DT-CESSAZ        '.strip.downcase.gsub('-', '_').to_sym => r[11],
    'DT-INI-AT        '.strip.downcase.gsub('-', '_').to_sym => r[12],
    'DT-CES-AT        '.strip.downcase.gsub('-', '_').to_sym => r[13],
    'DT-FALLIM        '.strip.downcase.gsub('-', '_').to_sym => r[14],
    'DT-LIQUID        '.strip.downcase.gsub('-', '_').to_sym => r[15],
    'DENOMINAZIONE    '.strip.downcase.gsub('-', '_').to_sym => r[16],
    'INDIRIZZO        '.strip.downcase.gsub('-', '_').to_sym => r[17],
    'STRAD            '.strip.downcase.gsub('-', '_').to_sym => r[18],
    'CAP              '.strip.downcase.gsub('-', '_').to_sym => r[19],
    'COMUNE           '.strip.downcase.gsub('-', '_').to_sym => r[20],
    'FRAZIONE         '.strip.downcase.gsub('-', '_').to_sym => r[21],
    'ALTRE-INDICAZIONI'.strip.downcase.gsub('-', '_').to_sym => r[22],
    'AA-ADD           '.strip.downcase.gsub('-', '_').to_sym => r[23],
    'IND              '.strip.downcase.gsub('-', '_').to_sym => r[24],
    'DIP              '.strip.downcase.gsub('-', '_').to_sym => r[25],
    'C-FISCALE        '.strip.downcase.gsub('-', '_').to_sym => r[26],
    'PARTITA-IVA      '.strip.downcase.gsub('-', '_').to_sym => r[27],
    'TELEFONO         '.strip.downcase.gsub('-', '_').to_sym => r[28],
    'CAPITALE         '.strip.downcase.gsub('-', '_').to_sym => r[29],
    'ATTIVITA         '.strip.downcase.gsub('-', '_').to_sym => r[30],
    'CODICI-ATTIVITA  '.strip.downcase.gsub('-', '_').to_sym => r[31],
    'VALUTA-CAPITALE  '.strip.downcase.gsub('-', '_').to_sym => r[32]
  }
  sestiere = CAP[riga[:cap].to_i]
  if sestiere
    riga[:cod_sestiere] = sestiere
    if riga[:indirizzo] =~ /\s([0-9]+)[\/]{0,1}([A-Z]{0,1})/
      civico  = $1
      civico = "000000#{civico}"[-5,5]
      lettera = $2
      lettera = '_' if lettera == ''
      my_civico = geo.detect{|g| g['Codice_Ses'] == sestiere && g['LETTERA'] == lettera && g['CIVICO'] == civico}
      if my_civico
        riga[:chiave_civico] = my_civico['CHIAVE']
        riga[:lat] = my_civico['Y']
        riga[:lng] = my_civico['X']
        riga[:g] = GeoHash.encode(riga[:lat], riga[:lng])
      else
        riga[:chiave_civico] = 'NOT FOUND'
      end
    else
      riga[:chiave_civico] = 'NN'
    end
  else
    riga[:cod_sestiere] = 'NN'
  end
  FB.set("shops/#{riga[:n_rea]}", riga)
end
