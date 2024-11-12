# README

## Getting started

### Local development with hot refresh

Ensure that you are using the correct Ruby version:

```sh
$ asdf current ruby
> 3.3.3
```

Install the correct dependencies and link your yard docs:

```sh
$ sudo bundle install
> Bundle complete!
$ yard gems
>
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

Run the dev environment:

```sh
$ ./bin/dev
```

Lint the project:

```sh
$ ./bin/brakeman
```

### Local development via Docker

Make sure you have your `.env` file set up according to the `.dev.env.example`

Set up container

```sh
$ docker compose up --build -d
```

Optionally, you can also see the database with caves

```sh
$ docker compose exec app bundle exec rake data:load_cave_csv
> Data loaded successfully!
```

To end the process, run:

```sh
$ docker compose down
```

## Deployment via AWS

Ensure that you have the `aws` and `npm` cli tools installed

With the `aws` cli configured (`aws configure`), navigate to the CDK directory and install the packages

```sh
$ cd cdk && npm install
```

**Important:** Now set up your `.env` file according to the `.env.example`.

Run the full deployment script:

```sh
$ npm run cdk -- deploy --all
```

Optionally, you can also see the database with caves

```sh
$ aws ecs list-tasks \
    --cluster {{RAILS_APP_CULUSTER_ARN}} \
    --service {{RAILS_APP_SERVICE_ARN}} \
    --desired-status RUNNING \
    --query "taskArns[0]" \
    --output text
> {{RAILS_APP_TASK_ARN}}

$ aws ecs execute-command \
  --region {{AWS_REGION}} \
  --cluster {{RAILS_APP_CULUSTER_ARN}} \
  --task {{RAILS_APP_TASK_ARN}} \
  --container RailsAppContainer \
  --interactive \
  --command "bundle exec rake data:load_cave_csv"
> Data loaded successfully!
```

Where:

- `{{RAILS_APP_CULUSTER_ARN}}` -- the ECS cluster ID of your deployed rails app
- `{{RAILS_APP_TASK_ARN}}` -- the ECS task ID contained inside the above ECC cluster
- `{{AWS_REGION}}` -- the value of `CDK_REGION` env used when you ran the deploy script

To shut down the stack:

```sh
$ npm run cdk -- destroy --all
```

## 0.1 Release Beta Criteria

<details>
<summary><b>Click to expand the TODO list</b></summary>
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
- [x] dark mode
- [x] cave: no description/location if not present
- [x] cave: no details if no lon && lat && desc
- [x] general ui cleanup
  - [x] dark mode: calendar on datetime picker should be white
  - [x] remove actions section (danger zone for delete edit in details section)
  - [x] consistent styling for all edit/new forms
  - [x] better buttons on cave locations section
  - [x] partnership badges need darkmode
  - [x] Cancel links on edit forms
  - [x] empty section when no caves to display on index view
- [x] log viewing
  - [x] logs#index styling
  - [x] consistent log views on all locations/caves
  - [x] checkmarks on locations/caves once visited
  - [x] shared logs on my partnership section
- [x] No info yet on tables
- [x] Add/edit buttons go to sign in page if no current user
- [ ] nicer sign in page
- [x] if not signed in, welcome and explanation of what cavelog is
- [ ] forgot password flow
- [ ] If no description/metadata, show link to add it
- [x] check marks on caves if not signed in
- [x] better footer
- [x] better home page
- [ ] CI/CD pr deployments/teardowns
- [ ] CI/CD production deployments
- [x] DNS routing to domain
- [x] SSL in production
- [ ] Tests!
</details>

## Feature ideas

<details>
<summary><b>Click to expand the TODO list</b></summary>
- [ ] add location button when editing cave location copies on a log
- [ ] Reputation score (gaining and as a thrshold for is can edit/delete)
- [ ] Stats section on user page (caves visited, hours in caves)
- [ ] Log type (leader, participant)
- [ ] Add filters to logs#index
- [ ] export logs to excel file
- [x] User page (name, username)
  - [x] Edit user page
  - [x] Permissions
  - [x] Connect partners to users
    - [x] Add partners to a log (high)
- [x] deletion/edit permissions (basic)
- [x] edit history on caves/subsystem/location
  - [x] text about the importance of accuracy on cave/subsystem/edit forms and warning about tracability of edits/additions
- [ ] search for partners on log
- [ ] pagination for caves/partners
- [ ] add cave id to log locations copy
- [ ] Add cave connections
  - [ ] Adding cave to log suggests relevant cave connections
- [ ] searchable/paginating locations
- [ ] location comments
- [ ] Locations metadata - star rating, physical difficulty rating, mental grimness rating (1)
  - [ ] tier ranking/access difficulty grade
- [ ] Report cave/locations
- [x] Improve homepage
- [x] Logs you tagged X in
</details>

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
