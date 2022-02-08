require 'sinatra'
require 'sinatra/activerecord'
require './environments'

# Data
posts = [{title: "First Post", body: "content of first post"},{title: "Second Post", body: "Hellow World 2!"}]

# Models
class Post < ActiveRecord::Base
end

# Endpoints
get '/' do
  "Hello World"
end

## Custom Method for Getting Request body
def getBody (req)
    ## Rewind the body in case it has already been read
    req.body.rewind
    ## parse the body
    return JSON.parse(req.body.read)
end

## Index route
get '/posts' do
    # Return all the posts as JSON
    return posts.to_json
end

get '/posts/:id' do
    # return a particular post as json based on the id param from the url
    # Params always come to a string so we convert to an integer
    id = params["id"].to_i
    return posts[id].to_json
end

## Create Route
post '/posts' do
    # Pass the request into the custom getBody function
    body = getBody(request)
    # create the new post
    new_post = {title: body["title"], body: body["body"]}
    # push the new post into the array
    posts.push(new_post)
    # return the new post
    return new_post.to_json
end
