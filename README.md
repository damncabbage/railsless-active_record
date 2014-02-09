# Railsless-ActiveRecord

Provides a ActiveRecord Rake tasks and integration for Sinatra, Grape and other not-Rails frameworks.

## Installation

Add `gem 'railsless-active_record'` to your Gemfile (along with `gem 'sqlite3'`, or whatever other database you're using). Run `bundle install` to pull it down and set it up.

### Rake

In your Rakefile, add the following line:

```ruby
require 'railsless/active_record/load_tasks'
require './app' # or whatever the path to your app or server is.
```

You'll then need to integrate this gem with your app; here's how to do it with some common non-Rails frameworks:

#### Sinatra

In your application, add a `register Railsless::ActiveRecord::SinatraExtension` line to use the extension to manage your database configuration and connections, eg.

```ruby
require 'sinatra/base'
require 'railsless/active_record/sinatra_extension'
class MyApp < Sinatra::Base
  register Railsless::ActiveRecord::SinatraExtension

  # ... And the rest of your app goes here.
end
```

... Or with the "Classic" style:

```ruby
require 'sinatra'
require 'railsless/active_record/sinatra_extension'

# get '/foo', ... etc.
```

#### Grape

TODO. :sweat_smile:

#### Generic

```ruby
require 'railsless/active_record'
config = Railsless::ActiveRecord::Config.new

# On app startup:
Railsless::ActiveRecord.connect!(config)

# On app shutdown:
Railsless::ActiveRecord.disconnect!
```


## Configuration

Run `rake db:generate:config` to generate a `config/database.yml` to fill in.

If you don't, it will fall back to parsing `ENV['DATABASE_URL']`. If that isn't provided, this gem will explode.


## Usage

Have a look at the Rake tasks now available to you:

```
$ rake -T
rake db:create             # Create the database from config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)
rake db:drop               # Drops the database for the current Rails.env (use db:drop:all to drop all databases)
rake db:fixtures:load      # Load fixtures into the current environment's database.
rake db:migrate            # Migrate the database (options: VERSION=x, VERBOSE=false).
rake db:migrate:status     # Display status of migrations
rake db:rollback           # Rolls the schema back to the previous version (specify steps w/ STEP=n).
rake db:schema:dump        # Create a db/schema.rb file that can be portably used against any DB supported by AR
rake db:schema:load        # Load a schema.rb file into the database
rake db:seed               # Load the seed data from db/seeds.rb
rake db:setup              # Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)
rake db:structure:dump     # Dump the database structure to an SQL file
rake db:version            # Retrieves the current schema version number
rake db:create_migration   # Create a new database migration
```

Create a new DB migration with:

```
$ rake db:create_migration NAME=create_posts
```

This will create a migration file in your migrations directory (`db/migrate`), eg.

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :name
      t.timestamps
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes

Apologies for the horrendous name. ActiveRecord has the gem name `activerecord`, but you need to `require 'active_record'` when using it. I decided to be up-front with you as to how to require the damn thing.

Why not [sinatra-activerecord](https://github.com/janko-m/sinatra-activerecord)? It takes the (understandable) approach of *emulating* the ActiveRecord Rake tasks, instead of using them directly; this unfortunately which leaves large gaps in the set of tasks Rails users are used to. These ActiveRecord tasks have only really been able to be used directly since v4.0, though, so putting these changes back into Blake's/Janko's library would be very backwards-incompatible.

## License

Copyright 2013, Rob Howard

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
