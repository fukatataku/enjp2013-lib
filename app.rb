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
    
    # 変更の種類が「更新」であれば無視して200 OKを返す
    # ※自分自身による書き換えを無視するため
    if params[:reason] == "update" then
        return
    end
    
    "create note"
end

