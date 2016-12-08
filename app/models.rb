require "sequel"

module Models
  DB = Sequel::Model.db = Sequel.connect('sqlite://app.db')
  Sequel::Model.strict_param_setting = false

  class Cert < Sequel::Model
    one_to_many :fields

   #   primary_key :id
   #   String :name
   #   String :filename
   #   String :filepath
   #   Integer :width
   #   Integer :height
  end

  class Field < Sequel::Model
    many_to_one :cert

    #   primary_key :id
    #   foreign_key :cert_id, :certs
    #   String :name
    #   String :fontcolor
    #   Integer :fontsize
    #   Integer :x
    #   Integer :y
  end
end

