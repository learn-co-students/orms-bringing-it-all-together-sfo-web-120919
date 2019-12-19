class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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

  def save
    sql = <<-SQL
         INSERT INTO dogs (name, breed)
         VALUES (?, ?)
       SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = retrieve_id
    self
  end

  def retrieve_id
    sql = <<-SQL
        SELECT id
        FROM dogs
        ORDER BY id DESC
        LIMIT 1
      SQL

    DB[:conn].execute(sql)[0][0]
    #binding.pry

  end

  def self.create(name:, breed:)
    #binding.pry
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(my_id)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL
    self.new_from_db(DB[:conn].execute(sql, my_id)[0])
  end

  def self.find_by_info(my_name, my_breed)
    sql = <<-SQL
         SELECT *
         FROM dogs
         WHERE name = ? and breed = ?
      SQL
    result = DB[:conn].execute(sql, my_name, my_breed)[0]
    if result
      return self.new_from_db(result)
    else 
      return nil # no record in db
    end    
    
  end



  def update
     exists_in_db = self.class.find_by_id(self.id)
     if !exists_in_db
      self.save 
     else 
     sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
     SQL
     DB[:conn].execute(sql, self.name, self.breed, self.id) 
     end
  end 


  def self.find_by_name(my_name)
   sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
     SQL
   result = DB[:conn].execute(sql, my_name)[0]
   if result
     return self.new_from_db(result)
   else 
     return nil # no record in db
   end    
   
 end

  def self.find_or_create_by(name:, breed:, id: nil)
    possible_dog = self.find_by_info(name, breed)
    #binding.pry
    if possible_dog.class == Dog
      #binding.pry
      return possible_dog
    else
      #binding.pry
      new_dog = self.create(name: name, breed: breed)
      #binding.pry
      #new_dog.save
      new_dog
    end
  end
end
