module ActiveRecord::TypedStore
  class Column
    attr_reader :array, :blank, :name, :default, :type, :null, :accessor

    def initialize(name, type, options={})
      @accessor = options.fetch(:accessor, true)
      @name = name
      @type = type
      @default = extract_default(options.fetch(:default, nil))
      @null = options.fetch(:null, true)
      @blank = options.fetch(:blank, true)
      @array = options.fetch(:array, false)
    end

    def has_default?
      !default.nil?
    end

    def cast(value)
      casted_value = type_cast(value)
      if !blank
        casted_value = default if casted_value.blank?
      elsif !null
        casted_value = default if casted_value.nil?
      end
      casted_value
    end

    def extract_default(value)
      # return value if (type == :string || type == :text) && value.nil?

      type_cast(value)
    end

    def type_cast(value, arrayize: true)
      if array && (arrayize || value.is_a?(Array))
        return [] if arrayize && !value.is_a?(Array)
        return value.map { |v| type_cast(v, arrayize: false) }
      end

      # if type == :string || type == :text
      #   return value.to_s unless value.nil? && (null || array)
      # end

      casted_value = type.cast(value)
      casted_value
    end
  end
end
