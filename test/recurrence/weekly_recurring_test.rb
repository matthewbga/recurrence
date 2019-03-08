require "test_helper"

class WeeklyRecurringTest < Minitest::Test
  test "recurs until limit date" do
    r = Recurrence.weekly(:on => :thursday)
    assert_equal Date.parse("2037-12-31"), r.events[-1]
  end

  test "repeats 6 weeks from now" do
    date = 6.weeks.from_now
    r = recurrence(:every => :week, :on => date.wday, :until => date.to_date)
    assert_equal date.to_date, r.events[-1]
  end

  test "repeats through 6 weeks from now" do
    date = 6.weeks.from_now
    r = recurrence(:every => :week, :on => date.wday, :through => date.to_date)
    assert_equal date.to_date, r.events[-1]
  end

  test "starts 3 months ago (#{3.months.ago.to_s(:date)})" do
    date = 3.months.ago

    r = recurrence(:every => :week, :on => date.wday, :starts => date.to_date)
    assert_equal date.to_date, r.events[0]
    assert_equal (date + 1.week).to_date, r.events[1]
    assert_equal (date + 2.weeks).to_date, r.events[2]
    assert_equal (date + 3.weeks).to_date, r.events[3]
    assert_equal (date + 4.weeks).to_date, r.events[4]
    assert_equal (date + 5.weeks).to_date, r.events[5]
    assert_equal (date + 6.weeks).to_date, r.events[6]
  end

  test "starts at 2008-02-29 and repeat until 2008-03-14" do
    starts = Date.parse("2008-02-29")
    ends = Date.parse("2008-03-14")

    r = recurrence(
      :every  => :week,
      :on     => :friday,
      :starts => starts,
      :until  => ends.to_date
    )
    assert_equal "2008-02-29", r.events[0].to_s
    assert_equal "2008-03-07", r.events[1].to_s
    assert_equal ends.to_s, r.events[-1].to_s
  end

  test "starts at 2008-02-29 and repeat through 2008-03-14" do
    starts = Date.parse("2008-02-29")
    ends = Date.parse("2008-03-14")

    r = recurrence(
      :every  => :week,
      :on     => :friday,
      :starts => starts,
      :through=> ends.to_date
    )
    assert_equal "2008-02-29", r.events[0].to_s
    assert_equal "2008-03-07", r.events[1].to_s
    assert_equal ends.to_s, r.events[-1].to_s
  end

  test "uses interval on any weekday" do
    puts ""
    [*0..6].each do |dow|
      initial_offset = dow
      date = initial_offset.days.from_now.beginning_of_day
      r = recurrence(
        :every    => :week,
        :on       => date.wday,
        :interval => 2,
        :starts   => date.beginning_of_day,
        :until    => date + 6.weeks
      )
      # puts "Beginning: #{date.to_date}, a #{date.strftime("%A")}, offset: #{initial_offset}, through #{date + 6.weeks}"
      # puts "First event date: #{r.events[0].to_date}"
      # r.events.each {|d| puts d.to_s }
      assert_equal date, r.events[0]
      assert_equal (date + 2.weeks).to_date, r.events[1]
      assert_equal (date + 4.weeks).to_date, r.events[2]
      assert_equal (date + 6.weeks).to_date, r.events[3]
      assert_equal 4, r.events.size
    end
  end

  test "uses repeat" do
    starts = Date.parse("2008-09-21")
    r = recurrence(
      :every    => :week,
      :on       => starts.wday,
      :starts   => starts,
      :until    => "2011-01-01",
      :repeat    => 5
    )
    assert_equal 5, r.events.size
  end

  test "occurs several times per week" do
    starts = Date.parse("2008-09-21") #=> sunday
    r = recurrence(
      :every    => :week,
      :on       => [:saturday, :sunday],
      :interval => 2,
      :starts   => starts,
      :until    => "2009-01-01"
    )
    assert_equal "2008-09-21", r.events[0].to_s
    assert_equal "2008-09-27", r.events[1].to_s
    assert_equal "2008-10-05", r.events[2].to_s
    assert_equal "2008-10-11", r.events[3].to_s
    assert_equal "2008-10-19", r.events[4].to_s
    assert_equal "2008-10-25", r.events[5].to_s
    assert_equal "2008-11-02", r.events[6].to_s
    assert_equal "2008-11-08", r.events[7].to_s

    starts = Date.parse("2008-09-21") #=> sunday
    r = recurrence(
      :every  => :week,
      :on     => [:monday, :wednesday, :friday],
      :starts => starts,
      :until  => "2009-01-01"
    )
    assert_equal "2008-09-22", r.events[0].to_s
    assert_equal "2008-09-24", r.events[1].to_s
    assert_equal "2008-09-26", r.events[2].to_s
    assert_equal "2008-09-29", r.events[3].to_s
    assert_equal "2008-10-01", r.events[4].to_s
    assert_equal "2008-10-03", r.events[5].to_s
  end

  test "runs until next available saturday" do
    starts = Date.parse("2008-09-21") # => sunday
    r = recurrence(
      :every  => :week,
      :on     => :saturday,
      :starts => starts,
      :until  => "2009-01-01"
    )
    assert_equal "2008-09-27", r.events[0].to_s
  end

  test "uses except" do
    date = 6.weeks.from_now
    r = recurrence(:every => :week, :on => date.wday, :except => 2.weeks.from_now.to_date)

    assert r.events.include?(1.week.from_now.to_date)
    refute r.events.include?(2.weeks.from_now.to_date)
  end
end
