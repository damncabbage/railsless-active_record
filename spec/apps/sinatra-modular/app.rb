require 'sinatra/base'
require 'railsless/active_record/sinatra_extension'
require 'json'

class Message < ActiveRecord::Base
  # attributes: title
end

class TestSinatraApp < Sinatra::Base
  register Railsless::ActiveRecord::SinatraExtension

  get '/messages' do
    Message.all.to_json
  end
  post '/messages' do
    Message.create!(:title => params[:title]).to_json
  end
end
