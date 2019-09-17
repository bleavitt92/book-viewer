require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Homes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_title = @contents[number-1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_title}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

helpers do
  def in_paragraphs(text)
    text.prepend("<p>").gsub!(/\n\n/, "</p>\n\n<p>").concat("</p>")
    text.split("\n\n").each_with_index do |line, index|
      line.gsub!(/<p>/, "<p id=paragraph#{index}>")
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraph: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])

  erb :search
end

not_found do 
  redirect "/"
  puts "Hello"
end
