require 'sinatra' # load sinatra

get '/' do # default route for our website
	erb :index
end