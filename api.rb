require "sinatra"
require "googleauth"
require "googleauth/stores/file_token_store"
require "google/apis/drive_v3"
require "json"
require "mimemagic"

require "./services/upload_service"

SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

# In order to not have to deal with using the callback-based oauth used by Google for
# Web apps, this app should be registered as "Other".
# Since it is not a "web app" the base URI has to be this string.
OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze

configure do
  # Client secrets and a token store.
  set :client_id, Google::Auth::ClientId.from_file("credentials.json")
  set :token_store, Google::Auth::Stores::FileTokenStore.new(file: "tokens.yml")
  set :authorizer, Google::Auth::UserAuthorizer.new(settings.client_id,
                                                    SCOPE,
                                                    settings.token_store)
end

get "/" do
  redirect settings.authorizer.get_authorization_url(base_url: OOB_URI)
end

post "/upload" do
  code = params[:code]
  file = params[:file]
  # Since the credentials are never actually stored, the user_id can be anything.
  user_id = "user"
  base_url = OOB_URI

  file_type = MimeMagic.by_magic(file[:tempfile]).to_s

  if code.nil? || code == "" || file.nil? || !file_type != "image/png"
    return 422
  end

  credentials = settings.authorizer.get_credentials_from_code(
    user_id:  user_id,
    code:     code,
    base_url: base_url
  )

  drive_file = Services::UploadService.new(file, credentials, file_type).upload
  content_type :json
  return {file_link: drive_file.web_view_link}.to_json
end
