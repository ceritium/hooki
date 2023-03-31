# frozen_string_literal: true

require "hooki"

module Examples
  module ModuleWithHooki
    include Hooki

    before_singleton_method :before_singleton_log
    after_singleton_method :after_singleton_log

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def save
        puts "singleton save"
      end

      def before_singleton_log(method_name)
        puts "before singleton #{method_name} log"
      end

      def after_singleton_log(method_name)
        puts "after singleton #{method_name} log"
      end
    end
  end

  module ModuleIncludingModuleWithHooki
    include ModuleWithHooki

    def self.another
      puts "singleton another"
    end
  end

  class ClassWithHooki
    include Hooki

    before_singleton_method :before_singleton_log
    after_singleton_method :after_singleton_log

    def self.save
      puts "singleton save"
    end

    def self.before_singleton_log(method_name)
      puts "before singleton #{method_name} log"
    end

    def self.after_singleton_log(method_name)
      puts "after singleton #{method_name} log"
    end

    before_method :before_instance_log
    after_method :after_instance_log

    def save
      puts "instance save"
    end

    private

    def before_instance_log(method_name)
      puts "before instance #{method_name} log"
    end

    def after_instance_log(method_name)
      puts "after instance #{method_name} log"
    end
  end

  class Inheriting < ClassWithHooki
    def self.another
      puts "singleton another"
    end

    def another
      puts "instance another"
    end
  end

  class InheritingAgain < Inheriting
    def self.another_again
      puts "singleton another_again"
    end

    def another_again
      puts "instance another_again"
    end
  end
end
