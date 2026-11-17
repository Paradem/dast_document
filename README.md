# DastDocument

Render DatoCMS structured-text (DAST) documents to HTML and dispatch embedded
blocks into the host's own component module. Block classes and their markup are
site-owned; there is no shared catalogue of block types.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

```ruby
DastDocument::Document.new(dast, component_module: Blocks, view_context: view_context).walk
```

`dast` responds to `value` (the DAST envelope) and `blocks` (embedded records).
A CMS key such as `text_with_image` resolves to `Blocks::TextWithImage`, constructed
with `resource: block`. Only constants defined directly in the supplied module
are considered. Add a component to that module to support a new block; no
registration table, shared block inventory or layout metadata is required.

Each site supplies its own module, components and styling. Hosts with their own
DAST walkers can retain their own constructor and rendering conventions.

The optional [`block_registry:` prototype](docs/block-registry.md) remains for
compatibility with its published API, but is not needed for module dispatch.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dast_document.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
