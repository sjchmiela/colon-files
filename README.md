# colon-files

Simple app in Sinatra to receive and send files to university project's subsystems.

## Installing

First you should have MySQL server running, with database `colon`. Inside you should create two tables:
```
tasks
  id:integer
  in_file_path:string
  out_file_path:string

solutions
  id:integer
  file_path:string
```
 This app does not create records, so to attach any file you first need to create sample rows yourself. Then:

1. `git clone https://github.com/sjchmiela/colon-files.git`
2. `cd colon-files`
3. `bundle install`
4. Edit database connection settings in `config.yml`.
4. `ruby app.rb`
5. Open browser, head over to `http://localhost:4567/`.

## API

### Solutions

#### Attaching solutions

`POST /solutions` — attach file `solution_file` to solution with id `solution_id`. Expects exactly these request parameters. Solution with specified `solution_id` should already be persisted in database. Returns JSON: `{success:boolean, message:text}`.

#### Retrieving solution
`GET /solutions/:solution_id` — retrieve file `solution_id`.

### Tasks

#### Attaching task files
`POST /tasks` — attach files `task_in_file` and `task_out_file` to task with id `task_id`. Expects exactly these request parameters. Task with specified `task_id` should already be persisted in database. Returns JSON: `{success:boolean, message:text}`.

#### Retrieving task files

`GET /tasks/:task_id/in` — retrieve infile of task with id `task_id`.

`GET /tasks/:task_id/out` — retrieve outfile of task with id `task_id`.

## Testing
Testing web interface is at `http://localhost:4567/` of the app.
