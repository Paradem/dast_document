# DastDocument

A Ruby gem for rendering DatoCMS DAST (DatoCMS Abstract Syntax Tree) documents into HTML. Supports rich text elements (headings, paragraphs, lists) and embedded blocks with custom components.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add dast_document

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install dast_document

## Usage

Basic usage:

```ruby
require 'dast_document'

dast = { "value" => { "document" => { "type" => "document", "children" => [...] } }, "blocks" => [...] }
document = DastDocument::Document.new(dast)
html = document.to_html
```

For blocks with custom components:

```ruby
# Assuming Rails view context and component module
document = DastDocument::Document.new(dast, view_context: self, component_module: Components)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paradem/dast_document.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).