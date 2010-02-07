# Mti
module MTI
  module ActiveRecord
    module Base
    def self.included(base) # :nodoc:
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      def mti_subclass options = {}
        self.send(:include, MTI::ActiveRecord::Base::InstanceMethods)
        class_name = options[:class_name] || "#{self.name}Detail"
        
        has_one :mti_detail, :class_name => class_name, :autosave => true
        accepts_nested_attributes_for :mti_detail
        default_scope :include => :mti_detail

      end
    end

    module InstanceMethods
      def method_missing (method, *args)
        build_mti_detail if mti_detail.nil?
        if mti_detail && mti_detail.respond_to?(method, true)
          mti_detail.send(method, *args)
        else 
          super(method, *args)
        end
      end

      def respond_to?( method, include_private = false)
        build_mti_detail if mti_detail.nil?
        super(method, include_private) || 
          mti_detail.respond_to?(method, include_private)
      end
     
    end
  end
end
end
