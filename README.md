# apply_env

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Build Apline Linux static bin

  * start container

```bash
$ docker run --rm -it --entrypoint /bin/sh -v $(pwd):/user/local/src/apply_env crystallang/crystal:latest-alpine
```
  * inside contaier run

```bash
$ cd /user/local/src/apply_env
$ shards build --production --static
$ strip bin/apply_env
```

## Contributing

1. Fork it (<https://github.com/your-github-user/apply_env/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Martin Mareš](https://github.com/your-github-user) - creator and maintainer
