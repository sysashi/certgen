require "fastimage"
require "prawn"
require_relative "models"
require_relative "../app"

module Actions
  module Cert
    def self.new(filepath, filename, name = false)
      unless name
        name = filename
      end
      width, height = FastImage.size("#{filepath}/#{filename}")
      cert = Models::Cert.new(
        :name => name,
        :filename => filename,
        :filepath => filepath,
        :width => width,
        :height => height
      )
      if cert.save
        cert.pk
      end
    end

    def self.generate(cert, params)
      roboto = "#{App.settings.root}/app/assets/fonts/roboto/Roboto-Regular.ttf"
      file = "#{cert.filepath}/#{cert.filename}"
      pdf = Prawn::Document.new(
        :page_layout => :landscape,
        :page_size => [cert.height, cert.width],
        :margin => [0, 0, 0, 0]) do
        font roboto
        image file
        cert.fields.each do |field|
          spk = field.pk.to_s
          if params[spk] != ""
            fill_color field.fontcolor
            draw_text params[spk],
                      :at => [field.x, cert.height - field.y],
                      :size => field.fontsize,
                      :color => field.fontcolor
          end
        end
      end
      pdf.render
    end
  end
end
