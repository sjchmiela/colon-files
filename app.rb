#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/activerecord'
require 'multi_json'
require 'yaml'

require_relative 'helpers.rb'
require_relative 'model.rb'

configure do
  config = YAML.load_file("./config.yml")
  ActiveRecord::Base.establish_connection(config["database"])
  FileUtils.mkpath(config["solutions"]["path"])
  FileUtils.mkpath(config["tasks"]["path"])
end

# Routes


# Testing
get '/' do
  @solutions = Solution.all
  @tasks = Task.all
  erb :index
end
get '/solutions/attach' do
  erb :attach_solution
end
get '/tasks/attach' do
  erb :attach_task
end


get '/solutions/:solution_id' do
  # Check if solution with such id exists
  unless Solution.exists?(params[:solution_id])
    halt 404, json(success: false,
                   message: 'Could not find solution with specified ID.')
  end

  # Check if solution file exists
  unless File.file?(Solution.path(params[:solution_id]))
    halt 404, json(success: false,
                   message: 'Could not find file for solution with specified ID.')
  end

  send_file Solution.path(params[:solution_id])
end

get '/tasks/:task_id/in' do
  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  # Check if task file exists
  unless File.file?(Task.inPath(params[:task_id]))
    halt 404, json(success: false,
                   message: 'Could not find infile for task with specified ID.')
  end

  send_file Task.inPath(params[:task_id])
end

get '/tasks/:task_id/out' do
  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  # Check if task file exists
  unless File.file?(Task.outPath(params[:task_id]))
    halt 404, json(success: false,
                   message: 'Could not find outfile for task with specified ID.')
  end

  send_file Task.outPath(params[:task_id])
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

  # Move file
  file_path = Solution.path(params[:solution_id])
  FileUtils.move(tmpfile.path, file_path)
  p file_path

  # Update file path in database
  solution = Solution.find(params[:solution_id])
  solution.file_path = file_path
  if solution.save
    json(success: true, message: 'File saved and attached to the proper solution.')
  else
    json(success: false, message: solution.errors.to_s)
  end
end

post '/tasks' do
  # Check if task infile is attached
  unless params[:task_in_file] and
         tmp_in_file = params[:task_in_file][:tempfile]
    halt 400, json(success: false,
                   message: 'Infile not attached.')
  end

  # Check if task outfile is attached
  unless params[:task_out_file] and
         tmp_out_file = params[:task_out_file][:tempfile]
    halt 400, json(success: false,
                   message: 'Outfile not attached.')
  end

  # Check if task with such id exists
  unless Task.exists?(params[:task_id])
    halt 404, json(success: false,
                   message: 'Could not find task with specified ID.')
  end

  # Move files
  in_file_path = Task.inPath(params[:task_id])
  FileUtils.move(tmp_in_file.path, in_file_path)
  out_file_path = Task.outPath(params[:task_id])
  FileUtils.move(tmp_out_file.path, out_file_path)

  # Update file path in database
  task = Task.find(params[:task_id])
  task.in_file_path = in_file_path
  task.out_file_path = out_file_path
  if task.save
    json(success: true, message: 'Files saved and attached to the proper task.')
  else
    json(success: false, message: solution.errors.to_s)
  end
end
