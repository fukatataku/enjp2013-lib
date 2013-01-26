# -*- encoding: utf-8 -*-
require "rubygems"
require "sinatra"

get "/hello" do
    "Hello NIFTYCloud C4SA @ Evernote Hackathon 2013"
end

get "/index" do
    @name   = params[:name]

    erb :index
end

get "/modify" do
    "modify"
end

