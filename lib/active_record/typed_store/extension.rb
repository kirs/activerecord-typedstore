require 'active_record/typed_store/dsl'
require 'active_record/typed_store/type'
require 'active_record/typed_store/typed_hash'

module ActiveRecord::TypedStore
  module Extension
    extend ActiveSupport::Concern

    included do
      class_attribute :typed_stores
    end

    module ClassMethods
      def store_accessors
        typed_stores.values.map(&:accessors).flatten
      end

      def typed_store(store_attribute, options={}, &block)
        dsl = DSL.new(options, &block)
        self.typed_stores = {}
        self.typed_stores[store_attribute] = dsl
        attribute(store_attribute, Type.new(dsl.types, dsl.defaults))
        store_accessor(store_attribute, dsl.accessors)
      end

      def define_attribute_methods
        super
        define_typed_store_attribute_methods
      end

      def undefine_attribute_methods # :nodoc:
        super if @typed_store_attribute_methods_generated
        @typed_store_attribute_methods_generated = false
      end
      def define_typed_store_attribute_methods
        return if @typed_store_attribute_methods_generated
        store_accessors.each do |attribute|
          define_attribute_method(attribute.to_s)
          undefine_before_type_cast_method(attribute)
        end
        @typed_store_attribute_methods_generated = true
      end

      def undefine_before_type_cast_method(attribute)
        # because it mess with ActionView forms, see #14.
        method = "#{attribute}_before_type_cast"
        undef_method(method) if method_defined?(method)
      end
    end

    def write_store_attribute(store_attribute, key, value)
      prev_value = read_store_attribute(store_attribute, key)
      new_value = typed_stores[store_attribute].types[key].cast(value)
      attribute_will_change!(key.to_s) if new_value != prev_value
      super
    end
  end
end
