require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'json'
require 'open-uri'
# require 'dotenv/load'
require 'rufus-scheduler'

# Data
set :database_file, './config/database.yml'

# Models
class Letter < ActiveRecord::Base
  has_many :words
end

class Word < ActiveRecord::Base
  belongs_to :letter
  serialize :shortdef
end

# Scheduler to get a new set of letters every day at 4am.
scheduler = Rufus::Scheduler.new

scheduler.cron '0 4 * * *' do
# scheduler.every '5m' do
  # Randomly select 7 letters
  alf = ('a'..'z').to_a
  letters = alf.sample(7)
  # Ensure at at least 1 vowel
  until letters.join.match?(/[a,e,i,o,u]/) do
    letters = alf.sample(7)
  end
  # Create new Letter instance
  new_letters = Letter.new(letter: letters.join)
  new_letters.save
  # Add date to allow instance to be searchable by date
  new_letters.date = Date.parse(new_letters.created_at.strftime('%d/%m/%Y'))
  new_letters.save
  # Access GH database of English words and add to words that match letters
  prefiltered_words = get_list_of_words(letters)
  # Access Dictionary API and add words to database
  word_list_check(prefiltered_words, new_letters)
end

# Endpoints
# Index
get '/' do
  content_type 'application/json'
  todays_letters = Letter.last
  return convert_to_json(todays_letters)
end

# All Letters
get '/all' do
  content_type 'application/json'
  all = Letter.all
  all.to_json
end

# All Words
get '/words' do
  content_type 'application/json'
  all = Word.all
  all.to_json
end

# Get Letters By Date
get '/:date' do
  content_type 'application/json'
  date = params["date"]
  date_formatted = Date.iso8601(date)
  letters = Letter.find_by(date: date_formatted)
  return convert_to_json(letters)
end

# Custom Methods
def get_list_of_words(letters)
  url = 'https://raw.githubusercontent.com/dwyl/english-words/master/words_dictionary.json'
  word_serialized = URI.open(url).read
  gitwords = JSON.parse(word_serialized)
  prefiltered_words = []
  gitwords.each_key do |key|
    if (key.include? letters[0]) && (/^[#{letters}]{4,}$/ === key)
      prefiltered_words << key
    end
  end
  prefiltered_words
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

def convert_to_json(letters)
  # get words and definitions
  words_and_def = {}
  letters.words.each do |word|
    words_and_def[word.word] = word.shortdef
  end
  # set json format
  json = [{ letters: letters.letter, date: letters.date, words: words_and_def }]
  json.to_json
end
