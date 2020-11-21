require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord # Student class is inheriting InteractiveRecord class 

    # only code needed here is to create the attr_accessor 
    
    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

    # iterates through column_names, turns each into a symbol and creates attr_accessor

end
