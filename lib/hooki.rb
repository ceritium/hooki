# frozen_string_literal: true

require_relative "ext/module"

require_relative "hooki/version"
require_relative "hooki/internal"
require_relative "hooki/class_methods"

module Hooki
  def self.prepended(klass)
    hooki(klass)
  end

  def self.included(klass)
    hooki(klass)
  end

  INSTANCE_VARIABLE_LIST = %i[
    @before_method_callbacks @before_singleton_method_callbacks
    @after_method_callbacks @after_singleton_method_callbacks
    @ignore_methods @ignore_singleton_methods
  ].freeze

  def self.hooki(klass)
    klass.extend(Hooki::ClassMethods)
    klass.instance_variable_set(:@lock, Mutex.new)
    INSTANCE_VARIABLE_LIST.each do |instance_variable|
      klass.instance_variable_set(instance_variable, [])
    end

    klass.instance_variable_set(:@ignore_singleton_methods, %i[included extended])

    def klass.included(klass)
      super
      Hooki.rehooki(self, klass)
    end

    def klass.prepended(klass)
      super
      Hooki.rehooki(self, klass)
    end

    def klass.inherited(klass)
      super
      Hooki.rehooki(self, klass)
    end

    def klass.append_features(mod)
      super
      mod.include(Hooki) # Notice this
      Hooki.rehooki(self, mod)
    end
  end

  def self.rehooki(parent, child)
    INSTANCE_VARIABLE_LIST.each do |instance_variable|
      child.instance_variable_set(instance_variable, parent.instance_variable_get(instance_variable))
    end
  end
end
