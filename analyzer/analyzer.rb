#!/usr/bin/env ruby

require 'natto'
require 'json'

@nm = Natto::MeCab.new('--node-format=%f[1]\t%f[2]')


def calculate_point(sentence, nodes)
  # 0: 青葉
  # 1: 見頃
  # 2: 落葉

  point_map = {
    "もうすぐ" => 0.8, "あと少し" => 0.8, "もう少し" => 0.8,
    "あとちょっと" => 0.8, "もうちょっと" => 0.8,
    "早かった" => 0.5, "早い" => 0.5,
    "まだ" => 0.2, "全然" => 0.2, "青葉" => 0,
    "色付き始め" => 0.5, "色づき始め" => 0.5, "色付きはじめ" => 0.5, "色づきはじめ" => 0.5,
    "見頃" => 1, "見ごろ" => 1, "見頃は" => 0.5, "見頃予想" => 0,
    "終わり" => 2, "色あせ" => 1.5, "色褪せ" => 1.5, "散り始め" => 1.5
  }

  points = []
  point_map.each { |k, v| points << v if sentence.include?(k) }

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

