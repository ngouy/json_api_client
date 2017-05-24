module JsonApiClient
  module Helpers
    module DynamicAttributes

      def attributes
        @attributes
      end

      def attributes=(attrs = {})
        @attributes ||= ActiveSupport::HashWithIndifferentAccess.new

        return @attributes unless attrs.present?
        attrs.each do |key, value|
          send("#{key}=", value)
        end
      end

      def [](key)
        read_attribute(key)
      end

      def []=(key, value)
        set_attribute(key, value)
      end

      def respond_to_missing?(method, include_private = false)
        if (method.to_s =~ /^(.*)=$/) || has_attribute?(method)
          true
        else
          super
        end
      end

      def has_attribute?(attr_name)
        attributes.has_key?(attr_name)
      end

      protected

      def nested_key_unformat(param)
        if param.is_a?(Hash)
          param.map {|k, v| [key_formatter.unformat(k), nested_key_unformat(v)] }.to_h
        elsif param.is_a?(Array)
          param.map { |elem| nested_key_unformat(elem) }
        else
          param
        end
      end

      def method_missing(method, *args, &block)
        normalized_method = if key_formatter
                              key_formatter.unformat(method.to_s)
                            else
                              method.to_s
                            end

        if normalized_method =~ /^(.*)=$/
          if key_formatter && nested_key_unformat?
            set_attribute($1, nested_key_unformat(args.first))
          else
            set_attribute($1, args.first)
          end
        elsif has_attribute?(method)
          attributes[method]
        else
          super
        end
      end

      def read_attribute(name)
        attributes.fetch(name, nil)
      end

      def set_attribute(name, value)
        attributes[name] = value
      end

      def key_formatter
        self.class.respond_to?(:key_formatter) && self.class.key_formatter
      end

    end
  end
end
