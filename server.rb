require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'
require 'open-uri'
require 'dotenv/load'
require 'rufus-scheduler'


# Data
set :database_file, './config/database.yml'
posts = [{title: "First Post", body: "content of first post"},{title: "Second Post", body: "Hellow World 2!"}]


# Models
class Letter < ActiveRecord::Base
  has_many :words
end

class Word < ActiveRecord::Base
  belongs_to :letter
  serialize :shortdef
end

# Scheduler
scheduler = Rufus::Scheduler.new

scheduler.cron '25,30 14 * * *' do
# scheduler.every '24h' do
  # new_letters = Letter.new(letter: "12345")
  # new_letters.save
  url = "https://raw.githubusercontent.com/dwyl/english-words/master/words_dictionary.json"
  word_serialized = URI.open(url).read
  gitwords = JSON.parse(word_serialized)
  alf = ('a'..'z').to_a
  letters = alf.sample(7)
  until letters.join.match?(/[a,e,i,o,u]/) do
    letters = alf.sample(7)
  end
  new_letters = Letter.new(letter: letters.join)
  new_letters.save

  prefiltered_words = []
  gitwords.each_key do |key|
    if (key.include? letters[0]) && (/^[#{letters}]{4,}$/ === key)
      prefiltered_words << key
    end
  end
  word_list_check(prefiltered_words, new_letters)
end

# Endpoints
get '/' do
  todays_letters = Letter.last
  words_and_def = {}
  todays_letters.words.each do |word|
    words_and_def[word.word] = word.shortdef
  end

  json = [ letters: todays_letters.letter, date: todays_letters.created_at, words: words_and_def]

  return JSON.generate(json)
end

def word_list_check(prefiltered_words, new_letters)
  prefiltered_words.each do |word|
    url = "https://dictionaryapi.com/api/v3/references/collegiate/json/#{word}?key=#{ENV['DICTIONARY_API_KEY']}"
    word_def_serialized = URI.open(url).read
    word_def = JSON.parse(word_def_serialized)
    unless word_def[0]['shortdef'].nil?
      new_word = Word.new(word: word, shortdef: word_def[0]['shortdef'])
      new_word.letter = new_letters
      new_word.save
    end
  end
end


# ## Custom Method for Getting Request body
# def getBody (req)
#     ## Rewind the body in case it has already been read
#     req.body.rewind
#     ## parse the body
#     return JSON.parse(req.body.read)
# end

# ## Index route
# get '/posts' do
#     # Return all the posts as JSON
#     return posts.to_json
# end

# get '/posts/:id' do
#     # return a particular post as json based on the id param from the url
#     # Params always come to a string so we convert to an integer
#     id = params["id"].to_i
#     return posts[id].to_json
# end

# ## Create Route
# post '/posts' do
#     # Pass the request into the custom getBody function
#     body = getBody(request)
#     # create the new post
#     new_post = {title: body["title"], body: body["body"]}
#     # push the new post into the array
#     posts.push(new_post)
#     # return the new post
#     return new_post.to_json
# end
