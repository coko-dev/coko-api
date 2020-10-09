# About:
Web API of the application "Coko". This API is for SSKDs and is not intended to be open to the public.

# Build & Test status:
- Go check build or test status with CircleCI
https://app.circleci.com/pipelines/github/coko-dev

# Set up

### Clone Repository
```terminal
$ git clone git@github.com:coko-dev/coko-api.git
```

### Prerequisites
- Install Docker (Need to sign up)
  - https://store.docker.com/editions/community/docker-ce-desktop-mac  (Mac)
  - https://docs.docker.com/docker-for-windows/install/  (Winodows)

- rbenv
```terminal
$ brew install rbenv
$ rbenv install $(cat heim-front/.ruby-version)
$ rbenv init
```

- yarn
```terminal
$ brew install yarn
```

### Build Docker Containers in your local environment
```terminal
$ docker-compose build
...
Successfully built xxxxxxxxxxx
```

### Run containers
- api
  - Rails Web API server.
- db
  - Database server (MySQL2)

```terminal
### Start all container
$ docker-compose up
...
api_1  | * Version 4.3.6 (ruby 2.6.6-p146), codename: Mysterious Traveller
api_1  | * Min threads: 5, max threads: 5
api_1  | * Environment: development
api_1  | * Listening on tcp://0.0.0.0:3000
api_1  | Use Ctrl-C to stop
```
Go to http://localhost:3000 !
