# -*- coding: utf-8 -*-
class IssueTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 250
  
  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.fontWithName("Helvetica", size:14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
    [height, 80].max
  end

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 30], [30, 30]]
  end

  def draw(rect)
    UIColor.grayColor.setFill()
    commentsRect = rect;
    commentsRect = [[230, 10], [rect.size.width, 10]]
    @commentsFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    "#{@dataSource[:comments]} comments".drawInRect(commentsRect, withFont:@commentsFont, lineBreakMode:NSLineBreakByWordWrapping)

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
    "##{@dataSource[:number]} - #{date} #{time}".drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    UIColor.blackColor.setFill()      
    titleRect = rect
    titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end
    @dataSource[:title].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:user][:avatar_url]), placeholderImage:nil)
  end
end