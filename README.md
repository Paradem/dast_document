# DastDocument

A Ruby gem for rendering DatoCMS DAST (DatoCMS Abstract Syntax Tree) documents into HTML. Supports rich text elements (headings, paragraphs, lists) and embedded blocks with custom components.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Document Rendering](#basic-document-rendering)
  - [Text Formatting and Marks](#text-formatting-and-marks)
  - [Links and Blockquotes](#links-and-blockquotes)
  - [Blocks and Custom Components](#blocks-and-custom-components)
  - [Edge Cases and Error Handling](#edge-cases-and-error-handling)
  - [Supported Node Types](#supported-node-types)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add dast_document

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install dast_document

## Usage

### Basic Document Rendering

Basic usage for rendering a DAST document into HTML:

```ruby
require 'dast_document'

dast = { "value" => { "document" => { "type" => "root", "children" => [
  { "type" => "paragraph", "children" => [{ "type" => "span", "value" => "Hello world!" }] },
  { "type" => "heading", "level" => 1, "value" => "Title" },
  { "type" => "list", "style" => "numbered", "children" => [
    { "type" => "listItem", "children" => [{ "type" => "paragraph", "children" => [{ "type" => "span", "value" => "Item 1" }] }] }
  ] }
] } }, "blocks" => [] }
document = DastDocument::Document.new(dast)
html = document.to_html
# Output: <p>Hello world!</p><h1>Title</h1><ol><li><p>Item 1</p></li></ol>
```

Note: Newlines in text content are automatically converted to `<br>` tags (e.g., "line1\n\nline2" becomes "line1<br>line2").

### Text Formatting and Marks

Apply rich text formatting using marks on spans:

```ruby
dast = { "value" => { "document" => { "type" => "root", "children" => [
  { "type" => "paragraph", "children" => [
    { "type" => "span", "value" => "Bold and italic", "marks" => ["emphasis", "underline"] }
  ] }
] } }, "blocks" => [] }
document = DastDocument::Document.new(dast)
html = document.to_html
# Output: <p><em><u>Bold and italic</u></em></p>
```

Unknown marks fall back to using the mark name as the HTML tag.

### Links and Blockquotes

Render links and blockquotes:

```ruby
dast = { "value" => { "document" => { "type" => "root", "children" => [
  { "type" => "link", "url" => "https://example.com" },
  { "type" => "blockquote", "attribution" => "Author Name", "children" => [
    { "type" => "paragraph", "children" => [{ "type" => "span", "value" => "Quote text" }] }
  ] }
] } }, "blocks" => [] }
document = DastDocument::Document.new(dast)
html = document.to_html
# Output: <a href="https://example.com"></a><figure><blockquote><p>Quote text</p></blockquote><figcaption>Author Name</figcaption></figure>
```

### Blocks and Custom Components

For blocks with custom components, provide a view context and component module:

```ruby
# Assuming Rails view context and component module
document = DastDocument::Document.new(dast, view_context: self, component_module: Components)
```

If a component is missing or view context lacks a render method, error messages are displayed in the HTML output (e.g., "Can't render block ComponentName no component defined").

### Edge Cases and Error Handling

The gem handles malformed or missing data gracefully:
- Empty documents or missing node types are skipped without errors.
- Invalid inputs (e.g., non-integer heading levels) are rendered as-is or with defaults.
- Unknown node types are ignored, ensuring robust rendering.

### Supported Node Types

| Node Type      | Description                          | Example Output |
|----------------|--------------------------------------|----------------|
| paragraph      | Text paragraph                       | `<p>Text</p>` |
| heading        | Headings (levels 1-6)                | `<h1>Title</h1>` |
| list           | Ordered/unordered lists              | `<ol><li>Item</li></ol>` or `<ul>` |
| listItem       | List items                           | `<li>Item</li>` |
| span           | Text with marks                      | `<span>Text</span>` or `<em>Text</em>` |
| link           | Links                                | `<a href="url"></a>` |
| blockquote     | Blockquotes with attribution         | `<figure><blockquote>Text</blockquote><figcaption>Attr</figcaption></figure>` |
| thematicBreak  | Horizontal rules                     | `<hr>` |
| block          | Embedded blocks with components      | Custom component HTML |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paradem/dast_document.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).