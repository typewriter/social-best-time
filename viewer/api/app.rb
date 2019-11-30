#!/usr/bin/env ruby

require "sinatra"
require "sinatra/json"
require "json"
require "sinatra/reloader"
require 'uri'

@@json = JSON.parse(File.read('../../analyzer/results.json')).select { |k, v|
  k !~ /^(.+観光客|外国人.+|最盛期|今日この頃|.+気温|何度|四季桜|可能性|寒い朝|世界遺産|誕生日|今シーズン|黄緑|[０-９]+日|皇室献上|.+観光|お久しぶり|開催中|全国的|敷地内|温暖化|五平餅|お勧め|青紅葉|.+に|.+科|.+流星群|.+の|.+旅行|暑さ|.+的|桜の木|桜を見る会|ロケ地|.+公開|女子力|仙山線|お題|お姉ちゃん|外国人|私たち|朝活|好きだ|平野部|数年|異常気象|トロッコ列車|知らんけど|山手線|予防接種|午前中|募集中|.週間|観光.+|冬桜|落葉高木|今月末|.+市内|目的地|質問箱|.+人|.+年前|リア充|.回|分からん|.+希望|オフ会|聖地巡礼|子どもたち|大嘗宮|代表者|落羽松|つけ麺|定点観測|入場料|競馬場|.年|.枚|.?週末|冷たい雨|娘|お客さん|時間帯|涙)$/
}
@@time = File.mtime('../../analyzer/results.json')

get '/:pref?' do
  list = @@json.to_a
  if params[:pref]
    @pref = params[:pref]
    list.select! { |item| item[1]["guess_prefecture"] && item[1]["guess_prefecture"] == params[:pref] }
  end

  @list = list.sort_by { |item| item[1]["scores"].size }.reverse.select { |e| e[1]["guess_prefecture"] && e[1]["guess_prefecture_accuracy"] > 0.4 }.take(30).sort_by { |e| (e[1]["score"] - 1).abs + (1 / e[1]["scores"].size.to_f * 4) }
  erb :list
end



