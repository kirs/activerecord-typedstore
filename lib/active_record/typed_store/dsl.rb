module ActiveRecord::TypedStore
  class DSL
    attr_reader :types, :defaults

    def initialize(accessors)
      @types = Hash.new(ActiveRecord::Type::Value.new)
      @defaults = {}
      yield self
    end

    def accessors
      @types.keys
    end

    NO_DEFAULT_GIVEN = Object.new
    [:string, :text, :integer, :float, :datetime, :date, :boolean, :decimal].each do |type|
      define_method(type) do |name, default: NO_DEFAULT_GIVEN, null: true, array: false, **options|
        @types[name.to_sym] = ActiveRecord::Type.lookup(type)

        if default != NO_DEFAULT_GIVEN
          @defaults[name.to_sym] = default
        end
      end
    end
    alias_method :date_time, :datetime

    def any(name, **options)
      @types[name.to_sym] = ActiveRecord::Type::Value.new
    end
  end
end
