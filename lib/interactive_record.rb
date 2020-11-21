require_relative "../config/environment.rb"
require 'active_support/inflector'


class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize # call to class name to refer to table name, turn it into a string, downcase, and make it plural
    end

    def self.column_names
        DB[:conn].results_as_hash = true # access the hash of columns

        sql = "PRAGMA table_info('#{table_name}')" # use PRAGMA to receive table info

        table_info = DB[:conn].execute(sql) # execute
        column_names = [] # empty array to hold column names

        table_info.each do |column| # iterate through info to pull each columns name and shovel into our array
            column_names << column["name"]
        end
        column_names.compact # return our array, .compact to eliminate the possibility of any nil results
    end

    def initialize(options={}) # initialize w/ empty hash
        options.each do |property, value| # iterate through the hash
            self.send("#{property}=", value) # use send to interpolate a the hashes key as a method that sets equal to the keys value
        end
    end

    def table_name_for_insert
        self.class.table_name # call on the class method table name to receive the table to insert into
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ") # call on the class method column_names, iterate through & delete id (gets automatically created) then join on a comma
    end

    def values_for_insert
        values = [] # create empty array for values
        self.class.column_names.each do |col_name| # call on class method column_names, iterate and shovel col_name into array unless the column returns nil
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ") # return our array, joined on a comma
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})" # use SQL statement to INSERT INTO
        DB[:conn].execute(sql) # execute SQL statement
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0] # assign id instance vari to SQL statement that SELECTS the last insert rowid
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name]) # use SQL statement to SELECT by name
    end

    def self.find_by(hash)
        sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = ?" # use SQL statement to SELECT by given attribute, it will be a hash, need to get the keys at 0 index convert to string
        DB[:conn].execute(sql, hash.values[0]) # execute SQL statement
        # hash is a hash of col. and values, need to pull the column name out and conver to a string
    end


end