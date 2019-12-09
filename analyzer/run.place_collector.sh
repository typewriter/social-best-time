#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
DATE=`date +%Y%m%d`

bundle exec ./place_collector.rb ../config.yml results.json >> place_tweet_${DATE}.csv
sort -S 100M -T /var/tmp place_tweet_${DATE}.csv | uniq > place_tweet_${DATE}.csv.tmp
mv place_tweet_${DATE}.csv.tmp place_tweet_${DATE}.csv

