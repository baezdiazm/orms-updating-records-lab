require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  
  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-AYO
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    AYO
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-AYO
      DROP TABLE students
    AYO
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-AYO
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    AYO
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def update
    sql = <<-YURR
      UPDATE students
      SET name = ?, grade = ? WHERE id = ?
    YURR
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    #student.name = row[1]
    #student.grade = row[2]
    student
  end

  def self.find_by_name(name)
    sql = <<-YURR
      SELECT * FROM students WHERE name = ?
      LIMIT 1
    YURR
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end
