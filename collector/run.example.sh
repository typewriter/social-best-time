#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
bundle exec ./collector.rb ../config.yml >> tweet.csv
sort -S 100M -T /var/tmp tweet.csv | uniq > tweet.csv.tmp
mv tweet.csv.tmp tweet.csv

