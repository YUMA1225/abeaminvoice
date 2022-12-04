require 'rails_admin/config/fields/types/file_upload'

module RailsAdmin
  module Config
    module Fields
      module Types
        class ActiveStorage < RailsAdmin::Config::Fields::Types::FileUpload
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :thumb_method do
            if ::ActiveStorage::VERSION::MAJOR >= 6
              {resize_to_limit: [100, 100]}
            else
              {resize: '100x100>'}
            end
          end

          register_instance_option :delete_method do
            "remove_#{name}" if bindings[:object].respond_to?("remove_#{name}")
          end

          register_instance_option :image? do
            if value
              value.filename.to_s.split('.').last =~ /jpg|jpeg|png|gif|svg/i
            end
          end

          def resource_url(thumb = false)
            return nil unless value
            if thumb && value.variable?
              thumb = thumb_method if thumb == true
              variant = value.variant(thumb)
              Rails.application.routes.url_helpers.rails_blob_representation_path(
                variant.blob.signed_id, variant.variation.key, variant.blob.filename, only_path: true
              )
            else
              Rails.application.routes.url_helpers.rails_blob_path(value, only_path: true)
            end
          end

          def value
            attachment = super
            attachment if attachment && attachment.attached?
          end
        end
      end
    end
  end
end
