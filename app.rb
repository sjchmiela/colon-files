require 'sinatra'
require 'sinatra/activerecord'
require 'multi_json'

# File path
UPLOADS_PATH = './uploads/'
FileUtils.mkpath(UPLOADS_PATH)

# Model
class Solution < ActiveRecord::Base
end

# Database connection
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'colon'
)

# Helpers
helpers do
  def json(json)
    MultiJson.dump(json, pretty: true)
  end

  def file_path_for(solution_id)
    "#{UPLOADS_PATH}#{solution_id}"
  end
end

# Routes

# DEBUG
get '/' do
  Solution.all.map { |s| "<li>Solution #{s.id}: file located at #{s.file_path.empty? ? "??" : s.file_path}</li>" }.join("\n") + "<p><a href=\"/send\">Attach file</a></p>"
end
get '/send' do
  erb :send
end
# /DEBUG

get '/solutions/:solution_id' do
  # Check if solution with such id exists
  unless Solution.exists?(params[:solution_id])
    halt 404, json(success: false,
                   message: 'Could not find solution with specified ID.')
  end

  # Check if solution file exists
  unless File.file?(file_path_for(params[:solution_id]))
    halt 404, json(success: false,
                   message: 'Could not find file for solution with specified ID.')
  end

  send_file file_path_for(params[:solution_id])
end

post '/solutions' do
  # Check if solution file is attached
  unless params[:solution_file] and
         tmpfile = params[:solution_file][:tempfile]
    halt 400, json(success: false,
                   message: 'File not attached.')
  end

  # Check if solution with such id exists
  unless Solution.exists?(params[:solution_id])
    halt 404, json(success: false,
                   message: 'Could not find solution with specified ID.')
  end

  # Move temporary file to proper location
  file_path = file_path_for(params[:solution_id])
  FileUtils.move(tmpfile.path, file_path)

  # Update file path in database
  solution = Solution.find(params[:solution_id])
  solution.file_path = file_path
  solution.save

  json(success: true, message: 'File saved and attached to the proper solution.')
end
