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

## Feature ideas

- [ ] User page (name, username, logs)
  - [ ] logbooks
  - [ ] Edit user page
  - [ ] Connect partners to users
    - [ ] Add partners to a log (high)
- [ ] Add cave connections
  - [ ] Adding cave to log suggests relevant cave connections
- [ ] searchable/paginating locations
- [ ] location comments
- [ ] Locations metadata - star rating, physical difficulty rating, mental grimness rating (1)
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
