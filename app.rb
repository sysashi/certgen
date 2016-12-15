require "sinatra/base"
require "prawn"
require "uri"
require_relative "app/upload"
require_relative "app/actions"
require_relative "app/models"


class App < Sinatra::Base
  SAVE_PATH = settings.root + "/public/uploads"

  set :views, settings.root + '/app/views'
  set :server, "thin"

  get "/"  do
    erb :index
  end

  get "/cert/:id/edit" do
    @cert = Models::Cert[params[:id]]
    erb :editor
  end

  get "/cert/:id/generate" do
    content_type "application/pdf"
    cert = Models::Cert[params[:id]]
    Actions::Cert.generate(cert, params)
  end

  get "/cert/:id/field-options" do
    @cert = Models::Cert[params[:id]]
    erb :field_options, :layout => false
  end

  post "/cert/:id/field" do
    content_type :json
    cert = Models::Cert[params[:id]]
    field = cert.add_field(Models::Field.new(params))
    {:success => true, :id => field.id}.to_json
  end

  put "/cert/:id/field/:field_id" do
    field = Models::Field[params[:field_id]]
    field.update(params)
    {:success => true}.to_json
  end

  delete "/cert/:id/field/:field_id" do
    field = Models::Field[params[:field_id]]
    field.delete
    {:success => true}.to_json
  end

  # TODO allow custom name
  post "/cert/upload" do
    content_type :json
    upload_result = Upload.handle_request(params, SAVE_PATH)
    puts "Upload results"
    puts upload_result
    if upload_result.has_key? :error
      upload_result.to_json
    else
      filepath, filename = upload_result[:ok]
      id = Actions::Cert.new(filepath, filename)
      redirect to("/cert/#{id}/edit")
    end
  end


  helpers do
    def cert_img(cert)
      "<img id='cert-img'\
        src='/uploads/#{cert.filename}' \
        data-width = '#{cert.width}' \
        data-height = '#{cert.height}' \
        alt='#{cert.name}' />"
    end
    def default_field
      Models::Field.new(
        :name => "Default",
        :fontsize => 64,
        :fontcolor => "000000",
        :x => 0,
        :y => 0
      )
    end
    def base_url(user_path = "")
      proto = request.env["HTTP_X_FORWARDED_PROTO"] || request.env["rack.url_scheme"]
      host = "#{proto}://#{request.env['HTTP_HOST']}"
      URI::join(host, user_path)
    end
  end
end
