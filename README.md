
# Feature Channel Sample

This repository is a simple experiment that create 3 interdependent feature services and provide a way to sync
references.

## Setup

### Install deps

_Run the follow code at root directory._

```shellscript
foreach service in './platform' './emails' './assets'; do (cd $service && bundle install && cd ..); done
```

### Running

* First check if do you have `foreman` installed.

    `$ which foreman`

* If not, please install `foreman` using the follow command.

    `$ gem install foreman`

* Then, run foreman to start all services

    `$ foreman start`

## Author

Daniel Vinciguerra

## License

This `feature-channel-sample` repo code is released under the `MIT License`

