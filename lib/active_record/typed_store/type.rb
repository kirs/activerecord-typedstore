module ActiveRecord::TypedStore
  class Type < ActiveRecord::Type::Serialized
    def initialize(columns, coder)
      @columns = columns
      super(ActiveRecord::Type::Value.new, coder)
    end

    def deserialize(value)
      if value.nil?
        hash = {}
      else
        hash = super
      end

      TypedHash.new(columns).tap do |r|
        r.update(defaults)
        r.update(hash)
      end
    end

    def serialize(value)
      return if value.nil?
      super(value.to_h)
    end

    def cast(value)
      value = super
      if value.is_a?(::Hash)
        TypedHash.new(columns).tap do |r|
          r.update defaults
          r.update value
        end
      end
    end

    def defaults
      @columns.map { |k, v| [k, v.default] }.to_h
    end

    protected

    attr_reader :columns
  end
end
