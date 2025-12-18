# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dast_document"

ENV["MINITEST_PLUGINS"] = nil
require "minitest/autorun"

class String
  def html_safe
    self
  end
end
