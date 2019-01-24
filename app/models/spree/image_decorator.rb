Spree::Image.class_eval do
  if ENV["LEGACY_PAPERCLIP_ATTACHMENT"]
    has_attached_file :legacy_attachment,
                      self.attachment_definitions[:attachment]

    self.attachment_definitions[:legacy_attachment][:keep_old_files] = true

    cols = Spree::Image.columns.map(&:name)

    [:attachment_file_name, :attachment_width,
      :attachment_file_size, :attachment_content_type,
      :attachment_updated_at, :attachment_fingerprint
    ].each do |mth|
      unless cols.include?("legacy_#{mth}")
        define_method "legacy_#{mth}" do
          attributes[mth.to_s]
        end
      end
    end
  end

  def self.mount_custom_uploader(uploader)
    self.mount_uploader :attachment, uploader, :mount_on => :attachment_file_name
  end

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