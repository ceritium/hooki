# Hooki

Add before and after callbacks to methods.

## Sponsor

This project is sponsored by [babelfu.com](https://babelfu.com)
[![Babelfu is a Github based translation service](https://babelfu.com/banner.png)](https://babelfu.com)

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add hooki

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install hooki

## Usage

You can use Hooki in several ways to add before and after callbacks to methods.

Hooki provides callbacks for instance and singleton methods:

instance: `before_method`, `after_method`
singleton: `before_singleton_method`, `after_singleton_method`

All the callbacks accept optional parameters `only` and `except` for filtering
in which methods trigger the callbacks. `only` and `except` accepts a single symbol or array.

This is a basic example:

```ruby
class Foo
  include Hooki

  before_method :log_before, only: :bar # or [:bar]
  after_method :log_after, expect: :bar # or [:bar]

  before_singleton_method :log_singleton_before, only: [:bar] # or :bar
  after_singleton_method :log_singleton_after, expect: [:bar] # or :bar

  def self.bar
    puts "singleton bar"
  end

  def self.baz
    puts "singleton baz"
  end

  def self.log_singleton_before(method_name)
    puts "-- log singleton before #{method_name}"
  end

  def self.log_singleton_after(method_name)
    puts "-- log singleton after #{method_name}"
  end

  def bar
    puts "bar"
  end

  def baz
    puts "baz"
  end

  private

  def log_before(method_name)
    puts "-- log before #{method_name}"
  end

  def log_after(method_name)
    puts "-- log after #{method_name}"
  end
end
```

The previous example doesn't seem too useful, Hooki unchains its potential when
used on class inheritance or modules, for example:

```ruby
module Logger
  include Hooki

  before_method :log

  private

  def log(method_name)
    puts "running #{method_name}"
  end
end

class Foo
  include Logger

  def bar
    puts "bar"
  end

  def baz
    puts "baz"
  end
end
```

There are more examples on [`test/examples.rb`](test/examples.rb)

## Performance

Good, but how slow is it? Well, this is a lot of metaprograming, so it will be
slower than the traditional approach.

There are two benchmarks in [`benchmarks/`](benchmarks/) folder.

The results on my machine are the following:

```
$ bundle exec ruby benchmarks/no_job.rb
Warming up --------------------------------------
                with    58.373k i/100ms
             without   377.367k i/100ms
Calculating -------------------------------------
                with    387.588k (±20.7%) i/s -      1.868M in   5.058400s
             without      3.624M (±19.7%) i/s -     17.359M in   5.025660s

Comparison:
             without:  3623753.6 i/s
                with:   387587.8 i/s - 9.35x  slower


$ bundle exec ruby benchmarks/with_job.rb
Warming up --------------------------------------
                with    11.220k i/100ms
             without    14.801k i/100ms
Calculating -------------------------------------
                with    112.751k (± 8.7%) i/s -    561.000k in   5.025158s
             without    143.033k (±11.0%) i/s -    710.448k in   5.052800s

Comparison:
             without:   143033.0 i/s
                with:   112751.4 i/s - 1.27x  slower
```

The "no job" benchmark is ~9 times slower, but it is doing nothing, it doesn't seem
a realistic scenario. The "with job" benchmark is only a bit slower.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ceritium/hooki. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ceritium/hooki/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hooki project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ceritium/hooki/blob/master/CODE_OF_CONDUCT.md).
