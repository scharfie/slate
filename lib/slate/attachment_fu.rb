module Slate
  module AttachmentFu
    mattr_accessor :asset_root
    self.asset_root = Rails.public_path
    
    def self.included(base)
      base.send :include, Common
      base.send :include, ImageScience if Slate.config.assets.processor == 'ImageScience'
    end

    module Common
      # hack to make file paths like this:
      # [base]/[site id]/[partitioned id]/[filename]
      # e.g.: [asset root]/public/assets/51/0000/0047/turkey_small.jpg
      def full_filename(thumbnail = nil)
        thumbnail = nil unless has_thumbnail?(thumbnail)
        file_system_path = "assets/#{self.space_id}"
        File.join(Slate::AttachmentFu.asset_root, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
      end
            
      # patched to avoid re-creation of thumbnails (?)
      def temp_paths
        @temp_paths ||= (new_record? || File.exist?(full_filename)) ? [] : [copy_to_temp_file(full_filename)]
      end    
  
      # returns a modified hash of all possible thumbnails
      # for the given image - thumbnail sizes with geometry
      # greater than the source image are ignored
      def attachment_thumbnails
        return nil if !image?
        dimensions = [self.width, self.height]
        attachment_options[:thumbnails].inject({}) do |sizes, thumbnail|
          name, geometry = *thumbnail
          new_size = geometry.is_a?(Fixnum) ? geometry : dimensions / geometry.to_s
          need_thumbnail?(new_size) ? sizes.update(name => new_size) : sizes
        end
      end
  
      # hacked to use custom attachment_thumbnails instead of attachment_options[:thumbnails]
      # Cleans up after processing.  Thumbnails are created, the attachment is stored to the backend, and the temp_paths are cleared.
      def after_process_attachment
        if @saved_attachment
          if respond_to?(:process_attachment_with_processing) && thumbnailable? && parent_id.nil? && !attachment_thumbnails.blank?
            temp_file = temp_path || create_temp_file
            attachment_thumbnails.each do |suffix, size| 
              create_or_update_thumbnail(temp_file, suffix, *size)
            end  
          end
          save_to_storage
          @temp_paths.clear
          @saved_attachment = nil
          callback :after_attachment_saved
        end
      end
  
      # returns true if a thumbnail is needed for the given size
      def need_thumbnail?(size)
        return false if !image?
        if size.is_a?(Fixnum)
          size = [size] * 2 
          size[0] < self.width || size[1] < self.height
        else  
          size[0] < self.width && size[1] < self.height
        end
      end
    
      # returns true if the asset is an image
      def image?
        content_type =~ /^image/ ? true : false
      end
    
      # returns true if the asset is a zip file
      def zip?
        content_type == 'application/zip'
      end
  
      # returns true if the given thumbnail
      # should exist
      def has_thumbnail?(thumbnail)
        return nil if !image?
        thumbnail ? attachment_thumbnails.keys.include?(thumbnail.to_s) : true
      end
    end  

    # Patches specifically for ImageScience processor
    module ImageScience
      # patched to support ImageScience thumbnails
      def thumbnail_name_for(thumbnail = nil)
        return filename if thumbnail.blank?
        ext = nil
        basename = filename.gsub /\.\w+$/ do |s|
          ext = s; ''
        end
        # ImageScience doesn't create gif thumbnails, only pngs
        ext.sub!(/gif$/, 'png') if attachment_options[:processor] == :image_science
        "#{basename}_#{thumbnail}#{ext}"
      end    

      # hacked to support cropped thumbnails with ImageScience
      # Performs the actual resizing operation for a thumbnail
      def resize_image(img, size)
        # create a dummy temp file to write to
        filename.sub! /gif$/, 'png'
        content_type.sub!(/gif$/, 'png')
        self.temp_path = write_to_temp_file(filename)
        grab_dimensions = lambda do |img|
          self.width  = img.width  if respond_to?(:width)
          self.height = img.height if respond_to?(:height)
          img.save temp_path
          callback_with_args :after_resize, img
        end

        size = size.first if size.is_a?(Array) && size.length == 1
        if size.is_a?(Fixnum)
          img.cropped_thumbnail(size, &grab_dimensions)
        else
          img.resize(size[0], size[1], &grab_dimensions)
        end
      end
    end
  end
end