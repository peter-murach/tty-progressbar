# frozen_string_literal: true

RSpec.describe TTY::ProgressBar::Multi, "advance" do
  let(:output) { RSpec::Support::Ruby.truffleruby? ? OutputIO.new : StringIO.new }
  let(:save) { TTY::Cursor.save }
  let(:restore) { TTY::Cursor.restore }
  let(:top) { TTY::ProgressBar::Multi::DEFAULT_INSET[:top] }
  let(:middle) { TTY::ProgressBar::Multi::DEFAULT_INSET[:middle] }
  let(:bottom) { TTY::ProgressBar::Multi::DEFAULT_INSET[:bottom] }

  it "advances progress bars correctly under multibar" do
    bars = described_class.new(output: output)

    bar1 = bars.register("[:bar] one", total: 5)
    bar2 = bars.register("[:bar] two", total: 5)

    bar2.advance
    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G[=    ] two\n",
      "\e[1G[=    ] one\n"
    ].join)

    bar2.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G[=    ] two\n",
      "\e[1G[=    ] one\n",
      save,
      "\e[2A", # up 2 lines
      "\e[1G[==   ] two",
      restore
    ].join)

    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G[=    ] two\n",
      "\e[1G[=    ] one\n",
      save,
      "\e[2A", # up 2 lines
      "\e[1G[==   ] two",
      restore,
      save,
      "\e[1A", # up 1 line
      "\e[1G[==   ] one",
      restore
    ].join)
  end

  it "advances progress bars correctly under top level multibar" do
    bars = described_class.new("[:bar] main", output: output)

    bar1 = bars.register("[:bar] one", total: 5)
    bar2 = bars.register("[:bar] two", total: 5)

    bar2.advance
    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}[=         ] main\n",
      "\e[1G#{bottom}[=    ] two\n",
      save,
      "\e[2A",   # up 2 lines
      "\e[1G#{top}[==        ] main",
      restore,
      "\e[1G#{bottom}[=    ] one\n"
    ].join)

    bar2.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}[=         ] main\n",
      "\e[1G#{bottom}[=    ] two\n",
      save,
      "\e[2A",   # up 2 lines
      "\e[1G#{top}[==        ] main",
      restore,
      "\e[1G#{bottom}[=    ] one\n",
      save,
      "\e[3A",   # up 3 lines
      "\e[1G#{top}[===       ] main",
      restore,
      save,
      "\e[2A",   # up 2 lines,
      "\e[1G#{middle}[==   ] two",
      restore
    ].join)

    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}[=         ] main\n",
      "\e[1G#{bottom}[=    ] two\n",
      save,
      "\e[2A",   # up 2 lines
      "\e[1G#{top}[==        ] main",
      restore,
      "\e[1G#{bottom}[=    ] one\n",
      save,
      "\e[3A",   # up 3 lines
      "\e[1G#{top}[===       ] main",
      restore,
      save,
      "\e[2A",   # up 2 lines,
      "\e[1G#{middle}[==   ] two",
      restore,
      save,
      "\e[3A",   # up 3 lines
      "\e[1G#{top}[====      ] main",
      restore,
      save,
      "\e[1A",   # up 1 line
      "\e[1G#{bottom}[==   ] one",
      restore
    ].join)
  end

  it "advances progress bars correctly with indeterminate children" do
    bars = described_class.new("total: :current", output: output)

    bar1 = bars.register("one: :current")
    bar2 = bars.register("two: :current")

    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}total: 1\n",
      "\e[1G#{bottom}one: 1\n"
    ].join)

    bar2.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}total: 1\n",
      "\e[1G#{bottom}one: 1\n",
      save,
      "\e[2A", # up 2 lines
      "\e[1G#{top}total: 2",
      restore,
      "\e[1G#{bottom}two: 1\n"
    ].join)

    bar1.advance

    output.rewind
    expect(output.read).to eq([
      "\e[1G#{top}total: 1\n",
      "\e[1G#{bottom}one: 1\n",
      save,
      "\e[2A", # up 2 lines
      "\e[1G#{top}total: 2",
      restore,
      "\e[1G#{bottom}two: 1\n",
      save,
      "\e[3A", # up 3 lines
      "\e[1G#{top}total: 3",
      restore,
      save,
      "\e[2A", # up 2 lines
      "\e[1G#{middle}one: 2",
      restore
    ].join)
  end
end
