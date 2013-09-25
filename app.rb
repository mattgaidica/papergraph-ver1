require 'rubygems'
require 'neography'
require 'open_calais'
require './clean.rb'
require 'docsplit'

# these are the default values:
Neography.configure do |config|
  config.protocol       = "http://"
  config.server         = "localhost"
  config.port           = 7474
  config.directory      = ""  # prefix this path with '/' 
  config.cypher_path    = "/cypher"
  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file       = "neography.log"
  config.log_enabled    = false
  config.max_threads    = 20
  config.authentication = nil  # 'basic' or 'digest'
  config.username       = nil
  config.password       = nil
  config.parser         = MultiJsonParser
end

#read file into text, clean and remove linebreaks
pdf_filename = "Tonnesen, PLOS, 2011_stem cell monitoring by optogenetics in vitro parkinson model.pdf"
Docsplit.extract_text(pdf_filename)
text_filename = pdf_filename.split('/').last.split('.').first + '.txt'
s = IO.read(text_filename)
s = clean(s) 

#get meta
author_meta = Docsplit.extract_author(pdf_filename)
authors = author_meta.nil? ? [] : author_meta.split(';')
title = Docsplit.extract_title(pdf_filename)
title = pdf_filename.split('/').last.split('.').first if title.nil? || title.size < 15
date = Docsplit.extract_date(pdf_filename)

#load blacklist into array, remove all of them, chop string to 100,000
blacklist = IO.read("5000-wordlist.txt").split("\n")
s = s.split.delete_if{|x| blacklist.include?(x.downcase)}.join(' ')
s = s[0..999999]

#call calais and get tags
open_calais = OpenCalais::Client.new(:api_key=>'22tj3w8adh5rs7wtv93wtqhy')
response = open_calais.enrich(s)
tags = response.tags

#create nodes and relationships
paper_node = Neography::Node.create("title" => title)


authors.each do |author|
  author_node = Neography::Node.create("name" => author)
  author_node.outgoing(:authored) << paper_node
end

tags.each do |tag|
  begin
    existing_node = Neography::Node.find("Topics", "name", tag[:name])
  rescue
    existing_node = nil
  end
  if existing_node.nil?
    tag_node = Neography::Node.create("name" => tag[:name])
    tag_node.add_to_index("Topics", "name", tag[:name])
  else
    tag_node = existing_node
  end
  tag_node.incoming(:is_about) << paper_node
end

# Neography::Relationship.create(:friends, n1, n2)
# n1.outgoing(:friends) << n2                                          # Create outgoing relationship
# n1.incoming(:friends) << n2                                          # Create incoming relationship
# n1.both(:friends) << n2                                              # Create both relationships

