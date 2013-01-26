# -*- encoding: utf-8 -*-

require "uri"
require "net/http"
require "json"
require "rexml/document"
require "digest/md5"

require "rubygems"
require "sinatra"
require "evernote-thrift"
require "oauth"
require "oauth/consumer"

APP_KEY = "fukatataku"
APP_SECRET = "376dbdc1043a18d7"
ACS_TOKEN = "S=s1:U=5930c:E=143cc2c1cb3:C=13c747af0b7:P=1cd:A=en-devtoken:H=df21bad2666e29d9020cbd9cf55cebdb"

EN_SERVER = "https://sandbox.evernote.com"
EN_HOST = "sandbox.evernote.com"
USER_STORE_URL = "https://#{EN_HOST}/edam/user"

#APP_NOTEBOOK = "kobito_note"
APP_NOTEBOOK = "TestNotebook"

get "/index" do
    @name   = params[:name]

    erb :index
end

get "/modify" do
    puts "Web hook OK"
end

get "/modify_test" do
    
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
    targetNote = noteStore.getNote(ACS_TOKEN, guid, true, false, false, false)
    
    # ノートの内容を取得 (１行目だけ)
    doc = REXML::Document.new(targetNote.content)
    target_strings = doc.elements["/en-note/div"].get_text
    
    # MagicServerを叩く
    req_str = URI.encode("http://cbkx481-abj-app000.c4sa.net/api/magic.json?guid=#{guid}&string=#{target_string}")
    url = URI.parse(URI.encode(req_str))
    req = Net::HTTP::Get.new(url.path+"?"+url.query)
    res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
    }
    
    # レスポンスボディからPlanのHTMLを取り出す
    plan_html = JSON.parse(res.body)
    
    # HTMLをENMLに変換する
    plan_enml = html2enml(plan_html)
    
    # 既存のノートに上書き
    targetNote.content = plan_enml
    noteStore.updateNote(ACS_TOKEN, targetNote)
    
    return "Succeeded."
end

get "/auth" do
    # コールバックURL
    cb_url = "http://evernote.com/intl/jp/"
    
    # リクエストトークンを要求
    consumer = OAuth::Consumer.new(APP_KEY, APP_SECRET, {
        :site => EN_SERVER,
        :request_token_path => "/oauth",
        :access_token_path => "/oauth",
        :authorize_path => "/OAuth.action"
    })
    req_token = consumer.get_request_token(:oauth_callback => cb_url)
    
    # 認証用URLにリダイレクト
    session[:request_token] = req_token
    redirect req_token.authorize_url
end

