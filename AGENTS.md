# Build Commands
- Setup: bin/setup
- Test all: rake test
- Test single: ruby -I test test/dast_document_test.rb --name <test_method>
- Lint: rake standard

# Code Style
- frozen_string_literal: true at file top
- require_relative for internal requires
- StandardRB linting (ruby 2.6+)
- RBS type signatures required
- Minitest for testing
- Nokogiri for HTML parsing
- Use &. safe navigation, then chaining
- Descriptive test method names