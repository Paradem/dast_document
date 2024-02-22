module DastDocument
  class BlockWrapper
    attr_reader :content
    def initialize(content)
      @content = content
    end

    def nil?
      @content.nil?
    end

    def id
      @content&.id
    end

    def name
      @content&._model_api_key&.split("_")&.map(&:capitalize)&.join
    end

    def component_name
      name.to_s
    end
  end
end
