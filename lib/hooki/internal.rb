# frozen_string_literal: true

module Hooki
  module Internal
    class << self
      def callbacks(before_callbacks, after_callbacks, scope, method_name, &blk)
        before_callbacks.each do |callback|
          trigger_callback(callback, scope, method_name)
        end

        result = blk.call

        after_callbacks.each do |callback|
          trigger_callback(callback, scope, method_name)
        end

        result
      end

      def trigger_callback(callback, scope, method_name)
        method = scope.method(callback[:callback_method_name])
        case method.arity
        when 0
          scope.__send__(callback[:callback_method_name])
        when 1, -1
          scope.__send__(callback[:callback_method_name], method_name)
        end
      end
    end
  end
end
