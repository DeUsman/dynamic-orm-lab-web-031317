require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

	def initialize(hash={})
		hash.each do |key, value|
			#binding.pry
			self.send("#{key}=", value)
		end
	end

	def self.table_name
		self.to_s.downcase.pluralize
	end


	def self.column_names
		column_names = []
		
		sql = "PRAGMA table_info('#{self.table_name}')"
		table_info = DB[:conn].execute(sql)
		table_info.each do |hash|
			column_names.push(hash["name"])
			
		end
		
		column_names.compact
	end

	def self.find_by_name(nam_e)

		sql = "SELECT * FROM #{table_name} WHERE name = '#{nam_e}'"

		DB[:conn].execute(sql)
	end

	def self.find_by(hash)
		x1 = hash.keys[0].to_s
		x2 = hash.values[0].to_s
		sql = "SELECT * FROM #{table_name} WHERE #{x1} = '#{x2}'"
		
		DB[:conn].execute(sql)


	end

	def table_name_for_insert
		self.class.table_name
	end


	def col_names_for_insert
		self.class.column_names.reject {|col_name| col_name == "id"}.join(", ")
	end

	def values_for_insert
		values = []
		self.class.column_names.each do |col_name|
			if(col_name != "id")
			values.push("'#{self.send(col_name)}'")
		    end

		end
		values.join(", ")
	end

	def save
		sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
		DB[:conn].execute(sql)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

	end
  	end


  
