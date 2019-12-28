#!/usr/bin/env ruby

require 'natto'
require 'json'
require 'time'

@nm = Natto::MeCab.new('--node-format=%f[1]\t%f[2]')


def calculate_point(sentence, nodes)
  # 0: つぼみ
  # 1: 満開
  # 2: 青葉（葉桜）

  point_map = {
    /つぼみ/ => 0.0,
    /開花/ => 0.3,
    /(1|１|一)分咲き/ => 0.3,
    /(2|２|二)分咲き/ => 0.4,
    /(3|３|三)分咲き/ => 0.5,
    /(4|４|四)分咲き/ => 0.6,
    /(5|５|五)分咲き/ => 0.6,
    /(6|７|六)分咲き/ => 0.7,
    /(7|７|七)分咲き/ => 0.8,
    /(8|８|八)分咲き/ => 0.8,
    /(9|９|九)分咲き/ => 0.9,
    /満開|見頃/ => 1.0,
    /散り始め/ => 1.3,
    /落花盛ん/ => 1.6,
    /青葉|葉桜|終わり/ => 2.0
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

  places = nodes.
    select { |node| node.feature =~ /固有名詞\t(一般)/ }.
    map { |node| node.surface }.
    select { |surface| surface !~ /[ -~｡-ﾟ]/ && surface =~ /[一-龠々]/ }.
    uniq
  return [] if places.empty?

  point = calculate_point(sentence, nodes)
  return [] if !point

  places.map { |place| [place, point] }
end

def convert_score(score)
  if score >= 1.7
    '葉桜'
  elsif score >= 1.4
    '落花盛ん'
  elsif score > 1.1
    '散り始め'
  elsif score > 0.9
    '満開'
  elsif score > 0.7
    '七分咲き'
  elsif score > 0.5
    '五分咲き'
  elsif score > 0.35
    '三分咲き'
  elsif score > 0.2
    '開花'
  else
    'つぼみ'
  end
end

results = {}

STDIN.each { |line|
  items = line.chomp.split(/,/, 6)

  message = nil
  tweet = {}
  if items.size == 3
    message = items[2]
    tweet = { created_at: Time.parse(items[0]).getlocal, screen_name: items[1], text: items[2] }
  elsif items.size == 5
    message = items[4]
    tweet = { created_at: Time.parse(items[0]).getlocal, screen_name: items[1], user_id: items[2], tweet_id: items[3], text: items[4] }
  elsif items.size == 6
    message = items[5]
    tweet = { created_at: Time.parse(items[0]).getlocal, screen_name: items[1], user_id: items[2], tweet_id: items[3], media: items[4], text: items[5] }
  else
    next
  end

  next if (Time.now - tweet[:created_at]) > 24 * 60 * 60 * 4

  places = parse_and_calculate(message)

  if !places.empty?
    places.each { |place|
      results[place[0]] = { scores: [], tweets: [] } if !results.has_key?(place[0])
      results[place[0]][:scores] << place[1]
      results[place[0]][:tweets] << tweet.merge({ score: place[1] })
    }
  end
}

# 補足情報がある場合はマージ
if ARGV[0] && File.exist?(ARGV[0])
  place_supplements = JSON.parse(File.read(ARGV[0]))
  results.each { |place, result|
    if place_supplements.has_key?(place)
      result.merge!(place_supplements[place])
    end
  }
end

place_scores = results.map { |place, result|
  score = result[:scores].sum.to_f / result[:scores].size
  [place, result.merge({ score: score, score_text: convert_score(score) })]
}.select { |e| e[1][:scores].size >= 2 }.to_h

puts place_scores.to_json

