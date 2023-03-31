# frozen_string_literal: true

require "benchmark/ips"
require "hooki"

class WithoutHooki
  def bar
    100.times.reduce(1, :*)
    log
  end

  private

  def log; end
end

class WithHooki
  prepend Hooki

  before_method :log

  def bar
    100.times.reduce(1, :*)
  end

  private

  def log
    # puts "bar method called"
  end
end

Benchmark.ips do |x|
  x.warmup = 2
  x.time = 5
  x.report("with") { WithHooki.new.bar }
  x.report("without") { WithoutHooki.new.bar }
  x.compare!
end
