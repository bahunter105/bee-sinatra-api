require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'
require 'open-uri'


# Data
set :database_file, './config/database.yml'
posts = [{title: "First Post", body: "content of first post"},{title: "Second Post", body: "Hellow World 2!"}]

# Models
class Letter < ActiveRecord::Base
  has_many :words
end

class Word < ActiveRecord::Base
  belongs_to :word
  has_many :shortdefs
end

class Shortdefs < ActiveRecord::Base
  belongs_to :word
end

# Endpoints
get '/' do
  # "Hello World"
  # letters = Letter.new(letter: "hihunter")
  # letters.save
  url = "https://raw.githubusercontent.com/dwyl/english-words/master/words_dictionary.json"
  word_serialized = URI.open(url).read
  word = JSON.parse(word_serialized)
  alf = ('a'..'z').to_a
  letters = alf.sample(7)
  # letters = ["b", "l", "f", "g", "e", "t", "p"]
  until letters.join.match?(/[a,e,i,o,u]/) do
    letters = alf.sample(7)
  end
  new_letters = Letter.new(letter: letters.join)
  new_letters.save

  # prefiltered_words = []
  # word.each_key do |key|
  #   if (key.include? letters[0]) && (/^[#{letters}]{4,}$/ === key)
  #     prefiltered_words << key
  #   end
  # end
  # filtered_words = word_list_check(prefiltered_words)

  return Letter.last.to_json
end

def word_list_check(prefiltered_words)
    words_and_def = {}
    prefiltered_words.each do |word|
      url = "https://dictionaryapi.com/api/v3/references/collegiate/json/#{word}?key=#{ENV['DICTIONARY_API_KEY']}"
      word_def_serialized = URI.open(url).read
      word_def = JSON.parse(word_def_serialized)
      unless word_def[0]['shortdef'].nil?
        words_and_def[:"#{word}"] = word_def[0]['shortdef']
      end
    end
    filtered_words = []
    words_and_def.each_key do |key|
      filtered_words << key
    end
    return filtered_words
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
