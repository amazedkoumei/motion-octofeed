# -*- coding: utf-8 -*-
class IssueDetailCommentTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 35], [30, 30]]
  end

  def content_width
    self.frame.size.width - 70
  end

  def draw(rect)
    UIColor.grayColor.setFill()
    commentsRect = rect;
    commentsRect = [[10, 10], [rect.size.width, 10]]
    @commentsFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    "#{@dataSource[:user][:login]}".drawInRect(commentsRect, withFont:@commentsFont, lineBreakMode:NSLineBreakByWordWrapping)

    timeRect = rect;
    timeRect = [[content_width - 60, 10], [rect.size.width, 10]]
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

    UIColor.blackColor.setFill()      
    titleRect = rect
    # FIXME: error: reason is @img_rect.size->2 why??
    #titleRect = [[50, 30], 250, 80]

    titleRect.origin.x = 50
    titleRect.origin.y = 30
    titleRect.size.height = 80
    titleRect.size.width = content_width
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end

    # adjust cell height
    cell_content_width = content_width
    cell_content_margin = 0
    text = @dataSource[:body]
    constraint = CGSizeMake(cell_content_width - (cell_content_margin * 2), 20000);   
    size = text.sizeWithFont(UIFont.systemFontOfSize(14), constrainedToSize:constraint, lineBreakMode:NSLineBreakByWordWrapping)
    height = [size.height, 80].max
    titleRect.size.height = height + (cell_content_margin * 2)

    @dataSource[:body].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # icon
    avatar_url = @dataSource[:user][:avatar_url]
    self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:user][:avatar_url]), placeholderImage:nil)
  end
end