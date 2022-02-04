require 'sinatra'

posts = [{title: "First Post", body: "content of first post"}]


get '/' do
  "Hello World"
end

## Index route
get '/posts' do
    # Return all the posts as JSON
    return posts.to_json
end
