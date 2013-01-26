﻿# -*- encoding: utf-8 -*-

require "rubygems"
require "sinatra"
require "digest/md5"
require "evernote-thrift"

APP_KEY = "fukatataku"
APP_SECRET = "376dbdc1043a18d7"
ACS_TOKEN = "S=s1:U=5930c:E=143cc2c1cb3:C=13c747af0b7:P=1cd:A=en-devtoken:H=df21bad2666e29d9020cbd9cf55cebdb"

EN_HOST = "sandbox.evernote.com"
USER_STORE_URL = "https://#{EN_HOST}/edam/user"

#APP_NOTEBOOK = "kobito_note"
APP_NOTEBOOK = "TestNotebook"

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
    
    # ユーザーストアを作成
    userStoreTransport = Thrift::HTTPClientTransport.new(USER_STORE_URL)
    userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
    userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)
    
    # ノートストアを作成
    noteStoreUrl = userStore.getNoteStoreUrl(ACS_TOKEN)
    noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
    
    # ノートブックのリストを取得
    #notebooks = noteStore.listNotebooks(ACS_TOKEN)
    #puts "Found #{notebooks.size} notebooks"
    #notebooks.each do |notebook|
    #    puts " * #{notebook.name}"
    #end
    
    # 最も直近に変更されたノートを見つける
    pageSize = 10
    
    filter = Evernote::EDAM::NoteStore::NoteFilter.new()
    filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
    filter.words = 'notebook:"TestNotebook"'
    
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new()
    spec.includeTitle = true
    
    notesMetadata = noteStore.findNotesMetadata(ACS_TOKEN, filter, 0, pageSize, spec)
    targetNoteMetadata = notesMetadata.notes[0]
    guid = targetNoteMetadata.guid
    targetNote = noteStore.getNote(ACS_TOKEN, guid, false, false, false, false)
    puts "NOTE TITLE: #{targetNote.title}"
    puts targetNote.content
end

