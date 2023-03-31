# frozen_string_literal: true

require "benchmark/ips"
require "hooki"

class WithoutHooki
  def bar
    log
  end

  private

  def log
    # noop
  end
end

class WithHooki
  prepend Hooki

  before_method :log

  def bar
    # noop
  end

  private

  def log
    # noop
  end
end

Benchmark.ips do |x|
  x.warmup = 2
  x.time = 5
  x.report("with") { WithHooki.new.bar }
  x.report("without") { WithoutHooki.new.bar }
  x.compare!
end
