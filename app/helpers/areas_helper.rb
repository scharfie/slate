module AreasHelper
  def panel_title(version)
    case version.version
    when 1: 'Published'
    when 2: 'One version ago'
    when 3: 'Two versions ago'
    when 4: 'Three versions ago'
    end
  end
  
  def version_timestamp(version)
    stamp = version.published_at
    today = Time.now
    format = if stamp.year == today.year
      ':hour12::minute :lmeridian on :nmonth :day:ordinal'
    else
      ':nmonth :day:ordinal :year'
    end
    
    version.published_at.eztime(format)
  end
end