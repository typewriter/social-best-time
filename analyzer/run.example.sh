#!/bin/bash

PATH=$HOME/.rbenv/shims:$PATH
cd `dirname "${0}"`
cat ../collector/tweet.csv | bundle exec ./place_analyzer.rb > place_supplements.json
cat ../collector/tweet.csv | bundle exec ./analyzer.rb ./place_supplements.json > results.json.tmp
mv results.json.tmp results.json

