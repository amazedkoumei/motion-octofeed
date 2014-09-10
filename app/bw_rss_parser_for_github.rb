# -*- coding: utf-8 -*-
=begin
module BubbleWrap
  class RSSParserForGithub < RSSParser

    class RSSItemForGithub < RSSItem
      attr_accessor :id, :published, :updated, :link, :title, :author, :thumbnail, :content

      def initialize
        @id, @published, @updated, @link, @title, @thumbnail, @content = '', '', '', '', '', '', ''
      end

      def to_hash
        {
          :id        => id,
          :published  => published,
          :updated         => updated,
          :link      => link,
          :title         => title,
          :author    => author,
          :thumbnail    => thumbnail,
          :content    => content
        }
      end
    end

    def parser(parser, didStartElement:element, namespaceURI:uri, qualifiedName:name, attributes:attrs)
      if element == 'entry'
        @current_item = RSSItemForGithub.new
      elsif element == 'thumbnail'
        @current_item.thumbnail = attrs["url"]
      elsif !@current_item.nil? && element == 'link'
        @current_item.link = attrs["href"]
      end
      @current_element = element
    end
    
    def parser(parser, didEndElement:element, namespaceURI:uri, qualifiedName:name)
      if element == 'entry'
        @block.call(@current_item) if @block
      else
        @current_element = nil
      end
    end
  end
end
=end