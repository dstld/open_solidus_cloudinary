require 'dbg_image_uploader'

Spree::Image.class_eval do
  if true || ENV["LEGACY_PAPERCLIP_ATTACHMENT"]
    has_attached_file :legacy_attachment,
                      self.attachment_definitions[:attachment]

    self.attachment_definitions[:legacy_attachment] = self.attachment_definitions[:attachment]

    [:attachment_file_name, :attachment_width,
      :attachment_file_size, :attachment_content_type,
      :attachment_updated_at, :attachment_fingerprint
    ].each do |mth|
      define_method "legacy_#{mth}" do
        attributes[mth.to_s]
      end
    end
  end

  mount_uploader :attachment, DbgImageUploader, :mount_on => :attachment_file_name

  # Get rid of the paperclip callbacks
  # def save_attached_files; end
  # def prepare_for_destroy; end
  # def destroy_attached_files; end

  # For solidus front end compatibility
  def attachment(version=nil)
    if version.nil?
      super()
    else
      super().url(version)
    end
  end


  # i.attachment=open(i.legacy_attachment.url)
  # Get rid of Paperclip validation
  # def attachment_file_name
  #   "not_blank"
  # end
end
