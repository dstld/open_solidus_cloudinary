Spree::Image.extend(CloudinaryImageClassMethods = Module.new do
  def mount_custom_uploader(uploader)
    mount_uploader :attachment, uploader, mount_on: :attachment_file_name
  end
end)

Spree::Image.prepend(CloudinaryImageDecorator = Module.new do
  def self.prepended(base)
    Spree::Image._validators.reject! { |k,_| k == :attachment }
    Spree::Image._validate_callbacks.select { |cb| cb.raw_filter.class.to_s.include?("Paperclip") }
      .each { |cb| cb.filter.attributes.delete(:attachment) }


    if ENV["LEGACY_PAPERCLIP_ATTACHMENT"]
      base.has_attached_file :legacy_attachment,
                        base.attachment_definitions[:attachment]

      base.attachment_definitions[:legacy_attachment][:keep_old_files] = true

      cols = Spree::Image.columns.map(&:name)

      [:attachment_file_name, :attachment_width,
        :attachment_file_size, :attachment_content_type,
        :attachment_updated_at, :attachment_fingerprint
      ].each do |mth|
        unless cols.include?("legacy_#{mth}")
          base.send :define_method, "legacy_#{mth}" do
            attributes[mth.to_s]
          end
        end
      end
    end
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
end)
