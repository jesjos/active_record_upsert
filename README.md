[![Gem Version](https://badge.fury.io/rb/active_record_upsert.svg)](https://badge.fury.io/rb/active_record_upsert)
[![CI](https://github.com/jesjos/active_record_upsert/actions/workflows/ci.yml/badge.svg)](https://github.com/jesjos/active_record_upsert/actions/workflows/ci.yml)
# ActiveRecordUpsert

Real upsert for PostgreSQL 9.5+ and Rails 5.2+ / ActiveRecord 5.2+. Uses [ON CONFLICT DO UPDATE](http://www.postgresql.org/docs/9.5/static/sql-insert.html).

## Main points

- Does upsert on a single record using `ON CONFLICT DO UPDATE`
- Updates timestamps as you would expect in ActiveRecord
- For partial upserts, loads any existing data from the database

## Prerequisites

- PostgreSQL 9.5+ (that's when UPSERT support was added; see Wikipedia's [PostgreSQL Release History](https://en.wikipedia.org/wiki/PostgreSQL#Release_history))
- ActiveRecord >= 5.2
- Ruby MRI, with the `pg` gem
- _JRuby is currently not supported_

## Alternatives

This library was written at a time in history when Rails did not support any `#upsert` method.

Instead of using this library, if you are using a current version of Rails, you may want to [use its `#upsert`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert). You may want to investigate how [newer PostgreSQL versions support `MERGE` statement](https://www.postgresql.org/docs/current/sql-merge.html).

### NB: Releases to avoid

Due to a broken build matrix, v0.9.2 and v0.9.3 are incompatible with Rails
< 5.2.1. [v0.9.4](https://github.com/jesjos/active_record_upsert/releases/tag/v0.9.4) fixed this issue.

### Supported Rails versions

This library is compatible with all major Rails versions covered by the Rails ["Severe Security Issues" maintenance policy](https://guides.rubyonrails.org/maintenance_policy.html).

### Supported Ruby versions

This library may be compatible with older versions of Ruby, however we only run automated tests using the [officially supported Ruby versions](https://www.ruby-lang.org/en/downloads/branches/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_upsert'
```

And then execute:

```console
bundle
```

Or install it yourself as:

```console
gem install active_record_upsert
```

## Usage

### Create

Use `ActiveRecord.upsert` or `ActiveRecord#upsert`. _ActiveRecordUpsert_ respects timestamps.

```ruby
class MyRecord < ActiveRecord::Base
end

MyRecord.create(name: 'foo', wisdom: 1)
# => #<MyRecord id: 1, name: "foo", created_at: "2016-02-20 14:15:55", updated_at: "2016-02-20 14:15:55", wisdom: 1>

MyRecord.upsert(id: 1, wisdom: 3)
# => #<MyRecord id: 1, name: "foo", created_at: "2016-02-20 14:15:55", updated_at: "2016-02-20 14:18:15", wisdom: 3>

r = MyRecord.new(id: 1)
r.name = 'bar'
r.upsert
# => #<MyRecord id: 1, name: "bar", created_at: "2016-02-20 14:15:55", updated_at: "2016-02-20 14:18:49", wisdom: 3>
```

### Update

If you need to specify a condition for the update, pass it as an Arel query:

```ruby
MyRecord.upsert({id: 1, wisdom: 3}, arel_condition: MyRecord.arel_table[:updated_at].lt(1.day.ago))
```

The instance method `#upsert` can also take keyword arguments to specify a condition, or to limit which attributes to upsert (by default, all `changed` attributes will be passed to the upsert):

```ruby
r = MyRecord.new(id: 1)
r.name = 'bar'
r.color = 'blue'
r.upsert(attributes: [:name], arel_condition: MyRecord.arel_table[:updated_at].lt(1.day.ago))
# will only update :name, and only if the record is older than 1 day;
# but if the record does not exist, will insert with both :name and :colors
```

### Create with specific Attributes

If you want to create a record with the specific attributes, but update only a limited set of attributes, similar to how `ActiveRecord::Base.create_with` works, you can do the following:

```ruby
existing_record = MyRecord.create(id: 1, name: 'lemon', color: 'green')
r = MyRecord.new(id: 1, name: 'banana', color: 'yellow')
r.upsert(attributes: [:color])
# => #<MyRecord id: 1, name: "lemon", color: "yellow", ...>

r = MyRecord.new(id: 2, name: 'banana', color: 'yellow')
r.upsert(attributes: [:color])

# => #<MyRecord id: 2, name: "banana", color: "yellow", ...>

# This is similar to:

MyRecord.create_with(name: 'banana').find_or_initialize_by(id: 2).update(color: 'yellow')

```

### Validations

Upsert will perform validation on the object, and return false if it is not valid. To skip validation, pass `validate: false`:

```ruby
MyRecord.upsert({id: 1, wisdom: 3}, validate: false)
```

If you want validations to raise `ActiveRecord::RecordInvalid`, use `upsert!`:

```ruby
MyRecord.upsert!(id: 1, wisdom: 3)
```

Or using the instance method:

```ruby
r = MyRecord.new(id: 1, name: 'bar')
r.upsert!
```

### Gotcha with database defaults

When a table is defined with a database default for a field, this gotcha can occur when trying to explicitly upsert a record _to_ the default value (from a non-default value).

**Example**: a table called `hardwares` has a `prio` column with a default value.

```text
┌─────────┬─────────┬─────────┬
│ Column  │ Type    │ Default │
├─────────┼─────────┼─────────┼
│ id      │ integer │ ...     |
│ prio    │ integer │ 999     |
```

And `hardwares` has a record with a non-default value for `prio`. Say, the record with `id` 1 has a `prio` of `998`.

In this situation, upserting like:

```ruby
hw = { id: 1, prio: 999 }
Hardware.new(prio: hw[:prio]).upsert
```

will not mention the `prio` column in the `ON CONFLICT` clause, resulting in no update.

However, upserting like so:

```ruby
Hardware.upsert(prio: hw[:prio]).id
```

will indeed update the record in the database back to its default value, `999`.

### Conflict Clauses

It's possible to specify which columns should be used for the conflict clause. **These must comprise a unique index in Postgres.**

```ruby
class Vehicle < ActiveRecord::Base
  upsert_keys [:make, :name]
end

Vehicle.upsert(make: 'Ford', name: 'F-150', doors: 4)
# => #<Vehicle id: 1, make: 'Ford', name: 'Focus', doors: 2>

Vehicle.create(make: 'Ford', name: 'Focus', doors: 4)
# => #<Vehicle id: 2, make: 'Ford', name: 'Focus', doors: 4>

r = Vehicle.new(make: 'Ford', name: 'F-150')
r.doors = 2
r.upsert
# => #<Vehicle id: 1, make: 'Ford', name: 'Focus', doors: 2>
```

Partial indexes can be supported with the addition of a `where` clause.

```ruby
class Account < ApplicationRecord
  upsert_keys :name, where: 'active is TRUE'
end
```

Custom index can be handled with a Hash containing a literal key :

```ruby
class Account < ApplicationRecord
  upsert_keys literal: 'md5(my_long_field)'
end
```

Overriding the models' `upsert_keys` when calling `#upsert` or `.upsert`:

```ruby
  Account.upsert(attrs, opts: { upsert_keys: [:foo, :bar] })
  # Or, on an instance:
  account = Account.new(attrs)
  account.upsert(opts: { upsert_keys: [:foo, :bar] })
```

Overriding the models' `upsert_options` (partial index) when calling `#upsert` or `.upsert`:

```ruby
  Account.upsert(attrs, opts: { upsert_options: { where: 'foo IS NOT NULL' } })
  # Or, on an instance:
  account = Account.new(attrs)
  account.upsert(opts: { upsert_options: { where: 'foo IS NOT NULL' } })
```

## Comparing to native Rails 6 Upsert

Rails 6 (via the ["Add insert_many to ActiveRecord models" PR #35077](https://github.com/rails/rails/pull/35077)) added the ability to create or update individual records through `#insert` and `#upsert` and similarly the ability to create or update multiple records through `#insert_all` and `#upsert_all`.

Here is a quick comparison of how the Rails native `ActiveRecord::Persistence#upsert` feature compares to what's offered in this gem:

| Feature                                                 | `active_record_upsert`          | Rails native `ActiveRecord::Persistence#upsert`          |
| ------------------------------------------------------- | ------------------------------- | -------------------------------------------------------- |
| Set model level conflict clause                         | Yes, through `#upsert_keys`     | No, but can be passed in through the `:unique_by` option |
| Ability to invoke validations and callbacks             | Yes                             | No                                                       |
| Automatically sets `created_at`/`updated_at` timestamps | Yes                             | Yes (Rails 7.0+)                                         |
| Checks for unique index on the database                 | No[^1]                          | Yes                                                      |
| Use associations in upsert calls                        | Yes                             | No                                                       |
| Return object type                                      | Instantiated ActiveRecord model | `ActiveRecord::Result`                                   |

[^1]: Though the gem does not check for the index first, the upsert will still fail due to the database constraint.

## Tests

Make sure to have an upsert_test database:

```shell
bin/run_rails.sh db:create db:migrate DATABASE_URL=postgresql://localhost/upsert_test
```

Then run `rspec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/jesjos/active_record_upsert>.

## Contributors

- Jesper Josefsson
- Aurora Nockert
- Olle Jonsson
- Simon Dahlbacka
- Paul Hoffer
- Ivan ([@me](https://github.com/me))
- Leon Miller-Out ([@sbleon](https://github.com/sbleon))
- Andrii Dmytrenko ([@Antti](https://github.com/Antti))
- Alexia McDonald ([@alexiamcdonald](https://github.com/alexiamcdonald))
- Timo Schilling ([@timoschilling](https://github.com/timoschilling))
- Benedikt Deicke ([@benedikt](https://github.com/benedikt))
- Daniel Cooper ([@danielcooper](https://github.com/danielcooper))
- Laurent Vallar ([@val](https://github.com/val))
- Emmanuel Quentin ([@manuquentin](https://github.com/manuquentin))
- Jeff Wallace ([@tjwallace](https://github.com/tjwallace))
- Kirill Zaitsev ([@Bugagazavr](https://github.com/Bugagazavr))
- Nick Campbell ([@nickcampbell18](https://github.com/nickcampbell18))
- Mikhail Doronin ([@misdoro](https://github.com/misdoro))
- Jan Graichen ([@jgraichen](https://github.com/jgraichen))
