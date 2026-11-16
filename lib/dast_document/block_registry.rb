# frozen_string_literal: true

module DastDocument
  # Explicit host-owned mapping from CMS block keys/aliases to renderers.
  # Registering a renderer is the only way a block is rendered; this registry
  # never constantizes a CMS-provided key.
  class BlockRegistry
    class Error < StandardError; end
    class RegistrationError < Error; end
    class UnknownBlock < Error; end
    class InvalidBlock < Error; end

    LAYOUTS = %i[reading wide section].freeze
    CONTAINERS = %i[block shell].freeze

    Entry = Data.define(:key, :aliases, :renderer, :validator, :text_extractor, :layout, :container)

    # key:      callable that returns the host's discriminator for a block.
    # unknown:  :omit, :raise, or a callable that receives the block.
    def initialize(key:, unknown:)
      raise RegistrationError, "key extractor must respond to call" unless key.respond_to?(:call)

      unless unknown.nil? || unknown == :omit || unknown == :raise || unknown.respond_to?(:call)
        raise RegistrationError, "unknown must be :omit, :raise or a callable"
      end
      @key = key
      @unknown = unknown
      @entries = {}
    end

    def register(key, renderer:, aliases: [], validate: nil, text: nil, layout: :reading, container: :block)
      key = normalize_key(key)
      names = [key] + Array(aliases).map { |name| normalize_key(name) }
      raise RegistrationError, "duplicate block key #{names.first}" if names.uniq.length != names.length
      occupied = names.find { |name| @entries.key?(name) }
      raise RegistrationError, "block key or alias already registered: #{occupied}" if occupied
      raise RegistrationError, "renderer must respond to call" unless renderer.respond_to?(:call)
      raise RegistrationError, "validator must respond to call" if validate && !validate.respond_to?(:call)
      raise RegistrationError, "text extractor must respond to call" if text && !text.respond_to?(:call)

      layout = layout.to_sym
      container = container.to_sym
      raise RegistrationError, "unknown layout role: #{layout}" unless LAYOUTS.include?(layout)
      raise RegistrationError, "unknown container ownership: #{container}" unless CONTAINERS.include?(container)

      entry = Entry.new(
        key: key,
        aliases: names.drop(1).freeze,
        renderer: renderer,
        validator: validate,
        text_extractor: text,
        layout: layout,
        container: container
      )
      names.each { |name| @entries[name] = entry }
      self
    end

    def key_for(block)
      value = @key.call(block)
      value&.to_s
    end

    def entry_for(block)
      key = key_for(block)
      key && @entries[key]
    end

    # A nil return omits the block. Hosts choose unknown behavior explicitly.
    def render(block, context: nil)
      entry = entry_for(block)
      return unknown(block) unless entry
      if entry.validator
        raise InvalidBlock, "Invalid block data for #{entry.key}" unless entry.validator.call(block, context)
      end

      entry.renderer.call(block, context)
    end

    def text(block)
      entry_for(block)&.text_extractor&.call(block)
    end

    private

    def normalize_key(value)
      key = value.to_s
      raise RegistrationError, "block key must be nonblank" if key.empty? || key != key.strip

      key
    end

    def unknown(block)
      case @unknown
      when :omit, nil then nil
      when :raise
        raise UnknownBlock, "Unknown block type #{key_for(block).inspect}"
      else
        @unknown.call(block)
      end
    end
  end
end
