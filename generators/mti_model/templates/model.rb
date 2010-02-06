class <%= class_name %> < <%= parent_class_name %>
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
  mti_subclass
end
