#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
bundle exec ./collector.rb ../config.yml >> tweet.csv
cat tweet.csv | sort | uniq > tweet.csv.tmp
mv tweet.csv.tmp tweet.csv

