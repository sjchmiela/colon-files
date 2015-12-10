#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/activerecord'
require 'multi_json'
require 'yaml'

require_relative 'helpers.rb'
require_relative 'model.rb'

## Configuration for sinatra. Bind to port 80 on all interfaces
set :bind, '0.0.0.0'
set :port, 80
set :logging, true

configure do
  config = YAML.load_file(File.join(__dir__, 'config.yml'))
  database = {
    adapter: 'mysql2',
    database: ENV['DB_COLON_FILES_DATABASE'],
    username: ENV['DB_COLON_FILES_USERNAME'],
    password: ENV['DB_COLON_FILES_PASSWORD'],
    host: "db",
    encoding: "utf8",
    pool: 5
  }
  ActiveRecord::Base.establish_connection(database)
  FileUtils.mkpath(config['solutions']['path'])
  FileUtils.mkpath(config['tasks']['path'])
end

# Routes

# Testing
get '/' do
  @solutions = Solution.all
  @tasks = Task.all
  erb :index
end
get '/solutions/:solution_id/attach' do
  erb :attach_solution, locals: { solution_id: params[:solution_id] }
end
get '/tasks/:task_id/attach' do
  erb :attach_task, locals: { task_id: params[:task_id] }
end

get '/solutions/:solution_id' do
  # Check if solution with such id exists
  unless Solution.exists?(params[:solution_id])
    halt 404, json(success: false,
                   message: 'Could not find solution with specified ID.')
  end

  solution = Solution.find(params[:solution_id])

  # Check if solution file exists
  unless File.file?(solution.file_path)
    halt 404, json(success: false,
                   message: 'Could not find file for solution with specified ID.')
  end

  send_file solution.file_path
end

get '/tasks/:task_id/in' do
  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  task = Task.find(params[:task_id])

  # Check if task file exists
  unless File.file?(task.in_file_path)
    halt 404, json(success: false,
                   message: 'Could not find infile for task with specified ID.')
  end

  send_file task.in_file_path
end

get '/tasks/:task_id/out' do
  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  task = Task.find(params[:task_id])

  # Check if task file exists
  unless File.file?(task.out_file_path)
    halt 404, json(success: false,
                   message: 'Could not find outfile for task with specified ID.')
  end

  send_file task.out_file_path
end

###

post '/solutions/:solution_id' do
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

  solution = Solution.find(params[:solution_id])

  unless solution.file_path.nil? || solution.file_path.empty?
    halt 403, json(success: false,
                   message: 'You cannot overwrite solution file. Submit new solution.')
  end

  # Move file
  file_path = Solution.path(params[:solution_id])
  FileUtils.move(tmpfile.path, file_path)
  p file_path

  # Update file path in database
  solution.file_path = file_path
  if solution.save
    json(success: true, message: 'File saved and attached to the proper solution.')
  else
    json(success: false, message: solution.errors.to_s)
  end
end

post '/tasks/:task_id' do
  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  # Check if any file is attached
  unless params[:task_in_file].nil? || params[:task_out_file].nil?
    halt 400, json(success: false,
                   message: 'No files attached.')
  end

  task = Task.find(params[:task_id])

  { task_in_file: :in_file_path, task_out_file: :out_file_path }.each do |key, attribute|
    next if params[key].nil?
    if File.file?(task[attribute])
      begin
        FileUtils.rm(task[attribute])
      rescue Exception
        puts "Could not remove file #{task[attribute]}."
      end
    end
    file = params[key][:tempfile]
    path = (key == :task_in_file) ? Task.inPath(params[:task_id]) : Task.outPath(params[:task_id])
    FileUtils.move(file.path, path)
    task[attribute] = path
  end

  # Update file path in database
  if task.save
    json(success: true, message: 'Files saved and attached to the proper task.')
  else
    json(success: false, message: solution.errors.to_s)
  end
end
