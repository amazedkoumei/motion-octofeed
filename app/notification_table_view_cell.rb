# -*- coding: utf-8 -*-
class NotificationTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 250

  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.fontWithName("Helvetica", size:14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
    [height, 80].max
  end

  def draw(rect)

    # type
    UIColor.grayColor.setFill()
    type = notificationType(@dataSource[:subject][:url])
    @typeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    typeRect = rect;
    typeSize = UIView.textContetSize(type, width:CONTENT_WIDTH, height:20000, font:@typeFont, lineBreakMode:NSLineBreakByWordWrapping)    
    typeRect = [[320 - typeSize.width - 25, 10], [typeSize.width, 10]]
    "#{type}".drawInRect(typeRect, withFont:@typeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # time
    timeRect = rect;
    timeRect = [[10, 10], [rect.size.width, 10]]
    @timeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    inputFormatter ||=begin
      f = NSDateFormatter.new
      f.setTimeZone(NSTimeZone.timeZoneWithAbbreviation("GMT"))
      f.setDateFormat("YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'")
    end
    outputDateFormatter ||=begin
      f = NSDateFormatter.new
      f.setLocale(NSLocale.systemLocale)
      f.setTimeZone(NSTimeZone.systemTimeZone)
      f.setDateFormat("YYYY-MM-dd")
    end
    outputTimeFormatter ||=begin
      f = NSDateFormatter.new
      f.setLocale(NSLocale.systemLocale)
      f.setTimeZone(NSTimeZone.systemTimeZone)
      f.setDateFormat("HH:mm:ss")
    end
    nsDate = inputFormatter.dateFromString(@dataSource[:updated_at])
    date = outputDateFormatter.stringFromDate(nsDate)
    time = outputTimeFormatter.stringFromDate(nsDate)    
    "#{date} #{time}".drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # title
    UIColor.blackColor.setFill() 
    titleRect = rect
    titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end
    @dataSource[:subject][:title].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # unread mark
    if @dataSource[:unread]
      "#000099".to_color.setFill()
      unreadRect = rect
      unreadRect = [[15, 30], [30, 30]]
      @unreadFont ||= begin
        UIFont.fontWithName("Helvetica", size:18)
      end
      "●".drawInRect(unreadRect, withFont:@unreadFont, lineBreakMode:NSLineBreakByWordWrapping)
    end
    
  end

  # FIXME: it may be better in github_manager.rb
  def notificationType(url)
    url =~ /https?:\/\/.+?\/.+?\/.+?\/.+?\/(.+?)\/.*/
    $1
  end

end