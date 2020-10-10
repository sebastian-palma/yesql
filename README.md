# Yesql

Ruby library for using SQL in Ruby on Rails projects.

YeSQL is a Ruby wrapper built on top of ActiveRecord to allow applications to execute "raw" SQL files from any directory within the application.

Heavily inspired by [krisajenkins/yesql](https://github.com/krisajenkins/yesql) Clojure library. You can see the [rationale](https://github.com/krisajenkins/yesql#rationale) of the library, which is the same for this one.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yesql'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yesql

## Usage

Write a SQL query in a file under the `app/yesql` directory named `users.sql`:

```sql
-- app/yesql/users.sql
SELECT *
FROM users;
```

Now open the Rails console, include the module and execute your query using `YeSQL`:

```ruby
include YeSQL

YeSQL('users')
# users (0.9ms)  SELECT * FROM users;
# => [[1, nil, nil, 2020-09-27 21:27:02.997839 UTC, 2020-09-27 21:27:02.997839 UTC]
```

By default the output is an array of arrays, containing the value for every row.


## Options


#### `bindings`


If your query has bindings, you can pass them as the second argument when calling `YeSQL`.

```sql
-- app/yesql/top_10_users_in_x_country.sql
SELECT
  :country AS country,
  users.*
FROM users
WHERE country_id = :country_id
LIMIT :limit;
```

When calling `YeSQL`:

```ruby
YeSQL('top_10_users_in_x_country', { country: 'Cuba', country_id: 1, limit: 6 })
```

- If the query doesn't have bindings, but they're provided they're just omitted.
TODO: update this with link to the error.
- If the query has bindings, but nothing is provided, it raises a `NotImplementedError` exception.


#### `output`


If you need an output other than an array of arrays, you can use the `output` options. It accepts three values:

  - `:columns` (or `'columns'`): returns an array containing the name of the columns returned from the query in the format `['column_a', 'column_b', ...]`.
  - `:hash` (or `'hash'`): returns an array of hashes in the format `[{ column: value }, ...]`.
  - `:rows` (or `'rows'`) DEFAULT: returns an array of arrays containing the result values from the query in the format `[[value1, value2, ...], ...]`.

Example:

```ruby
YeSQL('users', output: :columns)
# => ['id', 'name', 'admin', 'created_at', 'updated_at']

YeSQL('users', output: :hash)
# => [{:id=>1, :name=>nil, :admin=>nil, :created_at=>2020-09-27 21:27:02.997839 UTC, :updated_at=>2020-09-27 21:27:02.997839 UTC}]

YeSQL('users', output: :rows)
# => [[1, nil, nil, 2020-09-27 21:27:02.997839 UTC, 2020-09-27 21:27:02.997839 UTC]]

YeSQL('users') # same as in `YeSQL('users', output: :rows)`
# => [[1, nil, nil, 2020-09-27 21:27:02.997839 UTC, 2020-09-27 21:27:02.997839 UTC]]
```

- If an unsupported `output` value is provided it raises a `NotImplementedError` exception.
- If no `output` value is provided, the default is `rows`.


#### `prepare`

Using `prepare: true` it creates a prepared statement with the content of the SQL file:

```ruby
ActiveRecord::Base.connection.execute('SELECT * FROM pg_prepared_statements').to_a
(0.Xms)  SELECT * FROM pg_prepared_statements
# => []

YeSQL('top_10_users_in_x_country', prepare: true)
# ...

ActiveRecord::Base.connection.execute('SELECT * FROM pg_prepared_statements').to_a
(0.Xms)  SELECT * FROM pg_prepared_statements
# => [{"name"=>"a1", "statement"=>"SELECT   $1 AS country,   users.* FROM users WHERE country_id = $2 LIMIT $3;", "prepare_time"=>2020-10-09 20:52:01.664121 +0000, "parameter_types"=>"{text,integer,bigint}", "from_sql"=>false}]
```


#### `cache`

If you need to cache your query, you can use the `cache` option. `cache` must be a Hash containing __at least__ the `expires_in` key with an `ActiveSupport::Duration` object, e.g:

```ruby
YeSQL('users', cache: { key: 'users', expires_in: 1.hour })
```

That's enough to cache the result of the query for 1 hour with the cache key "users".

If no `key` key/value is used, then the cache key is the name of the file containing the SQL code, and

```ruby
YeSQL('users', cache: { key: 'users', expires_in: 1.hour })
```

is the same as

```ruby
YeSQL('users', cache: { expires_in: 1.hour })
```

## Configuration

For default `YeSQL` looks for the _.sql_ files defined under the `app/yesql/` folder but you can update it to use any folder you need. For that you can create a Ruby file under the `config/initializers/` folder as:

```ruby
YeSQL.config.path = 'path'
```

After saving the file and restarting the server the files are going to be read from the given folder.

You can check at anytime what's the configuration path by inspecting the YeSQL `config` object:

```ruby
YeSQL.config
# <Dry::Configurable::Config values={:path=>"path"}>
Yesql.config.path
# "path"
```


## Development

- Clone the repository.
- Install the gem dependencies.
- Make sure to create the database used in the dummy Rails application in the spec/ folder.
- Run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sebastian-palma/yesql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sebastian-palma/yesql/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Yesql project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sebastian-palma/yesql/blob/master/CODE_OF_CONDUCT.md).
