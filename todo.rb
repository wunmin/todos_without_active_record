require "csv"
require "date"
require "byebug"
require_relative "import_info"

class Task
  attr_accessor :description, :status
  def initialize(task = {})
    @description = task[:description]
    @status = task[:status] || "[ ]"
    # @created_at = object_created_at(Time.now.to_s)
  end
  # def object_created_at(time_string)
  #   DateTime.parse(time_string)
  # end
end

module Actions
  attr_accessor :tasks
  # def last_task_id
  #   @tasks.rindex(@tasks[-1])
  # end
  def re_number
    # byebug
     @tasks.each_with_index do |task, index|
        @tasks[index] = ["[ ]", index+1, task[2]]
      end
  end

  def add(task_string)
    # task is a string
    new_task = Task.new(description: task_string)
    # new_task.id = last_task_id + 2
    @tasks << [new_task.status, @tasks.length + 1, new_task.description]
    save
    puts "The new task '#{task_string}' has been added to your TODO list."
    puts "The remaining tasks are:"
    display_all
  end

  def delete(id)
    # id is an integer
    @tasks.each_with_index do |element, index|
      if index == id-1
        puts "The task '#{element[2]}' has been deleted from your TODO list."
        @tasks.delete_at(index)
      end
    end
    re_number
    save
    puts "The remaining tasks are:"
    display_all
  end

  def check_off(input)
    # byebug
    @tasks[input-1][0] = "[X]"
    save
    puts "The remaining tasks are:"
    display_all
  end

  def uncheck(input)
    # byebug
    @tasks[input-1][0] = "[ ]"
    save
    puts "The remaining tasks are:"
    display_all
  end

  def save
    CSV.open("todo.csv", "wb") do |csv|
      @tasks.each do |task|
        task[2] = "\'#{task[2]}\'"
        csv << task
      end
    end
  end

  def display_all
    # @tasks.each do |task|
    #   puts "#{task[0]}. #{task[1]}"
    # end
    @tasks.each_with_index do |task, index|
      # byebug
      # puts "#{completed_status(index)} #{index+1}. #{task[0]}"
      puts "#{task[0]} #{task[1]}. #{task[2]}"
    end
  end
end


class List
  include Actions
  attr_reader :file

  def initialize(file)
    @file = file
    @tasks = []
  end

  def import
    @tasks = CSV.read("todo.csv")

    # CSV.foreach(@file) do |row|
    #   if
    #       add(row[0])
    #   else
    #       @tasks << row
    #   end
    #   save
    # end
  end

  def add_more_info
    if @tasks[0].length < 2
      @tasks.each_with_index do |task, index|
        @tasks[index] = ["[ ]", index+1, task[0]]
      end
    end
    save
  end

  def object_created_at(time_string)
    DateTime.parse(time_string)
  end
end



class MainProgram
  def self.start
    @new_list = List.new("todo.csv")
    @new_list.import
    @new_list.add_more_info

    action = ARGV[0]
    case
    when action == "display_all"
      @new_list.display_all
    when action == "delete"
      @new_list.delete(ARGV[1].to_i)
    when action == "add"
      @new_list.add(ARGV[1])
    when action == "check_off"
      @new_list.check_off(ARGV[1].to_i)
    when action == "uncheck"
      @new_list.uncheck(ARGV[1].to_i)
    else
      p "You can only choose from display_all, delete, add or check_off"
    end
  end

end

# Parse the file
MainProgram.start
