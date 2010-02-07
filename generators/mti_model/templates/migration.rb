class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= detail_table_name %>, :id => false do |t|
      t.references :<%= singular_name %>
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
    end
    add_index :<%= detail_table_name %>, :<%= singular_name %>_id
  end

  def self.down
    remove_index :<%= detail_table_name%>, :<%= singular_name %>_id
    drop_table :<%= detail_table_name %>
  end
end
