#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
cat ../collector/tweet.csv | bundle exec ./place_collector.rb ../config.yml results.json >> place_tweet.csv
cat place_tweet.csv | sort | uniq > place_tweet.csv.tmp
mv place_tweet.csv.tmp place_tweet.csv

