#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
bundle exec ./collector.rb ../config.yml > tweet.csv.tmp
cat tweet.csv.tmp | sort | uniq > tweet.csv.tmp.2
rm tweet.csv.tmp
mv tweet.csv.tmp.2 tweet.csv

