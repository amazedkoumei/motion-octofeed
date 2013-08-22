# -*- coding: utf-8 -*-
class MainTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 250
  # FIXME: make CONST
  #CONTENT_FONT = UIFont.systemFontOfSize(14)
  #CONTENT_LINE_BREAK_MODE = NSLineBreakByWordWrapping

  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.systemFontOfSize(14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
  end
  
  def draw(rect)
    if(!@dataSource.nil?)

      # prevent bleeding
      context = UIGraphicsGetCurrentContext()
      self.layer.contentsScale = UIScreen.mainScreen.scale

      # title
      UIColor.blackColor.setFill()
      titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
      titleFont ||= begin
        UIFont.fontWithName("Helvetica", size:14)
      end
      @dataSource[:title].drawInRect(titleRect, withFont:titleFont, lineBreakMode:NSLineBreakByWordWrapping)

      # time
      UIColor.grayColor.setFill()
      timeRect = [[CONTENT_WIDTH, 10], [320 - CONTENT_WIDTH, 10]]
      @timeFont ||= begin
        UIFont.fontWithName("Helvetica", size:12)
      end
      @dataSource[:time].drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

      # icon
      # FIXME: DRY: MainTableViewController.fetchFeed()
      # input > https://secure.gravatar.com/avatar/[:fileName]?s=30&;d=[:original image url]
      /.+?\/avatar\/(.+?)\?.*/ =~ @dataSource[:thumbnail]
      fileName = $1 + ".png"
      fileManager = NSFileManager.defaultManager()
      filePath = "#{App.documents_path}/#{fileName}"
      if fileManager.fileExistsAtPath(filePath)
        if @dataSource[:thumbnailImage].nil?
          @dataSource[:thumbnailImage] = UIImage.imageWithContentsOfFile(filePath)
        end

        img_rect = CGRectMake(0, 0, 30, 30)
        #UIGraphicsBeginImageContext(img_rect.size)
        UIGraphicsBeginImageContextWithOptions(img_rect.size, false, 2.0);
        @dataSource[:thumbnailImage].drawInRect(img_rect)
        @dataSource[:thumbnailImage] = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        @dataSource[:thumbnailImage].drawAtPoint(CGPointMake(10, 30))
      else
        # reason of calling Dispatch::Queue is that other thread is downloading images
        Dispatch::Queue.concurrent.async{
          self.setNeedsDisplay()
        }
      end
    end
  end

end