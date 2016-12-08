require "sequel"

Sequel.migration do
  change do
    create_table(:certs) do
      primary_key :id
      String :name
      String :filename, :null => false
      String :filepath, :null => false
      Integer :width, :null => false
      Integer :height, :null => false
    end

    create_table(:fields) do
      primary_key :id
      foreign_key :cert_id, :certs
      String :name, :null => false
      String :fontcolor, :null => false, :default => "000000"
      # TODO Add font style constraint
      String :fontstyle, :default => "normal" 
      Integer :fontsize, :null => false
      Integer :x, :null => false
      Integer :y, :null => false
    end
  end
end
