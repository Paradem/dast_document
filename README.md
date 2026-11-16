# DastDocument

Render DatoCMS structured-text (DAST) documents to HTML. The optional block
registry provides an explicit, host-owned map from CMS block keys to renderer
factories, with layout/container metadata and unknown-block policy.

See [the block registry contract](docs/block-registry.md) for integration and
limits.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

```ruby
DastDocument::Document.new(dast, view_context: view_context).walk
```

`dast` responds to `value` (the DAST envelope) and `blocks` (embedded block
records). Pass `block_registry:` to use an explicit registry instead of the
legacy component-module dispatch. The registry never constantizes CMS keys.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dast_document.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
