require 'active_record/typed_store/column'
module ActiveRecord::TypedStore
  class DSL
    attr_reader :columns, :coder

    def initialize(options)
      @coder = options.fetch(:coder, default_coder)
      @columns = {}
      yield self
    end

    def default_coder
      ActiveRecord::Coders::YAMLColumn.new
    end

    def accessors
      @columns.values.select { |v| v.accessor }.map(&:name)
    end

    NO_DEFAULT_GIVEN = Object.new
    [:string, :text, :integer, :float, :datetime, :date, :boolean, :decimal].each do |type|
      define_method(type) do |name, **options|
        if options
          type_options = options.extract!(:scale, :limit, :precision)
        end
        # binding.pry if name.to_s == "public"
        if options.key?(:default)
          options[:default] = decode_default(options[:default])
        end
        ar_type = ActiveRecord::Type.lookup(type, **type_options)
        @columns[name] = Column.new(name, ar_type, options)
      end
    end
    alias_method :date_time, :datetime

    def any(name, **options)
      @columns[name] = Column.new(name, ActiveRecord::Type::Value.new, options)
    end

    def decode_default(value)
      if @coder.is_a?(ActiveRecord::Coders::YAMLColumn)
        begin
          @coder.load(value)
        rescue
          value
        end
      else
        value
      end
    end
  end
end
