# Csb

A simple and streaming support CSV template engine for Ruby on Rails.

## Usage

### Template handler

In app/controllers/reports_controller.rb:

```ruby
def index
  @reports = Report.preload(:categories)
end
```

In app/views/reports/index.csv.csb:

```ruby
csv.items = @reports
# When there are many records
# csv.items = @reports.find_each

# csv.filename = "reports_#{Time.current.to_i}.csv"
# csv.streaming = false

csv.cols.add('Update date') { |r| l(r.updated_at.to_date) }
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content)
csv.cols.add('Empty')
csv.cols.add('Static', 'dummy')
```

Output:

```csv
Update date,Categories,Content,Empty,Static
2019/06/01,category1 category2,content1,,dummy
2019/06/02,category3,content2,,dummy
```

### Directly

```ruby
csv = Csb::Builder.new(items: items)
csv.cols.add('Update date') { |r| l(r.updated_at.to_date) }
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content)
csv.cols.add('Empty')
csv.cols.add('Static', 'dummy')
csv.build

# =>
# Update date,Categories,Content,Empty,Static
# 2019/06/01,category1 category2,content1,,dummy
# 2019/06/02,category3,content2,,dummy
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csb'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install csb
```

## Configuration

In `config/initializers/csb.rb`, you can configure the following values.

```ruby
Csb.configure do |config|
  config.utf8_bom = true # default: false
  config.streaming = false # default: true
  config.after_streaming_error = ->(error) do # default: nil
    Rails.logger.error(error)
    Bugsnag.notify(error)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/csb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Csb project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aki77/csb/blob/master/CODE_OF_CONDUCT.md).
