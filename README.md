# README

## Getting started

Ensure that you are using the correct Ruby version:

```sh
$ asdf current ruby
> 3.3.3
```

Install the correct dependencies:

```sh
$ bundle install
> Bundle complete!
```

Startup Postgres container:

```sh
docker run -d --name cavelog-db -p 5432:5432 -e "POSTGRES_USER=cavelog" -e "POSTGRES_PASSWORD={{password}}" postgres:14
# or (if you have already created this container)
$ docker start cavelog-db
```

**Important:** Now set up your `.env` file according to the `.env.example`, using the `{{password}}` you defined in the step above!

You can optionally seed your database with a standard set of UK caves:

```sh
$ rake data:load_cave_csv
> Data loaded successfully!
```

Startup Elasticsearch container:

```sh
$ docker run -d --name cavelog-elasticsearch -p 127.0.0.1:9200:9200 -p 127.0.0.1:9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.17.23
# or (if you have already created this container)
$ docker start cavelog-elasticsearh
```

Now initialize the indexes:

```sh
$ rake elasticsearch:initialize_elasticsearch
> Indexes created!
```

Run the dev environment:

```sh
$ ./bin/dev
```

## Deploying to production

Make sure you have your `.env` file set up according to the `.dev.env.example`

Set up container

```sh
$ docker compose up --build -d
> Docker output
```

If running for first time, you need to initialize Elasticsearch

```sh
$ docker compose exec app bundle exec rake elasticsearch:initialize_elasticsearch
> Indexes created!
```

Optionally, you can also see the database with caves

```sh
$ docker compose exec app bundle exec rake data:load_cave_csv
> Data loaded successfully!
```

To end the process, run:

```sh
$ docker compose down
> Docker output
```

## TODOs

- [x] Add locations to log
- [x] Edit locations on log
- [x] Remove cave from log
- [x] Add caves to log
- [x] Delete unconnected locations from log
- [x] Delete unconnected cave from log
- [x] edit log details
- [x] delete a log
- [x] edit location subsystem
- [x] breadcrumb trail
- [x] create partnership request
- [x] delete sent partnership request
- [x] view pending partnership requests
- [x] deny pending partnership
- [x] accept partnership request adds partner
- [x] delete partnership
- [x] add partner connection to log
- [x] remove partner connection from log
- [x] refactor logs paths/routes
  - [x] move cave/location functions out to the cave copies/location copies controllers
  - [x] change the routes to use /log/:id{{caves|locations}}
  - [x] use button_to instead of a bunch of forms
  - [x] must be log owner to
    - [x] add/remove caves
    - [x] add/remove locations
    - [x] edit details
    - [x] delete log
    - [x] see edit buttons
- [x] add long and lat options to cave
- [x] add mock data to dev
- [x] Pagination
  - [x] Simple cave pagination
  - [x] Pagination in turbo
- [x] add cave address data at save time
- [ ] pagination for caves/partners
- [x] dark mode
- [ ] search for partners on log
- [x] cave: no description/location if not present
- [x] cave: no details if no lon && lat && desc
- [ ] general ui cleanup
  - [ ] remove actions section (danger zone for delete edit in detils section)
  - [ ] consistent styling for all edit/new forms
  - [ ] better buttons on cave locations section
  - [ ] partnership badges need darkmode
  - [ ] Cancel links on edit forms
- [ ] consistent log views on all locations/caves
- [ ] checkmarks on logs/caves once visited
- [ ] add info on the caves table
- [ ] add location button when editing cave location copies on a log
- [ ] shared logs on my partnership section
- [ ] better footer
- [ ] tests!!!

## Feature ideas

- [ ] deployments!
- [x] User page (name, username)
  - [x] Edit user page
  - [x] Permissions
  - [x] Connect partners to users
    - [x] Add partners to a log (high)
- [ ] edit history on caves/subsystem/location and permission based on refferal (from UKC?)
  - [ ] checkbox/text about the importance of accuracy on cave/subsystem/edit forms and warning about tracability of edits/additions
- [ ] add cave id to log locations copy
- [ ] add button to add a new location to cave on table footer of edit locations on log table
- [ ] Add cave connections
  - [ ] Adding cave to log suggests relevant cave connections
- [ ] searchable/paginating locations
- [ ] location comments
- [ ] Locations metadata - star rating, physical difficulty rating, mental grimness rating (1)
  - [ ] tier ranking/access difficulty grade
  - [ ] Cave metadata - entrance location - region - distribution of grades
- [ ] Report cave/locations
- [ ] Number log entries accoring to how many the user has logged?

## Notes

Location metadata/ratings: if you make logging the lcoation a req to vote on it, 1 vote per log, it can't be absued because if you add and remove the location you can will reference location_id and log_id to check if a vote has already been used

<details>
<summary><b>Appendix: original README hidden for brevity</b></summary>
- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions
</details>
