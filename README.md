[![Gem Version](https://badge.fury.io/rb/csb.svg)](https://rubygems.org/gems/csb)
[![Build](https://github.com/aki77/csb/workflows/Build/badge.svg)](https://github.com/aki77/csb/actions)

# Csb

A simple, streaming CSV template engine for Ruby on Rails. (The name is short for **CSV builder**.)

## Why csb?

Writing CSV downloads in Rails by hand looks easy, but the naive approach has recurring problems:

```ruby
# app/views/posts/index.csv.erb (the typical hand-written version)
CSV.generate do |csv|
  csv << %w[Date Category Title Content]
  @posts.each do |post|
    csv << [l(post.created_at.to_date), post.category.name, post.title, post.content]
  end
end
```

- **Garbled in Excel** — UTF-8 without a BOM shows up as mojibake.
- **Memory / timeout errors** — loading and building the whole CSV in memory breaks on large datasets.
- **Hard to maintain** — headers and values are defined far apart, so adding columns hurts readability.
- **Hard to test** — the export logic is buried in a view, leaving you stuck with slow system tests.

csb solves each of these:

- **Excel-friendly** — output UTF-8 with a BOM so Excel opens it without garbling.
- **Streaming download** — stream row by row to handle hundreds of thousands of records without memory or timeout errors.
- **Readable** — define each column's header and value together on one line.
- **Testable** — extract column definitions into a model and unit-test them directly.

## Usage

### Template handler

In `app/controllers/reports_controller.rb`:

```ruby
def index
  @reports = Report.preload(:categories)
end
```

In `app/views/reports/index.csv.csb`:

```ruby
csv.items = @reports

# For large datasets, pass an Enumerator so streaming starts immediately
# instead of waiting for every record to load:
# csv.items = @reports.find_each

# Combine with a decorator (e.g. Draper) while keeping it lazy:
# csv.items = @reports.find_each.lazy.map(&:decorate)

# Optional per-view overrides:
# csv.filename = "reports_#{Time.current.to_i}.csv"
# csv.streaming = false
# csv.csv_options = { col_sep: "\t" }

csv.cols.add('Update date') { |r| l(r.updated_at.to_date) } # block receives the record
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content) # a Symbol calls the method on the record
csv.cols.add('Static', 'dummy')   # a String is output verbatim
csv.cols.add('Empty')             # no value -> empty column
csv.cols.add('Dup', :col1)        # the same header may be added more than once
csv.cols.add('Dup', :col2)        # (columns are output in definition order)
```

Output:

```csv
Update date,Categories,Content,Static,Empty,Dup,Dup
2019/06/01,category1 category2,content1,dummy,,a,b
2019/06/02,category3,content2,dummy,,c,d
```

A link such as `link_to 'Download CSV', reports_path(format: :csv)` triggers the streaming download automatically.

### Directly

When you want to generate the CSV outside of a request (e.g. in a background job), use `Csb::Builder`:

```ruby
csv = Csb::Builder.new(items: items)
csv.cols.add('Update date') { |r| l(r.updated_at.to_date) }
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content)
csv.build # => returns the CSV string

# File.write('reports.csv', csv.build)
```

### Testing

Move the column definitions out of the view so you can unit-test them:

```ruby
# app/views/articles/index.csv.csb
csv.items = @articles
csv.cols = Article.csb_cols

# app/models/article.rb
def self.csb_cols
  Csb::Cols.new do |cols|
    cols.add('Update date') { |r| I18n.l(r.updated_at.to_date) }
    cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
    cols.add('Title', :title)
  end
end
```

```ruby
# spec/models/article_spec.rb
require 'csb/testing' # adds col_pairs and as_table

# Assert a single record, row by row:
expect(Article.csb_cols.col_pairs(article)).to eq [
  ['Update date', '2020-01-01'],
  ['Categories', 'test rspec'],
  ['Title', 'Testing'],
]

# Assert the whole table (header row + value rows):
expect(Article.csb_cols.as_table(articles)).to eq [
  ['Update date', 'Categories', 'Title'],
  ['2020-01-01', 'test rspec', 'Testing'],
  ['2020-02-01', 'rails gem', 'Rails 6.2'],
]
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
  config.csv_options = { col_sep: "\t" } # default: {}

  # Called when an error is raised during streaming. Without this, errors that
  # happen mid-stream are not reported even if you use a tool like Bugsnag.
  config.after_streaming_error = ->(error) do # default: nil
    Rails.logger.error(error)
    Bugsnag.notify(error)
  end

  # Error classes to ignore (not re-raise) during streaming, e.g. when the
  # client disconnects before the download finishes.
  config.ignore_class_names = %w[Puma::ConnectionError] # default: %w[Puma::ConnectionError]
end
```

## Agent skill

This gem ships an [agent skill](skills/csb/) (`SKILL.md`) so AI coding agents (e.g. Claude Code) understand how to use csb. Install it into your project with [apm (Agent Package Manager)](https://github.com/microsoft/apm):

```sh
apm install aki77/csb/skills/csb
```

apm deploys the skill to each agent's directory (e.g. `.claude/skills/`) and locks the version in its lockfile.

Alternatively, if your project already pulls csb in via Bundler, the [bundler-skills](https://github.com/aki77/bundler-skills) plugin auto-syncs this skill on `bundle install` — keeping the skill version locked to the gem version.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/csb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Csb project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aki77/csb/blob/master/CODE_OF_CONDUCT.md).
