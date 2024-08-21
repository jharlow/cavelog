# README

## Getting started

Ensure that you are using the correct Ruby version

```sh
$ asdf current ruby
> 3.3.3
```

Ensure that all the correct dependencies have been installed

```sh
$ bundle install
> Bundle complete!
```

Run the dev environment

```sh
$ ./bin/dev
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
  - [ ] pagination for caves/partners
- [ ] search for partners on log

## Feature ideas

- [ ] deployments!
- [x] User page (name, username) (ON DECK)
  - [x] Edit user page
  - [x] Permissions
  - [x] Connect partners to users
    - [x] Add partners to a log (high)
- [ ] edit history on caves/subsystem/location and permission based on refferal (from UKC?)
- [ ] checkbox/text about the importance of accuracy on cave/subsystem/edit forms and warning about tracability of edits/additions
- [ ] Pagination - HIGH
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
