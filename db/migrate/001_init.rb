class Init < ActiveRecord::Migration
  def self.up
    create_table "tweets" do |t|
      t.string    "text"
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
