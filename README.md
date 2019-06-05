sort-bot
====

slack bot for sort algorithm

## Setup

- Get slack integration token
- Create `#sort-algorithms` and invite the bot
- Create `config.yml` and write the token (cf. `config.yml.example` )
- Create `size.txt` and write any number (initial size of list)
- Run `$ bundle install --path=vendor/bundle`

## Run

```shell
$ bundle exec ruby main.rb
```
