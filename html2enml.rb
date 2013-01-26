﻿# -*- encoding: utf-8 -*-

require "re"
require "json"
require "rexml/document"

require "evernote-thrift"

def html2enml(html_str)
    #html = REXML::Document.new(html_str)
    enml_str = html_str
    
    # <DOCTYPE...> の削除
    regex = /<!DOCTYPE.*?>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex, "")
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
    
    # body を en-note に変換
    regex = /<(\/)?body.*?>/im
    if enml_str.match(regex) then
        enml_str.gsub!(regex) {|match|
            match.gsub(/body/, "en-note")
        }
    end
    
    return enml_str
end