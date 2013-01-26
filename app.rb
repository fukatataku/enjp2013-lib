# -*- encoding: utf-8 -*-
require "rubygems"
require "sinatra"

get "/" do
    "Hello NIFTYCloud C4SA @ Evernote Hackathon 2013"
end

get "/index" do
    @name   = params[:name]

    erb :index
end