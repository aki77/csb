---
description: Maintain the Ruby and Rails version matrix tested in CI for a Ruby gem. Use this when you need to remove EOL versions, add the latest supported versions, and update gemfiles and gemspec accordingly. Always use this for requests like 'remove unsupported Ruby/Rails versions', 'add the latest Rails', or 'update the CI matrix'.
license: MIT
metadata:
    github-path: skills/ruby/ruby-rails-ci-matrix
    github-ref: refs/heads/main
    github-repo: https://github.com/aki77/skills
    github-tree-sha: 59898557bcf3dd4e734ae3f25c8ab025a43341be
name: ruby-rails-ci-matrix
---
# ruby-rails-ci-matrix

Maintain the Ruby and Rails versions tested in CI for a Ruby gem that uses GitHub Actions matrix strategy with `gemfiles/railsXX.gemfile` and a gemspec. This skill keeps the test matrix aligned with the current support status.

Remove EOL (End of Life) versions and add currently supported and latest stable versions. The gemfile, gemspec, and workflow YAML must be updated **in sync** — updating only one will break CI.

## 1. Assess the Current State

Before making any changes, read all three types of files involved.

| File | What to check |
| --- | --- |
| `.github/workflows/*.yml` | `strategy.matrix.include` entries (`{ ruby:, gemfile: }`), `ruby/setup-ruby` version |
| `gemfiles/*.gemfile` | Per-Rails-version gemfiles — `source` URL and `gem 'rails', '~> X.Y.0'` |
| `*.gemspec` | `required_ruby_version` and the lower bound of `add_dependency "rails", ...` |

Note that the `gemfile:` values in the matrix correspond 1:1 with `gemfiles/<value>.gemfile`.

## 2. Research EOL Status

**Use today's date as the reference** and fetch the latest support information — do not rely on memory.

- Ruby: <https://endoflife.date/ruby>
- Rails: <https://endoflife.date/rails>

If endoflife.date is unreachable, use WebSearch as a fallback. Confirm the following three things:

1. EOL date for each version (including security support end date) — has it passed as of today?
2. Full list of currently supported versions
3. Latest stable releases (check whether a new major like Ruby 4.0 or Rails 8.1 has been released)

> Ruby releases a new version every December with ~3 years 3 months of support. Rails 7.2+ receives 1 year of standard support and 2 years of security support.

## 3. Decide What to Add and Remove

- **Remove**: Ruby / Rails versions that are EOL (security support also ended) as of today.
- **Add**: Supported versions not yet in the matrix, plus the latest stable releases.
- **Keep**: Versions still under security support. For versions expiring within a few months, ask the user whether to keep them.
- Build the matrix as **each Rails version × the compatible Ruby versions**. Pay attention to compatibility — older Rails versions may not support the newest Ruby.

## 4. Update Files

Keep all three files consistent. **If you remove a gemfile, remove the matrix entry too** (and vice versa).

### Workflow YAML Matrix

Update the `include:` entries. Use short-form Ruby version strings (`"4.0"`) so `ruby/setup-ruby` automatically picks the latest patch.

```yaml
strategy:
  matrix:
    include:
      - { ruby: "3.3", gemfile: "rails72" }
      - { ruby: "3.4", gemfile: "rails72" }
      - { ruby: "4.0", gemfile: "rails72" }
      - { ruby: "3.3", gemfile: "rails80" }
      - { ruby: "3.4", gemfile: "rails80" }
      - { ruby: "4.0", gemfile: "rails80" }
      - { ruby: "3.3", gemfile: "rails81" }
      - { ruby: "3.4", gemfile: "rails81" }
      - { ruby: "4.0", gemfile: "rails81" }
```

### Create / Delete Gemfiles

For a new Rails version, copy an existing gemfile and change only the `~> X.Y.0` constraint.

```ruby
source "https://rubygems.org"

gem 'rails', '~> 8.1.0'
gem 'sqlite3'

gemspec path: '../'
```

Delete the gemfile for any Rails version being dropped.

### Update gemspec Lower Bounds

Update two lines to match the minimum supported versions.

```ruby
spec.required_ruby_version = '>= 3.3.0'      # minimum supported Ruby
spec.add_dependency "rails", ">= 7.2.0"      # minimum supported Rails
```

## Notes

- **Always use `https://rubygems.org`** as the `source` — fix any `http://` occurrences.
- **`ruby/setup-ruby@v1` and new majors**: For brand-new majors like Ruby 4.0, verify that setup-ruby already supports it (it usually does very quickly).
- **Raising `required_ruby_version` is a breaking change**. Users on the old Ruby version will no longer be able to install the gem, so a minor or major gem version bump is required at release time. Handle this in a separate PR / commit, not as part of this matrix update.

## Pitfalls

- **Forgetting to update the gemspec lower bounds** means the old Ruby/Rails version you removed from CI can still be `gem install`-ed, creating a mismatch between stated and actual support.
- **Updating only the gemfile or only the matrix** breaks CI — either a missing gemfile is referenced, or an unused gemfile is left behind. Always update both together.
- **Mixing unrelated changes** (e.g., fixing `http://` → `https://` sources) into the same commit as version removals obscures intent. Commit each logical unit separately.
