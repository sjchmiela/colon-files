# colon-files

Simple app in Sinatra to receive and send solution files to university project's subsystem. Files are stored in `./uploads/` directory.

## Installing

First you should have MySQL server running, with database `colon` and table `solutions` with at least columns `id:integer` and `file_path:string`. This app does not create solutions, so to attach any file you first need to create sample solution rows yourself. Then:

1. `git clone https://github.com/sjchmiela/colon-files.git`
2. `cd colon-files`
3. `bundle install`
4. Edit database connection settings in `app.rb`.
4. `ruby app.rb`
5. Open browser, head over to `http://localhost:4567/`.

## API

### Attaching file

`POST /solutions/` — attach file `solution_file` to solution with id `solution_id`. Expects exactly these request parameters. Solution with specified `solution_id` should already be persisted in database. Returns JSON: `{success:boolean, message:text}`.

### Retrieving file
`GET /solutions/:solution_id` — retrieve file `solution_id`.

## Testing

`GET /` — list all solutions from database.

`GET /send` — returns form to attach file to a solution already saved in database.
