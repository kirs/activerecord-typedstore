module ActiveRecord::TypedStore
  class TypedHash < HashWithIndifferentAccess
    # class << self

    #   attr_reader :columns

    #   def create(columns)
    #     Class.new(self) do
    #       @columns = columns.index_by { |c| c.name.to_s }
    #     end
    #   end
    # end

    def initialize(columns)
      super()
      @columns = columns
    end

    def []=(key, value)
      super(key, cast_value(key, value))
    end
    alias_method :store, :[]=

    def merge!(other_hash)
      other_hash.each_pair do |key, value|
        if block_given? && key?(key)
          value = yield(convert_key(key), self[key], value)
        end
        self[convert_key(key)] = convert_value(value)
      end
      self
    end
    alias_method :update, :merge!

    private

    def cast_value(key, value)
      column = @columns[key.to_sym]
      column.cast(value)
    end
  end
end
