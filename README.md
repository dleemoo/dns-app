# README

This code implements a test API to register DNS entries associating IPs with
their hostnames.

## Notes

The `page` parameter isn't present at this implementation since I can't figure
how the pagination must work from API definition and it's too late to check how
this is supposed to works.

## Setup

This application includes a `Dockerfile` that generates an image suitable for
the `development` environment. This image is present at `docker hub`, so no
need to run the `build` script at `config/docker` directory.

The `docker-compose.yml` contains everything required to run the application
and the `.example.env` includes a setup that works out of the box to run this
locally. By default, the port used to expose the app is `3456`.

The steps to run this app for the first time:

```
# first-time steps
cp .example.env .env
docker-compose run --rm dns-app bundle exec rake db:create db:migrate

# runs the app and database and at first time pull images from hub
docker-compose up
```

## Populate database

To populate the database with minimal records for a test we can execute the
seed with the following command:

```
docker-compose run --rm dns-app bundle exec rake db:seed
```

The seed reproduces exaclty the same scenrio presented at API definition. Using
the API, the following commands can be used:


```
curl http://localhost:3456/dns_records -X POST -H 'Content-Type: application/json; charset=utf-8' \
--data '{ "dns_records": { "ip": "1.1.1.1", "hostname_attributes": [ "lorem.com", "ipsum.com", "dolor.com", "amet.com" ] } }'

curl http://localhost:3456/dns_records -X POST -H 'Content-Type: application/json; charset=utf-8' \
--data '{ "dns_records": { "ip": "2.2.2.2", "hostname_attributes": [ "ipsum.com" ] } }'

curl http://localhost:3456/dns_records -X POST -H 'Content-Type: application/json; charset=utf-8' \
--data '{ "dns_records": { "ip": "3.3.3.3", "hostname_attributes": [ "ipsum.com", "dolor.com", "amet.com" ] } }'

curl http://localhost:3456/dns_records -X POST -H 'Content-Type: application/json; charset=utf-8' \
--data '{ "dns_records": { "ip": "4.4.4.4", "hostname_attributes": [ "ipsum.com", "dolor.com", "sit.com", "amet.com" ] } }'

curl http://localhost:3456/dns_records -X POST -H 'Content-Type: application/json; charset=utf-8' \
--data '{ "dns_records": { "ip": "5.5.5.5", "hostname_attributes": [ "dolor.com", "sit.com" ] } }'
```

## Test

To run specs for this application execute the following command:

```
docker-compose run --rm dns-app bundle exec rake
```
