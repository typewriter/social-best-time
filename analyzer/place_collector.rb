#!/usr/bin/env ruby

require 'twitter'
require 'yaml'
require 'json'
require 'uri'

config = YAML.load_file(ARGV[0])

client = Twitter::REST::Client.new(
  consumer_key:        config['twitter']['consumer_key'],
  consumer_secret:     config['twitter']['consumer_secret'],
  access_token:        config['twitter']['access_token'],
  access_token_secret: config['twitter']['access_token_secret'],
)

places = JSON.parse(File.read(ARGV[1]))

words = ""
count = 0
places.keys.shuffle.each_with_index { |place, i|
  if places.size + 1 == i || (URI.escape(words + place)).size > 470
    result_tweets = client.search("#{words} OR @DummyScreenName", count: 100, result_type: "recent",  exclude: "retweets")

    result_tweets.take(100).each { |tweet|
      puts "#{tweet.created_at},#{tweet.user.screen_name},#{tweet.user.id},#{tweet.id},#{tweet.media.size},#{tweet.full_text.gsub(/,/,"，").gsub(/\n/m, "<br>")}"
    }

    words = ""
    count += 1
    break if count > 100 # Rate limiting
  end

  words += " OR " if !words.empty?
  words += place
}

