require_relative 'lib/tty-progressbar'

puts "here's some stuff"
puts "go go go"

bars = TTY::ProgressBar::Multi.new("main [:bar] :percent")

BAR1_TIMES = 15
BAR2_TIMES = 5

bar1 = bars.register("one [:bar] :percent", total: BAR1_TIMES)
bar2 = bars.register("two [:bar] :percent", total: BAR2_TIMES)

bars.start  # starts all registered bars timers

i1 = 0
i2 = 0

th1 = Thread.new {
  BAR1_TIMES.times {
    bars.log("Bar 1 (#{i1 += 1}): #{rand}")
    sleep(0.1)
    bar1.advance
  }
}
th2 = Thread.new {
  BAR2_TIMES.times {
    bars.log("Bar 2 (#{i2 += 1}): #{rand}")
    sleep(0.5)
    bar2.advance
  }
}

[th1, th2].each(&:join)
