require "mimemagic"
require "securerandom"

module Upload
  ALLOWED_MIME = %w(image/png image/jpeg)

  def self.handle_request(params, savepath)
    unless params[:image] && params[:image][:filename]
      return {error: "Error uploading an image"}
    end

    ext = File.extname(params[:image][:filename])
    filename = "#{unique_filename}#{ext}"
    file = params[:image][:tempfile]

    unless check_magic(file)
      return {error: "Invalid file extension"}
    end

    unless save_file_locally(file, savepath, filename)
      return {error: "Error while saving file"}
    end

    return {ok: [savepath, filename]}
  end

  # TODO rescue from exception
  def self.save_file_locally(file, filepath, filename)
    File.open("#{filepath}/#{filename}", 'wb') do |f|
      f.write(file.read)
    end
  end

  def self.check_magic(imagepath)
    mime = MimeMagic.by_magic(File.open(imagepath))
    ALLOWED_MIME.include? mime.to_s
  end

  def self.unique_filename
    SecureRandom.urlsafe_base64
  end
end
