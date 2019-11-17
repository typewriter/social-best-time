#!/usr/bin/env ruby

require "sinatra"
require "sinatra/json"
require "json"
require "sinatra/reloader"

@@json = JSON.parse(File.read('../../analyzer/results.json'))

get '/' do
  @list = @@json.sort_by { |k, v| v["scores"].size }.reverse.take(60)
  erb :list
end



