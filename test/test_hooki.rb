# frozen_string_literal: true

require "test_helper"
require "examples"

class HookiTest < Minitest::Test
  def assert_output_list(list, &block)
    string = (list + [""]).join("\n")
    assert_output(string) { block.call }
  end

  test "in a module including a module with hooki" do
    assert_output_list([
                         "before singleton another log",
                         "singleton another",
                         "after singleton another log"
                       ]) { Examples::ModuleIncludingModuleWithHooki.another }
  end

  test "in a class" do
    assert_output_list([
                         "before singleton save log",
                         "singleton save",
                         "after singleton save log"
                       ]) { Examples::ClassWithHooki.save }

    assert_output_list([
                         "before instance save log",
                         "instance save",
                         "after instance save log"
                       ]) { Examples::ClassWithHooki.new.save }
  end

  test "inheriting a class with hooki" do
    assert_output_list([
                         "before singleton another log",
                         "singleton another",
                         "after singleton another log"
                       ]) { Examples::Inheriting.another }

    assert_output_list([
                         "before instance another log",
                         "instance another",
                         "after instance another log"
                       ]) { Examples::Inheriting.new.another }
  end

  test "inheriting two times a class with hooki" do
    assert_output_list([
                         "before singleton another_again log",
                         "singleton another_again",
                         "after singleton another_again log"
                       ]) { Examples::InheritingAgain.another_again }

    assert_output_list([
                         "before instance another_again log",
                         "instance another_again",
                         "after instance another_again log"
                       ]) { Examples::InheritingAgain.new.another_again }
  end

  test "only option" do
    klass = Class.new do
      include Hooki

      before_method :log, only: :save

      def save; end
      def delete; end

      private

      def log
        puts "logging"
      end
    end

    assert_output("logging\n") { klass.new.save }
    assert_silent { klass.new.delete }
  end

  test "except option" do
    klass = Class.new do
      include Hooki

      before_method :log, except: :delete

      def save; end
      def delete; end

      private

      def log
        puts "logging"
      end
    end

    assert_output("logging\n") { klass.new.save }
    assert_silent { klass.new.delete }
  end

  test "callbacks with plat(*) argument" do
    klass = Class.new do
      include Hooki

      before_method :before_log

      def save; end

      private

      def before_log(*)
        puts "before logging"
      end
    end

    assert_output("before logging\n") do
      klass.new.save
    end
  end

  test "callbacks without arguments" do
    klass = Class.new do
      include Hooki

      before_method :before_log

      def save; end

      private

      def before_log
        puts "before logging"
      end
    end

    assert_output("before logging\n") do
      klass.new.save
    end
  end
end
