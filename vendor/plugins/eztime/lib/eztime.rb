require 'date'

# The following code was based on work found at:
# http://www.bigbold.com/snippets/user/jswizard#post2368
class Numeric
  # Returns the cardinal (number) and ordinal (st, nd, rd, th, etc.)
  # Pass include_cardinal as false to only return the ordinal
  def ordinal(include_cardinal=true)
    cardinal = self.to_i.abs
    if (10...20).include?(cardinal) then
      include_cardinal ? cardinal.to_s << 'th' : 'th'
    else
      ord = %w{th st nd rd th th th th th th}[cardinal % 10]
      include_cardinal ? cardinal.to_s << ord : ord
    end
  end
end

module EZTime
  public
  # Returns only the lower two digits of the year
  # (i.e. 2006 => 06)
  def syear; year.to_s[-2..-1]; end
  
  # Returns the name of the month 
  # (January, February, etc.)
  def month_name; Date::MONTHNAMES[month]; end
  
  # Returns the abbreviated name of the month 
  # (Jan, Feb, etc.)
  def month_abbr; Date::ABBR_MONTHNAMES[month]; end
  
  # Returns the name of the weekday
  # (Sunday, Monday, etc.)
  def day_name; Date::DAYNAMES[wday]; end
  
  # Returns the abbreviated name of the weekday
  # (Sun, Mon, etc.)
  def day_abbr; Date::ABBR_DAYNAMES[wday]; end
  
  alias :nmonth :month_name
  alias :amonth :month_abbr
  
  alias :nday   :day_name
  alias :aday   :day_abbr

  # Returns the month as a zero-padded string
  # (i.e. June => 06)  
  def zmonth; '%02d' % month; end
  
  # Returns the day as a zero-padded string
  # (5 => 05)
  def zday;   '%02d' % mday;  end
  
  # Returns the hour as a zero-padded string
  # (3 => 03)
  def zhour;  '%02d' % hour; end
  
  # Returns the hour in 12-hour format
  # (5:00pm => 5)
  def hour12;  hour % 12 == 0 ? 12 : hour % 12; end
  
  # Returns the hour in 12-hour format as a zero-padded string
  # (5:00pm => 05)
  def zhour12; '%02d' % hour12; end
  
  # Returns the minute as a zero-padded string 
  # Note: If you need just the minute, use min
  def minute;  '%02d' % min; end
  
  # Returns the second as a zero-padded string
  # Note: If you need just the second, use sec
  def second;  '%02d' % sec; end
  
  # Returns the meridian 
  # (AM/PM)
  def meridian;   hour >= 12 ? 'PM' : 'AM'; end
  
  # Returns the meridian in short form (first letter)
  # (A/P)
  def smeridian;  meridian[0].chr; end
  
  # Returns the meridian in lowercase
  # (am/pm)
  def lmeridian;  meridian.downcase; end
  
  # Returns the meridian in lowercase, short form (first letter)
  # (a/p)
  def lsmeridian; smeridian.downcase; end
  
  # Returns the ordinal of the day
  # (1 => st, 2 => nd, 3 => rd, 4.. => th)
  def ordinal; mday.ordinal(false); end
  alias :ord :ordinal
  
  # Formats the date/time according to the formatting string format_str
  # The formatting string consists of any of the methods defined in EZTime
  # (such as meridian, ordinal, zhour, etc.) as well as any other methods 
  # available to the object class.  The methods are named in the string by
  # preceeded them with a single colon (:).  Any characters not preceeded by
  # a colon will be passed through directly.
  #
  # Example
  #
  #   d = DateTime.civil(2003, 12, 20, 17, 30, 0) 
  #   puts d.eztime(":day :nmonth :year at :hour12::minute::second :lmeridian")
  #
  #   Output: 20 December 2003 at 5:30:00 pm
  def eztime(format_str)
    eval("'" + format_str.gsub(/:([a-z_]{1,}[0-9]{0,2})/, '\' + \1.to_s + \'') + "'")
  end
end  

# Include the EZTime module into the Time class
class Time; include EZTime; end

# Include the EZTime module into the Date class
class Date; include EZTime; end

# class DateTime
#   include EZTime
#   def ordinal; mday.ordinal(false); end
#   def self.ordinal; mday.ordinal(false); end
# end