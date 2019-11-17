#!/usr/bin/env ruby

require 'natto'
require 'json'

@nm = Natto::MeCab.new('--node-format=%f[1]\t%f[2]')

prefs = [
[/北海道/, "北海道"],
[/青森/, "青森"],
[/岩手/, "岩手"],
[/宮城/, "宮城"],
[/秋田/, "秋田"],
[/山形/, "山形"],
[/福島/, "福島"],
[/茨城/, "茨城"],
[/栃木/, "栃木"],
[/群馬/, "群馬"],
[/埼玉/, "埼玉"],
[/千葉/, "千葉"],
[/東京/, "東京"],
[/神奈川/, "神奈川"],
[/新潟/, "新潟"],
[/富山/, "富山"],
[/石川/, "石川"],
[/福井/, "福井"],
[/山梨/, "山梨"],
[/長野/, "長野"],
[/岐阜/, "岐阜"],
[/静岡/, "静岡"],
[/愛知/, "愛知"],
[/三重/, "三重"],
[/滋賀/, "滋賀"],
[/[^東]京都/, "京都"],
[/大阪/, "大阪"],
[/兵庫/, "兵庫"],
[/奈良/, "奈良"],
[/和歌山/, "和歌山"],
[/鳥取/, "鳥取"],
[/島根/, "島根"],
[/岡山/, "岡山"],
[/広島/, "広島"],
[/山口/, "山口"],
[/徳島/, "徳島"],
[/香川/, "香川"],
[/愛媛/, "愛媛"],
[/高知/, "高知"],
[/福岡/, "福岡"],
[/佐賀/, "佐賀"],
[/長崎/, "長崎"],
[/熊本/, "熊本"],
[/大分/, "大分"],
[/宮崎/, "宮崎"],
[/鹿児島/, "鹿児島"],
[/沖縄/, "沖縄"],
]


results = {}

STDIN.each { |line|
  items = line.chomp.split(/,/, 3)
  next if items.size != 3

  nodes = @nm.enum_parse(items[2])
  places = nodes.select { |node| node.feature =~ /固有名詞\t(地域|一般)/ }.map { |node| node.surface }.select { |surface| surface !~ /[ -~｡-ﾟ]/ && surface =~ /[一-龠々]/ }
  next if places.empty?

  pref_candidates = prefs.select { |pref| items[2] =~ pref[0] }.map { |pref| pref[1] }
  next if pref_candidates.empty?

  places.each { |place|
    results[place] = [] if !results.has_key?(place)
    results[place] += pref_candidates
  }
}

place_prefs = results.map { |place, pref_candidates|
  pref_counts = pref_candidates.group_by { |pref| pref }.map { |pref, array| [pref, array.size] }.to_h
  pref = pref_counts.max_by { |e| e[1] }
  [place, { guess_prefecture: pref[0], guess_prefecture_accuracy: pref[1].to_f / pref_candidates.size, samples: pref_counts }]
}.to_h

puts place_prefs.to_json

