# -*- coding: utf-8 -*-
class IssueTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

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
    titleRect = [[50, 30], [250, 80]]
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end
    @dataSource[:title].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # url > https://secure.gravatar.com/avatar/[:fileName]?d=[:original image url]
    avatar_url = @dataSource[:user][:avatar_url]

    /.+?\/avatar\/(.+?)\?d=.*/ =~ avatar_url
    fileName = $1 + ".png"
    fileManager = NSFileManager.defaultManager()
    filePath = "#{App.documents_path}/#{fileName}"
    if fileManager.fileExistsAtPath(filePath)
      if @dataSource[:user][:avatar_image].nil?
        @dataSource[:user][:avatar_image] = UIImage.imageWithContentsOfFile(filePath)
      end

      @img_rect = rect
      
      # FIXME: error: reason is @img_rect.size->2 why??
      #@img_rect = [[0, 0], [30, 30]]
      
      # x, y set at drawAtPoint
      @img_rect.origin.x = 0
      @img_rect.origin.y = 0
      @img_rect.size.height = 30
      @img_rect.size.width = 30

      UIGraphicsBeginImageContext(@img_rect.size);
      @dataSource[:user][:avatar_image].drawInRect(@img_rect)
      @dataSource[:user][:avatar_image] = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      @dataSource[:user][:avatar_image].drawAtPoint(CGPointMake(10, 35))
    else
      Dispatch::Queue.concurrent.async{
        thumbnailData = NSData.dataWithContentsOfURL(NSURL.URLWithString("#{avatar_url}&s=30"))
        thumbnailData.writeToFile(filePath, atomically:false)
        self.setNeedsDisplay()
      }
    end
  end
end