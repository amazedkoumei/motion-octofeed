# -*- coding: utf-8 -*-
class MainTableViewCellContentView < UIView

  attr_accessor :highlighted, :cell

  def initialize
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
    if(!@cell.nil? && !@cell.feed.nil?)
      UIColor.blackColor.setFill()      
      titleRect = rect
      titleRect.origin.x = 50
      titleRect.origin.y = 30
      titleRect.size.height = 80
      titleRect.size.width = 250;
      @titleFont ||= begin
        UIFont.fontWithName("Helvetica", size:14)
      end
      @cell.feed[:title].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

      UIColor.grayColor.setFill()      
      timeRect = rect;
      timeRect.origin.x = 250
      timeRect.origin.y = 10
      timeRect.size.height = 10
      timeRect.size.width = rect.size.width - 20;
      @timeFont ||= begin
        UIFont.fontWithName("Helvetica", size:12)
      end
      @cell.feed[:time].drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)




      # FIXME: DRY: MainTableViewController.fetchFeed()
      # input > https://secure.gravatar.com/avatar/[:fileName]?s=30&;d=[:original image url]
      /.+?\/avatar\/(.+?)\?s=30.*/ =~ @cell.feed[:thumbnail]
      fileName = $1 + ".png"
      fileManager = NSFileManager.defaultManager()
      filePath = "#{App.documents_path}/#{fileName}"
      if fileManager.fileExistsAtPath(filePath)
        if @cell.feed[:thumbnailImage].nil?
          @cell.feed[:thumbnailImage] = UIImage.imageWithContentsOfFile(filePath)
        end          
        @img_rect = rect;
        @img_rect.origin.x = 0;
        @img_rect.origin.y = 0;
        @img_rect.size.height = 30
        @img_rect.size.width = 30
        UIGraphicsBeginImageContext(@img_rect.size);
        @cell.feed[:thumbnailImage].drawInRect(@img_rect)
        @cell.feed[:thumbnailImage] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        @cell.feed[:thumbnailImage].drawAtPoint(CGPointMake(10, 30))
      else
        # reason of calling Dispatch::Queue is that other thread is downloading images
        Dispatch::Queue.concurrent.async{
          self.setNeedsDisplay()
        }
      end
    end
  end
end