# Kugiru

A simple and streaming support CSV template engine for Ruby on Rails.

## Usage

In app/controllers/reports_controller.rb:

```ruby
def index
  @reports = Report.preload(:categories)
end
```

In app/views/reports/index.csv.cb:

```ruby
csv.cols = {
  'Update date' => ->(r) { l(r.updated_at.to_date) },
  'Categories' => ->(r) { r.categories.pluck(:name).join(' ') },
  'Content' => ->(r) { r.content },
  'Url' => ->(r) { report_url(r) },
}
csv.data = @reports

# When there are many records
# csv.data = @reports.find_each

# csv.filename = "reports_#{Time.current.to_i}.csv"
# csv.streaming = false
```

Output:

```csv
Update date,Categories,Content,Url
2019/06/01,category1 category2,content1,https://localhost/reports/1
2019/06/02,category3,content2,https://localhost/reports/2
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kugiru'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install kugiru
```

## Configuration

In `config/initializers/kugiru.rb`, you can configure the following values.

```ruby
Kugiru.configure do |config|
  config.utf8_bom = true # default: false
  config.streaming = false # default: true
  config.after_streaming_error = ->(error) do # default: nil
    Rails.logger.error(error)
    Bugsnag.notify(error)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/kugiru. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kugiru project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aki77/kugiru/blob/master/CODE_OF_CONDUCT.md).
