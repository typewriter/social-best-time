#!/usr/bin/env ruby

require 'twitter'
require 'yaml'

config = YAML.load_file(ARGV[0])

client = Twitter::REST::Client.new(
  consumer_key:        config['twitter']['consumer_key'],
  consumer_secret:     config['twitter']['consumer_secret'],
  access_token:        config['twitter']['access_token'],
  access_token_secret: config['twitter']['access_token_secret'],
)

result_tweets = client.search("桜 つぼみ OR 開花 OR 三分咲き OR 五分咲き OR 七分咲き OR 満開 OR 散り始め OR 落花盛ん OR 青葉 OR 葉桜 OR 終わり OR @DummyScreenNameToAvoidSearchingByUserName", count: 100, result_type: "recent",  exclude: "retweets")

result_tweets.take(100).each { |tweet|
  puts "#{tweet.created_at},#{tweet.user.screen_name},#{tweet.user.id},#{tweet.id},#{tweet.media.size},#{tweet.full_text.gsub(/,/,"，").gsub(/\n/m, "<br>")}"
}

