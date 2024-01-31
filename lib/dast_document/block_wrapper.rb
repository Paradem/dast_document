module DastDocument
  class BlockWrapper
    attr_reader :content
    def initialize(content)
      @content = content
    end

    def nil?
      @block.nil?
    end

    def id
      @block.id
    end

    def name
      @block._model_api_key.split("_").map(&:capitalize).join
    end

    def component_name
      "#{name}Component"
    end
  end
end
