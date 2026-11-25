class AddPlaceDetailsToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :name, :string
    add_column :venues, :formatted_address, :text
    add_column :venues, :price_level, :string
    add_column :venues, :google_maps_uri, :text
    add_column :venues, :rating, :decimal, precision: 2, scale: 1
  end
end
