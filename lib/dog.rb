require_relative "../config/environment.rb"
require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
  end

  def self.create(name:, breed:)
    dog = Dog.new
    dog.name = name
    dog.breed = breed
    dog.save
  end

  def self.new_from_db(row)
    dog = Dog.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])  
  end

  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])  
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)  
  end

  def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
        LIMIT 1
      SQL
      dog = DB[:conn].execute(sql,name,breed)
      if dog.empty?
        dog = Dog.new
        dog.name = name
        dog.breed = breed
        dog.save
      else
        Dog.new_from_db(dog[0])
      end
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)

      sql = <<-SQL
        SELECT id
        FROM dogs
        ORDER BY id DESC
        LIMIT 1
      SQL
      self.id = DB[:conn].execute(sql)[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed, self.id)    
  end

end