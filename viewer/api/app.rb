#!/usr/bin/env ruby

require "sinatra"
require "sinatra/json"
require "json"
require "sinatra/reloader"

@@json = JSON.parse(File.read('../../analyzer/results.json'))
@@time = File.mtime('../../analyzer/results.json')

get '/' do
  @list = @@json.sort_by { |k, v| v["scores"].size }.reverse.take(99)
  erb :list
end



