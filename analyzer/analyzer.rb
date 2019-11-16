#!/usr/bin/env ruby

require 'natto'
require 'json'

@nm = Natto::MeCab.new('--node-format=%f[1]\t%f[2]')


def calculate_point(sentence, nodes)
  # 0: 青葉
  # 1: 見頃
  # 2: 落葉

  point_map = {
    /青葉/ => 0, /全然/ => 0.1, /まだ/ => 0.2,
    /(はや|早|速)(い|かった)/ => 0.4,
    /色[づ付]き/ => 0.4,
    /一部/ => 0.6,
    /(あと|もう)少し/ => 0.7, /(あと|もう)ちょっと/ => 0.8,
    /そろそろ|もうすぐ/ => 0.8,
    /ちょうど/ => 1, /見(頃|ごろ)[^は予]/ => 1,
    /(ちょっと|少し)遅かった/ => 1.5, /色(褪|あ)せ/ => 1.5, /(散|ち)り(始|はじ)め/ => 1.5,
    /落葉[は始]/ => 1.5,
    /落葉[^は始]/ => 2, /終わり/ => 2, /終わって/ => 2, /散って/ => 2
  }

  points = []
  point_map.each { |k, v| points << v if sentence =~ k }

  if points.empty?
    nil
  else
    points.sum.to_f / points.size
  end
end

def parse_and_calculate(sentence)
  nodes = @nm.enum_parse(sentence)

  places = nodes.select { |node| node.feature =~ /固有名詞\t(地域|一般)/ }.map { |node| node.surface }.select { |surface| surface !~ /[ -~｡-ﾟ]/ && surface =~ /[一-龠々]/ }
  return [] if places.empty?

  point = calculate_point(sentence, nodes)
  return [] if !point

  places.map { |place| [place, point] }
end

def convert_score(score)
  if score >= 1.5
    '落葉'
  elsif score > 1.2
    '落葉始め'
  elsif score > 0.8
    '見頃'
  elsif score > 0.6
    '見頃近し'
  elsif score > 0.4
    '色づき始め'
  else
    '青葉'
  end
end

results = {}

STDIN.each { |line|
  items = line.chomp.split(/,/, 3)
  next if items.size != 3

  places = parse_and_calculate(items[2])

  if !places.empty?
    places.each { |place|
      results[place[0]] = [] if !results.has_key?(place[0])
      results[place[0]] << place[1]
    }
  end
}

place_scores = results.map { |place, scores|
  [place, { score: scores.sum.to_f / scores.size, score_text: convert_score(scores.sum.to_f / scores.size), scores: scores }]
}.select { |e| e[1][:scores].size >= 2 }.to_h

puts place_scores.to_json

