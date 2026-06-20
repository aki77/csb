---
name: csb
description: "Generate streaming, Excel-friendly CSV downloads in Rails with the csb gem. Use when implementing a CSV export/download, writing a `.csv.csb` template, building CSV via Csb::Builder, or testing column definitions. Not for parsing CSV."
---

# csb

A simple, streaming CSV template engine for Ruby on Rails (the name is short for **CSV builder**). Use it to generate Excel-friendly, memory-safe CSV downloads with column definitions that are easy to read and unit-test.

## When to use csb

Reach for csb when building a CSV **download/export** in Rails. It replaces the naive hand-written `CSV.generate` in a view, which has recurring problems csb solves:

| Problem with hand-written CSV | csb solution |
| --- | --- |
| Garbled in Excel (UTF-8 without BOM) | Optional UTF-8 BOM output |
| Memory / timeout on large datasets | Row-by-row streaming download |
| Headers and values defined far apart | Each column's header + value on one line |
| Export logic buried in a view, hard to test | Extract column defs to a model and unit-test |

Out of scope: **parsing** CSV (use the `csv` stdlib directly).

## Approach 1: Template handler (the common case)

Controller — just assign the records (an `ActiveRecord::Relation` is fine, no `.to_a` needed):

```ruby
# app/controllers/reports_controller.rb
def index
  @reports = Report.preload(:categories)
end
```

View — `app/views/reports/index.csv.csb` (note the `.csv.csb` extension):

```ruby
csv.items = @reports

# Each column: header + value defined together.
csv.cols.add('Update date') { |r| l(r.updated_at.to_date) } # block receives the record
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content) # Symbol -> calls the method on the record
csv.cols.add('Static', 'dummy')   # String  -> output verbatim
csv.cols.add('Empty')             # no value -> empty column
csv.cols.add('Dup', :col1)        # the same header may be added more than once;
csv.cols.add('Dup', :col2)        # columns are output in definition order
```

A link like `link_to 'Download CSV', reports_path(format: :csv)` triggers the streaming download automatically.

### Large datasets

Pass an Enumerator so streaming starts immediately instead of loading every record first:

```ruby
csv.items = @reports.find_each
# With a decorator (e.g. Draper), kept lazy:
csv.items = @reports.find_each.lazy.map(&:decorate)
```

### Per-view overrides

```ruby
csv.filename = "reports_#{Time.current.to_i}.csv"
csv.streaming = false
csv.csv_options = { col_sep: "\t" }
```

## Approach 2: Direct generation (outside a request)

For background jobs or anywhere outside a controller, use `Csb::Builder`:

```ruby
csv = Csb::Builder.new(items: items)
csv.cols.add('Update date') { |r| l(r.updated_at.to_date) }
csv.cols.add('Categories') { |r| r.categories.pluck(:name).join(' ') }
csv.cols.add('Content', :content)
csv.build # => returns the CSV string

# File.write('reports.csv', csv.build)
```

## Testing column definitions

Extract the column definitions into a model method so they can be unit-tested apart from the view:

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

# One record, header/value pairs:
expect(Article.csb_cols.col_pairs(article)).to eq [
  ['Update date', '2020-01-01'],
  ['Categories', 'test rspec'],
  ['Title', 'Testing'],
]

# Whole table (header row + value rows):
expect(Article.csb_cols.as_table(articles)).to eq [
  ['Update date', 'Categories', 'Title'],
  ['2020-01-01', 'test rspec', 'Testing'],
  ['2020-02-01', 'rails gem', 'Rails 6.2'],
]
```

## Configuration

`config/initializers/csb.rb`:

```ruby
Csb.configure do |config|
  config.utf8_bom = true              # default: false. Set true so Excel opens without mojibake.
  config.streaming = false            # default: true
  config.csv_options = { col_sep: "\t" } # default: {}

  # Called when an error is raised during streaming. WITHOUT this, mid-stream
  # errors are silently swallowed and won't reach tools like Bugsnag.
  config.after_streaming_error = ->(error) do # default: nil
    Rails.logger.error(error)
    Bugsnag.notify(error)
  end

  # Error classes to ignore (not re-raise) during streaming, e.g. when the
  # client disconnects before the download finishes.
  config.ignore_class_names = %w[Puma::ConnectionError] # default: %w[Puma::ConnectionError]
end
```

## Pitfalls

- The view must use the `.csv.csb` extension.
- Trigger the download with `format: :csv` (e.g. `link_to 'Download', reports_path(format: :csv)`).
- The `cols.add` value rules: block → receives the record; `Symbol` → calls that method; `String` → literal; omitted → empty cell.
- Streaming errors are swallowed unless you set `config.after_streaming_error` — set it if you rely on error reporting.
- For big tables, pass `find_each` (an Enumerator), not a fully-loaded array, to keep streaming memory-safe.
