require "deliver/upload_metadata"

module Deliver
  class UploadMetadata
    def review_attachment_file(version)
      app_store_review_detail = begin
                                  version.fetch_app_store_review_detail
                                rescue => error
                                  FastlaneCore::UI.error("Skipping review attachment fetch - #{error.message}")
                                  nil
                                end

      return if app_store_review_detail.nil?

      app_store_review_attachments = app_store_review_detail.app_store_review_attachments || []

      if options[:app_review_attachment_file]
        app_store_review_attachments.each do |app_store_review_attachment|
          FastlaneCore::UI.message("Removing previous review attachment file from App Store Connect")
          app_store_review_attachment.delete!
        end

        FastlaneCore::UI.message("Uploading review attachment file to App Store Connect")
        app_store_review_detail.upload_attachment(path: options[:app_review_attachment_file])
      else
        app_store_review_attachments.each(&:delete!)
        FastlaneCore::UI.message("Removing review attachment file to App Store Connect") unless app_store_review_attachments.empty?
      end
    end
  end
end
