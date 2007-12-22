require 'test/unit'
require File.dirname(__FILE__) + '/../lib/eztime'
require File.dirname(__FILE__) + '/../lib/eztime'

class EZTimeTest < Test::Unit::TestCase
  def setup
    # 20 December 2003 @ 5:45:23 PM
    @stamp = DateTime.civil(2003, 12, 20, 17, 45, 23)
    
    # 1 Jan 2004 4:30:00 PM
    @ny = DateTime.civil(2004, 1, 1, 16, 30, 0) 
  end
  
  def test_constant
    assert_equal 'pizza time', @stamp.eztime('pizza time')
    assert_equal 'pizza : time', @stamp.eztime('pizza : time')
    assert_equal 'pizza :::: time', @stamp.eztime('pizza :::: time')
  end
  
  def test_month_day_year
    assert_equal '12/20/2003', @stamp.eztime(':month/:day/:year')
    assert_equal '2003-12-20', @stamp.eztime(':year-:month-:day')
    assert_equal '12-03',      @stamp.eztime(':month-:syear')
    
    assert_equal '1/1/2004',   @ny.eztime(':month/:day/:year')
    assert_equal '01/01/2004', @ny.eztime(':zmonth/:zday/:year')
  end
  
  def test_named_months_and_days  
    assert_equal 'December 20, 2003', @stamp.eztime(':month_name :day, :year')
    assert_equal '20 December 03', @stamp.eztime(':day :month_name :syear')
    
    assert_equal 'Dec 20, 2003', @stamp.eztime(':month_abbr :day, :year')
    assert_equal '20 Dec 03', @stamp.eztime(':day :month_abbr :syear')    
    
    1.upto(12) do |month|
      assert_equal Date::MONTHNAMES[month], Date.civil(2003, month, 1).eztime(':month_name')
      assert_equal Date::ABBR_MONTHNAMES[month], Date.civil(2003, month, 1).eztime(':month_abbr')
    end
    
    0.upto(6) do |wday|
      d = Date.civil(2006, 8, 6 + wday)
      assert_equal wday, d.wday
      assert_equal Date::DAYNAMES[wday], d.eztime(':day_name')
      assert_equal Date::ABBR_DAYNAMES[wday], d.eztime(':day_abbr')
    end
  end
  
  def test_hour_minute_second_meridian
    assert_equal '17:45:23 pm', @stamp.eztime(':hour::minute::second :lmeridian')
    assert_equal '17:45:23 PM', @stamp.eztime(':hour::minute::second :meridian')
    assert_equal '17:45:23 P',  @stamp.eztime(':hour::minute::second :smeridian')
    assert_equal '17:45:23 p',  @stamp.eztime(':hour::minute::second :lsmeridian')
    
    # now test am/AM/A/a
    @stamp2 = DateTime.civil(2003, 12, 12, 5, 45, 23)
    assert_equal '5:45:23 am', @stamp2.eztime(':hour::minute::second :lmeridian')
    assert_equal '5:45:23 AM', @stamp2.eztime(':hour::minute::second :meridian')
    assert_equal '5:45:23 A',  @stamp2.eztime(':hour::minute::second :smeridian')
    assert_equal '5:45:23 a',  @stamp2.eztime(':hour::minute::second :lsmeridian')    
  end
  
  def test_everything
    d = DateTime.civil(2000, 1, 1, 0, 0, 0)
    0.upto(1440/5) do |min|
      d += 300 if min > 0
      assert_equal d.strftime('%I:%M'), d.eztime(':hour12::minute') 
    end  

    1.upto(31) do |day|
      d = DateTime.civil(2000, 1, day, 0, 0, 0)
      assert_equal d.strftime('%m/%d/%Y %A'), d.eztime(':zmonth/:zday/:year :nday')
    end
  end
  
  def test_all
    assert_equal '05:45 PM on December 20th, 2003 (Saturday)', 
      @stamp.eztime(':zhour12::minute :meridian on :month_name :day:ord, :year (:day_name)')
      
    assert_equal '20 December 03 was a Saturday.',
      @stamp.eztime(':day :nmonth :syear was a :nday.')  
  end
  
  def test_hours
    0.upto(24) do |hour|
      hour12 = hour
      d = DateTime.civil(2000, 1, 1, hour, 0, 0)
      meridian = d.hour >= 12 ? 'pm' : 'am'
      hour12, meridian = 12, 'am' if d.hour == 0
      hour12 -=12 if hour12 > 12
      
      expected = "#{hour12} #{d.hour} #{meridian}"
      assert_equal expected, d.eztime(':hour12 :hour :lmeridian')
    end
  end
  
  def test_ordinals
    assert_equal 'st', @ny.ord
    assert_equal 'January 1st', @ny.eztime(':month_name :day:ord')
    
    ordinals = %w{
      th st nd rd th th th th th th 
      th th th th th th th th th th
      th st nd rd th th th th th th 
      th st nd rd th th th th th th       
    }
    
    1.upto(31) do |mday|
      d = Date.civil(2006, 1, mday)
      assert_equal ordinals[mday], d.eztime(':ord'), "Failed on " + d.to_s
    end
  end
end