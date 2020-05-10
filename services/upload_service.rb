require "google/apis/drive_v3"

module Services
  class UploadService
    def initialize(file, credentials, content_type=nil)
      @file = file
      @credentials = credentials
      @content_type = content_type
      @drive_service = Google::Apis::DriveV3::DriveService.new
      @drive_service.authorization = credentials
    end

    def upload
      file_data = @file[:tempfile]
      file_metadata = {
        name: @file[:filename]
      }
      content_type = @content_type || @file[:type]

      @drive_service.create_file(
        file_metadata,
        upload_source: file_data,
        fields:        "web_view_link",
        content_type:  content_type
      )
    end
  end
end
