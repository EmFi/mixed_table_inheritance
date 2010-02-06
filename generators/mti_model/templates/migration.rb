class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= detail_table_name %> do |t|
      t.references :<%= singular_name %>_id
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
