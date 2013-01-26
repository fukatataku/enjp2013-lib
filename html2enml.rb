# -*- encoding: utf-8 -*-

require "open-uri"
require "digest/md5"
require "evernote-thrift"

def html2enml(html_str)
    #html = REXML::Document.new(html_str)
    enml_str = html_str
    
    # <DOCTYPE...> の削除
    regex = /<!DOCTYPE.*?>/im
    head_str = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
EOF
    if enml_str.match(regex) then
        enml_str.gsub!(regex, head_str)
    end
    
    # <html>, </html> の削除
    regex = /<[\/]?html.*?>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex, "")
    end
    
    # <head>...</head> の削除
    regex = /<head.*?>.*?<\/head>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex, "")
    end
    
    # <body> を <en-note> に変換
    regex = /<body.*?>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex) {|match|
            match.gsub(/body/, 'en-note bgcolor="rgb(3, 186, 38)"')
        }
    end
    
    # </body> を </en-note> に変換
    regex = /<\/body.*?>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex) {|match|
            match.gsub(/body/, "en-note")
        }
    end
    
    # imgタグを消す
    #regex = /<img.*?\/>/im
    #enml_str.gsub!(regex, "")
    
    # imgタグをen-mediaに置き換える
    #regex = /<img src=(.*?)\/>/im
    #enml_str.gsub!(regex) { |match|
    #    match.gsub(/img/, "en-media")
    #}
    
    # en-mediaタグからsrcを取り出す
    #regex = /<img src="(.+?)".*?>/im
    #match_strs = enml_str.scan(regex)
    #match_strs.each do |match_str|
    #    reg = /src="(.+?)"/im
    #    match_str.
    #end
    
    #match = enml_str.match(regex)
    #img_src = match[0]
    #ext = File.extname(img_src).sub(".", "")
    
    # srcをダウンロード
    #img = open(img_src)
    
    # data
    #data = Evernote::EDAM::Type::Data.new
    #data.size = img.size
    #data.bodyHash = hashFunc.digest(img)
    #data.body = image
    
    # resource
    #resource = Evernote::EDAM::Type::Resource.new
    #resource.mime = "image/#{ext}"
    #resource.data = data
    #resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
    #resource.attributes.fileName = "image.#{ext}"
    
    # hash
    #hashHex = hashFunc.hexdigest(img)
    
    # imgタグを変換
    
    return enml_str#, resource
end
