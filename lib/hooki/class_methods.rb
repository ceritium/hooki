# frozen_string_literal: true

module Hooki
  module ClassMethods
    def before_singleton_method(method_name, only: [], except: [])
      callback = { callback_method_name: method_name, only: wrap(only), except: wrap(except) }
      with_lock do
        @before_singleton_method_callbacks << callback
        @ignore_singleton_methods << method_name
      end
      callback
    end

    def after_singleton_method(method_name, only: [], except: [])
      callback = { callback_method_name: method_name, only: wrap(only), except: wrap(except) }
      with_lock do
        @after_singleton_method_callbacks << callback
        @ignore_singleton_methods << method_name
      end
      callback
    end

    def before_method(method_name, only: [], except: [])
      callback = { callback_method_name: method_name, only: wrap(only), except: wrap(except) }
      with_lock do
        @before_method_callbacks << callback
        @ignore_methods << method_name
      end
      callback
    end

    def after_method(method_name, only: [], except: [])
      callback = { callback_method_name: method_name, only: wrap(only), except: wrap(except) }
      with_lock do
        @after_method_callbacks << callback
        @ignore_methods << method_name
      end
      callback
    end

    private

    def singleton_method_added(method_name)
      super

      return if @ignore_singleton_methods.include?(method_name)

      before_callbacks = filter_callbacks(@before_singleton_method_callbacks, method_name)
      after_callbacks = filter_callbacks(@after_singleton_method_callbacks, method_name)

      return if before_callbacks.empty? && after_callbacks.empty?

      original_method = method(method_name)

      @ignore_singleton_methods << method_name
      redefine_singleton_method(method_name) do |*args, &blk|
        Hooki::Internal.callbacks(before_callbacks, after_callbacks, self, method_name) do
          original_method.call(*args, &blk)
        end
      end
    end

    def method_added(method_name)
      super

      return if @ignore_methods.include?(method_name)

      before_callbacks = filter_callbacks(@before_method_callbacks, method_name)
      after_callbacks = filter_callbacks(@after_method_callbacks, method_name)
      return if before_callbacks.empty? && after_callbacks.empty?

      original_method = instance_method(method_name)

      @ignore_methods << method_name
      redefine_method(method_name) do |*args, &blk|
        Hooki::Internal.callbacks(before_callbacks, after_callbacks, self, method_name) do
          original_method.bind(self).call(*args, &blk)
        end
      end
    end

    def filter_callbacks(callbacks, method_name)
      callbacks.select do |callback|
        (callback[:only].empty? || callback[:only].include?(method_name)) &&
          (callback[:except].empty? || !callback[:except].include?(method_name))
      end
    end

    def with_lock(&block)
      @lock.synchronize(&block)
    end

    def wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end
