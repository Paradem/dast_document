# frozen_string_literal: true

module Minitest
  def self.load_plugins
    # do nothing
  end
end

require "minitest"

require_relative "test_helper"
require_relative "dast_document_test"

Minitest.run
