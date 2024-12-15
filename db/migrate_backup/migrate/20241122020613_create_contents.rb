class CreateContents < ActiveRecord::Migration[7.2]
  def change
    create_table :contents do |t|
      t.text :story_text
      t.string :image_url

      t.timestamps
    end
  end
end
