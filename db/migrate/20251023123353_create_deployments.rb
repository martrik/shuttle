class CreateDeployments < ActiveRecord::Migration[8.0]
  def change
    create_table :deployments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :project_id
      t.string :service_id
      t.string :docker_image
      t.string :service_name
      t.string :project_name

      t.timestamps
    end
  end
end
