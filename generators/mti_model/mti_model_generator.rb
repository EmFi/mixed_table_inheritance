class MtiModelGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false, :skip_fixture => false

  attr_reader :parent_class_path, :parent_file_path, :parent_class_nesting,
    :parent_class_nesting_depth, :parent_class_name_without_nesting, 
    :parent_singular_name, :parent_plural_name, :parent_table_name, 
    :parent_class_name,:parent_name
  attr_reader :detail_class_path, :detail_file_path, :detail_class_nesting,
    :detail_class_nesting_depth, :detail_class_name_without_nesting, 
    :detail_singular_name, :detail_plural_name, :detail_table_name, 
    :detail_class_name,:detail_name

  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
    @parent_name = @args.shift
parent_base_name, @parent_class_path, @parent_file_path, @parent_class_nesting, @parent_class_nesting_depth = extract_modules(@parent_name)
          @parent_class_name_without_nesting, @parent_singular_name, @parent_plural_name = inflect_names(parent_base_name)
          @parent_table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? parent_plural_name : parent_singular_name
          if @parent_class_nesting.empty?
            @parent_class_name = @parent_class_name_without_nesting
          else
            @parent_table_name = @parent_class_nesting.underscore << "_" << @parent_table_name
            @parent_class_name = "#{@parent_class_nesting}::#{@parent_class_name_without_nesting}"
          end
          @parent_table_name.gsub! '/', '_'

@detail_name = "#{@name}Detail"
detail_base_name, @detail_class_path, @detail_file_path, @detail_class_nesting, @detail_class_nesting_depth = extract_modules(@detail_name)
          @detail_class_name_without_nesting, @detail_singular_name, @detail_plural_name = inflect_names(detail_base_name)
          @detail_table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? detail_plural_name : detail_singular_name
          if @detail_class_nesting.empty?
            @detail_class_name = @detail_class_name_without_nesting
          else
            @detail_table_name = @detail_class_nesting.underscore << "_" << @detail_table_name
            @detail_class_name = "#{@detail_class_nesting}::#{@detail_class_name_without_nesting}"
          end
          @detail_table_name.gsub! '/', '_'


  end

  def manifest
    record do |m|

 # Check for class naming collisions.
      m.class_collisions class_name, "#{class_name}Test"

# Model, test, and fixture directories.
 m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)


  # Model class, unit test, and fixtures.

      m.template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'model_detail.rb', File.join('app/models', detail_class_path, "#{file_name}_detail.rb")
      m.template 'unit_test.rb', File.join('test/unit', class_path, "#{file_name}_test.rb")

      unless options[:skip_fixture] 
        m.template 'fixtures.yml',  File.join('test/fixtures', "#{table_name}.yml")
      end

      migration_file_path = "mti_" + file_path.gsub(/\//, '_')
      migration_name = "Mti" + class_name
      if ActiveRecord::Base.pluralize_table_names
        migration_name = migration_name.pluralize
        migration_file_path = migration_file_path.pluralize
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{migration_name.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{migration_file_path}"
      end


    end
  end


   protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName ParentModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--skip-fixture",
             "Don't generation a fixture file for this model") { |v| options[:skip_fixture] = v}
    end

end

