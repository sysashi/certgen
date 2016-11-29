require "mimemagic"
require "securerandom"

module Upload
  ALLOWED_MIME = %w(image/png image/jpeg)

  def self.handle_request(params, save_path)
    unless params[:image] && params[:image][:filename]
      return {error: "Error uploading an image"}
    end

    ext = File.extname(params[:image][:filename])
    file_name = "#{unique_filename}#{ext}"
    file = params[:image][:tempfile]

    unless check_magic(file)
      return {error: "Invalid file extension"}
    end

    unless save_file_locally(file, file_name, save_path)
      return {error: "Error while saving file"}
    end

    return {ok: [save_path, file_name]}
  end

  # TODO rescue from exception
  def self.save_file_locally(file, file_name, file_path)
    File.open("#{file_path}/#{file_name}", 'wb') do |f|
      f.write(file.read)
    end
  end

  def self.check_magic(image_path)
    mime = MimeMagic.by_magic(File.open(image_path))
    ALLOWED_MIME.include? mime.to_s
  end

  def self.unique_filename
    SecureRandom.urlsafe_base64
  end
end
