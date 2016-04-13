[![Build Status](https://travis-ci.org/jesjos/active_record_upsert.svg?branch=master)](https://travis-ci.org/jesjos/active_record_upsert)
[![Code Climate](https://codeclimate.com/github/jesjos/active_record_upsert/badges/gpa.svg)](https://codeclimate.com/github/jesjos/active_record_upsert)

# ActiveRecordUpsert

Real upsert for PostgreSQL 9.5+ and Rails 5 / ActiveRecord 5. Uses [ON CONFLICT DO UPDATE](http://www.postgresql.org/docs/9.5/static/sql-insert.html).

## Main points

- Does upsert on a single record using `ON CONFLICT DO UPDATE`
- Updates timestamps as you would expect in ActiveRecord
- For partial upserts, loads any existing data from the database

## Prerequisites

- PostgreSQL 9.5+
- ActiveRecord ~> 5
- For MRI: pg
- For JRuby: You need to use a fork of `activerecord-jdbcpostgresql-adapter`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_upsert'
```

If you use JRuby, also add the following:

```ruby
gem 'activerecord-jdbc-adapter',
    github: 'jensnockert/activerecord-jdbc-adapter',
    branch: 'activerecord-50',
    platform: :jruby

gem 'activerecord-jdbcpostgresql-adapter',
    github: 'jensnockert/activerecord-jdbc-adapter',
    branch: 'activerecord-50',
    platform: :jruby
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_upsert

## Usage
Just use `ActiveRecord.upsert` or `ActiveRecord#upsert`.
*ActiveRecordUpsert* respects timestamps.
 
```
class MyRecord < ActiveRecord::Base
end

MyRecord.create(name: 'foo', wisdom: 1)
=> #<MyRecord id: 1, name: "foo", created_at: "2016-02-20 14:15:55", updated_at: "2016-02-20 14:15:55", wisdom: 1>

MyRecord.upsert(id: 1, wisdom: 3)
=> #<MyRecord id: 2, name: "foo", created_at: "2016-02-20 14:15:55", updated_at: "2016-02-20 14:18:15", wisdom: 3>

r = MyRecord.new(id: 1)
r.name = 'bar'
r.upsert
=> #<MyRecord id: 2, name: "bar", created_at: "2016-02-20 14:17:50", updated_at: "2016-02-20 14:18:49", wisdom: 3>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jesjos/active_record_upsert.

## Contributors

- Jesper Josefsson
- Jens Nockert
- Olle Jonsson
- Simon Dahlbacka
