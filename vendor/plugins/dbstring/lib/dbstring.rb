# :main: Slate::DBString
module Slate # :nodoc:
  # = DBString
  # 
  # DBString provides query-building functions for a dealing
  # with strings and dates in databases.
  # 
  # == Motivation
  # 
  # In my development, I use SQL Server for production and SQLite3
  # for testing and development.  I needed to hand-code some queries
  # that required substring and date part extraction, so I wrote 
  # DBString. 
  # 
  # == Usage
  # 
  # The DBString functions are included into ActiveRecord's AbstractAdapter,
  # which means they are available to all database adapters (since all 
  # adapters are subclassed from the AbstractAdapter).  The methods are 
  # invoked using <tt>connection.<i>function_name</i></tt>.
  # 
  # == Examples
  # 
  # Assume the following:
  # * SQLite3 database with table +users+
  # * +users+ table has the following rows: 
  #   
  #    name        | middle | last   | created_at
  #    ------------+--------+--------+----------------------
  #    Christopher | B      | Scharf | 2007-09-07 18:45:00
  #    David       | M      | Olsen  | 1997-04-25 18:45:00
  #    ------------+--------+--------+----------------------
  # 
  #   
  #  class User < ActiveRecord::Base
  #    def self.find_users_created_in(y=2007)
  #      find(:all, :conditions => 
  #        "#{connection.year('created_at')} = #{y}"
  #      )
  #    end
  #  
  #    def self.find_usernames
  #      find(:all, :select => 
  #        "#{connection.concat(connection.substring('name', 1, 1), 'middle', 'last')} AS username"
  #      )
  #    end
  #  end
  #  
  #  User.find_users_created_this_year.map(&:last) # => ['Scharf']
  #  User.find_usernames.map(&:username) # => ['CBScharf', 'DMOlsen']
  # 
  # For more examples, please refer to <tt>test/dbstring_test.rb</tt>.
  # 
  # == Credits
  # 
  # <tt>dbstring</tt> was created by Chris Scharf (http://tiny.scharfie.com)
  module DBString
    def adapter_class # :nodoc:
      self.class.to_s  
    end
    
    # builds query for extracting a substring of 
    # given column
    # 
    # Parameters:
    # * +column+ - name of column
    # * +start+  - starting position for substring
    # * +length+ - number of characters to extract
    # 
    # *Example*:
    #   substring(name, 1, 5) # => SUBSTR(name, 1, 5)
    #     result: "Chris"
    def substring(column, start, length = nil)
      case adapter_class
        when /SQLite/:           "SUBSTR(#{column}, #{start}, #{length})"
        when /SQLServer|Mysql/:  "SUBSTRING(#{column}, #{start}, #{length})" 
        when /PostgreSQL/:       "SUBSTRING(#{column} FROM #{start} FOR #{length})" 
        else raise NotImplementedError, "substring is not implemented in #{self.class}"
      end
    end

    # builds query for joining the given columns
    # 
    # *Example*:
    #   concat(name, ' ', last) #=> "name || ' ' || last"
    #     result: "Christopher Scharf"
    #
    #   concat(substring(name, 1, 5), last) # => "SUBSTR(name, 1, 5) || last"
    #     result: "ChrisScharf"
    def concat(*args)
      case adapter_class
        when /SQLite|Oracle|PostgreSQL/:  args.join(' || ')
        when /SQLServer/:                 args.join(' + ')
        when /Mysql/:                     "CONCAT(" + args.join(',') + ")"
        else raise NotImplementedError, "concat is not implemented in #{self.class}"
      end
    end
  
    # builds query for extracting year from given column
    # 
    # *Example*:
    #   year(created_at) # => 'CAST(strftime('%Y', created_at) AS INTEGER)""
    #     result: 2007
    def year(column)
      case adapter_class
        when /SQLite/:            "CAST(strftime('%Y', #{column}) AS INTEGER)"
        when /SQLServer|Mysql/:   "YEAR(#{column})"
        when /PostgreSQL/:        "DATE_PART('YEAR', #{column})"
        else raise NotImplementedError, "year is not implemented in #{self.class}"              
      end  
    end

    # builds query for extracting month from given column
    # 
    # *Example*:
    #   year(created_at) # => "CAST(strftime('%m', created_at) AS INTEGER)"
    #     result: 9
    def month(column)
      case adapter_class
        when /SQLite/:            "CAST(strftime('%m', #{column}) AS INTEGER)"
        when /SQLServer|Mysql/:   "MONTH(#{column})"
        when /PostgreSQL/:        "DATE_PART('MONTH', #{column})"  
        else raise NotImplementedError, "year is not implemented in #{self.class}"              
      end  
    end
  
    # builds query for extracting day from given column
    # 
    # *Example*:
    #   year(created_at) # => "CAST(strftime('%d', created_at) AS INTEGER)"
    #     result: 7
    def day(column)
      case adapter_class
        when /SQLite/:          "CAST(strftime('%d', #{column}) AS INTEGER)"
        when /SQLServer|Mysql/: "DAY(#{column})"
        when /PostgreSQL/:      "DATE_PART('DAY', #{column})"
        else raise NotImplementedError, "year is not implemented in #{self.class}"              
      end  
    end  
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Slate::DBString