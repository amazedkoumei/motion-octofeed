# -*- coding: utf-8 -*-
class IssueDetailCommentTableViewCellContentView < UIView

  attr_accessor :highlighted, :cell

  def initialize
    super
    
    @highlighted = false
    @cell = nil
  end

  def initWithFrame(frame, withCell:newCell)
    if super
      @cell = newCell;
      self.setBackgroundColor(UIColor.clearColor);
    end
    self;
  end 

  def setHighlighted(newValue)
    @highlighted = newValue;
  end

  def drawRect(rect)
    UIColor.grayColor.setFill()
    commentsRect = rect;
    commentsRect.origin.x = 10
    commentsRect.origin.y = 10
    commentsRect.size.height = 10
    commentsRect.size.width = rect.size.width - 20;
    @commentsFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    "#{@cell.comment[:user][:login]}".drawInRect(commentsRect, withFont:@commentsFont, lineBreakMode:NSLineBreakByWordWrapping)

    timeRect = rect;
    timeRect.origin.x = 190
    timeRect.origin.y = 10
    timeRect.size.height = 10
    timeRect.size.width = rect.size.width - 20;
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
    nsDate = inputFormatter.dateFromString(@cell.comment[:updated_at])
    date = outputDateFormatter.stringFromDate(nsDate)
    time = outputTimeFormatter.stringFromDate(nsDate)    

    "#{date} #{time}".drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    UIColor.blackColor.setFill()      
    titleRect = rect
    titleRect.origin.x = 50
    titleRect.origin.y = 30
    titleRect.size.height = 80
    titleRect.size.width = 250;
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end

    cell_content_width = 250
    cell_content_margin = 0
    text = @cell.comment[:body]
    constraint = CGSizeMake(cell_content_width - (cell_content_margin * 2), 20000);   
    size = text.sizeWithFont(UIFont.systemFontOfSize(14), constrainedToSize:constraint, lineBreakMode:NSLineBreakByWordWrapping)
    height = [size.height, 80].max
    titleRect.size.height = height + (cell_content_margin * 2)

    @cell.comment[:body].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # url > https://secure.gravatar.com/avatar/[:fileName]?d=[:original image url]
    avatar_url = @cell.comment[:user][:avatar_url]

    /.+?\/avatar\/(.+?)\?d=.*/ =~ avatar_url
    fileName = $1 + ".png"
    fileManager = NSFileManager.defaultManager()
    filePath = "#{App.documents_path}/#{fileName}"
    if fileManager.fileExistsAtPath(filePath)
      if @cell.comment[:user][:avatar_image].nil?
        @cell.comment[:user][:avatar_image] = UIImage.imageWithContentsOfFile(filePath)
      end

      @img_rect = rect;
      @img_rect.origin.x = 0;
      @img_rect.origin.y = 0;
      @img_rect.size.height = 30
      @img_rect.size.width = 30

      UIGraphicsBeginImageContext(@img_rect.size);
      @cell.comment[:user][:avatar_image].drawInRect(@img_rect)
      @cell.comment[:user][:avatar_image] = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      @cell.comment[:user][:avatar_image].drawAtPoint(CGPointMake(10, 35))
    else
      Dispatch::Queue.concurrent.async{
        thumbnailData = NSData.dataWithContentsOfURL(NSURL.URLWithString("#{avatar_url}&s=30"))
        thumbnailData.writeToFile(filePath, atomically:false)
        self.setNeedsDisplay()
      }
    end
  end
end