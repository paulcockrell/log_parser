# Log file parser

Parses web log files, that have a known format of <uri path> <ip address>.
Renders the output to the screen as table, showing total visits by URI path,
and unique visits by URI path.

## Prerequisits
1. Ruby 2.1 or later
2. Gem and Bundler must be installed

## Install
To install:

```
$> git clone git@github.com:paulcockrell/log_parser.git
$> bundle install
```

## Test
To run test suite:

```
$> rspec ./spec --format documentation
```

## Run
To run program (sample web log file included in repo)


```
$> ruby parser.rb ./webserver.log
```
