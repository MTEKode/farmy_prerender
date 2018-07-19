# FarmyPrerender

Custom middleware for prerender.

## Usage

Options:

* application.rb config:

```ruby
config.middleware.insert_before 0, FarmyPrerender::Selector, {
    render_server: 'render server host',
    host: 'rails server host',
    redis: Redis.current,
    default_render_robot: false
}
```

* initializer.rb config:

``` ruby
Rails.configuration.middleware.insert_before 0, FarmyPrerender::Selector, {
    render_server: 'http://localhost:5000',
    host: 'http://lvh.me:3000',
    redis: Redis.current,
    default_render_robot: false
}
```



## Options explained:

* render_server: host where render server instance is running.
* host: host where main application is running.
* redis: if you want use Redis, you must pass an instance of Redis, like
  Redis.current.
* default_render_robot: this option is used if you want that the middleware
  response will be a rendered response by default. 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'farmy_prerender'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install farmy_prerender


## Prerender Server

To use this gem you need a prerender server running:

* Your prerender instance:
    ```
    git clone https://github.com/mtoribio/prerender
    ```
    ```
    yarn install
    ```
    ```
    node server.js
    ```
* Prerender.io official server(paid), check prerender.io.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/farmy_prerender. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FarmyPrerender project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/farmy_prerender/blob/master/CODE_OF_CONDUCT.md).
