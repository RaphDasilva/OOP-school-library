require './person'
require './rental'
require './book'
require './classroom'
require './student'
require './teacher'
require './nameable'
require './save'
require './read_data'

class App
  def initialize
    @books = []
    @people = []
    @rentals = []
  end

  def list_books
    if @books.empty?
      'There are no books'
    else
      @books.each do |each_book|
        puts "Title: \"#{each_book.title}\", Author: \"#{each_book.author}\""
        
      end
    end
  end

  def list_people
    if @people.empty?
      'There are no people'
    else
      @people.each do |each_person|
        puts "[#{each_person.class}] Name: #{each_person.name}, ID: #{each_person.id}, Age: #{each_person.age}"
      end
    end
  end

  def create_person
    print 'Do you want to create a student (1) or a teacher (2)? [Input the number]: '
    number = gets.chomp.to_i
    if number == 1
      create_student
    elsif number == 2
      create_teacher
    end
  end

  def create_student
    print 'Age: '
    age = gets.chomp.to_i
    print 'Name: '
    name = gets.chomp
    print 'Has parent permission? [Y/N]: '
    parent_permission = gets.chomp

    each_student = Student.new(age, name, parent_permission)
    @people << each_student
    puts 'Person created successfully'
  end

  def create_teacher
    print 'Age: '
    age = gets.chomp.to_i
    print 'Name: '
    name = gets.chomp
    print 'Specialization: '
    specialization = gets.chomp

    each_teacher = Teacher.new(age, specialization, name)
    @people << each_teacher
    puts 'Person created successfully'
  end

  def create_book
    print 'Title: '
    title = gets.chomp
    print 'Author: '
    author = gets.chomp

    each_book = Book.new(title, author)
    @books << each_book
    puts 'Book created successfully'
  end

  # Method to create a rental
  def create_rental
    if @books.empty?
      puts 'Book array is empty'
    elsif @people.empty?
      puts 'Person array is empty'
    else
      rental_book = select_book
      rental_person = select_person
      date = the_rental_date

      rental = Rental.new(date, @people[rental_person], @books[rental_book])

      @rentals << rental
      puts 'Rental created successfully'
    end
  end

  # Helper method to select a book from the list
  def select_book
    puts 'Select a book from the following list by number:'
    @books.each_with_index do |book, index|
      puts "#{index}) Title: \"#{book.title}\", Author: #{book.author}"
    end
    gets.chomp.to_i
  end

  # Helper method to select a person from the list
  def select_person
    puts 'Select a person from the following list by number (not id):'
    @people.each_with_index do |person, index|
      puts "#{index}) Name: #{person.name}, ID: #{person.id}, Age: #{person.age}"
    end
    gets.chomp.to_i
  end

  # Helper method to get the rental date from user input
  def the_rental_date
    print 'Enter rental date: '
    gets.chomp
  end

  # private :select_book, :select_person, :get_rental_date

  def list_rentals_of_person
    if @rentals.empty?
      puts 'Rental is empty'
    else
      print 'Enter ID of person: '
      person_id = gets.chomp.to_i

      rentals_found = false

      @rentals.each do |rental|
        next unless rental.person.id == person_id

        rentals_found = true
        puts 'Rentals:'
        puts "Date: #{rental.date}, Book: \"#{rental.book.title}\" by #{rental.book.author}"
      end

      puts 'No rentals found for the given person' unless rentals_found
    end
  end

  def student_hash(array)
    new_array = []
    array.each do |item|
      item_hash = if item.instance_of?(Student)
                    {
                      'class' => item.class,
                      'name' => item.name,
                      'id' => item.id
                    }
                  else
                    {
                      'age' => item.age,
                      'class' => item.class,
                      'name' => item.name
                    }
                  end
      new_array << item_hash
    end
    new_array
  end

  def book_hash(arr)
    new_array = []
    arr.each do |item|
      book_hash = {
        'title' => item.title,
        'author' => item.author
      }
      new_array << book_hash
    end
    new_array
  end

  def rental_hash(arr)
    new_array = []
    arr.each do |item|
      rental_hash = {
        'date' => item.date,
        'person' => item.person.name,
        'books' => item.book.title
      }
      new_array << rental_hash
    end
    new_array
  end

  def save_on_exit
    puts 'Thank you for using this app!'
    new_save = Save.new
    new_save.save_file(student_hash(@people), 'people.json') unless @people.empty?
    new_save.save_file(book_hash(@books), 'books.json') unless @books.empty?
    new_save.save_file(rental_hash(@rentals), 'rentals.json') unless @rentals.empty?
  end

  def people_class(arr)
    new_array = []
    arr.each do |item|
      person = if item['class'] == 'Student'
                 Student.new(item['age'], item['name'], item['parent_permission'])
               else
                 Teacher.new(item['age'], item['specialization'], item['name'])
               end
      new_array << person
    end
    new_array
  end

  def book_class(arr)
    new_array = []
    arr.each do |item|
      new_array << Book.new(item['title'], item['author'])
    end
    new_array
  end

  def rental_class(arr)
    new_array = []
    arr.each do |item|
      @people.each do |person|
        next unless item['person'] == person.name

        @books.each do |book|
          new_array << Rental.new(item['date'], person, book) if item['books'] == book.title
        end
      end
    end
    new_array
  end

  def fetch_all_data
    people_data = ReadData.new
    @people = people_class(people_data.read_data('people.json'))
    @books = book_class(people_data.read_data('books.json'))
    @rentals = rental_class(people_data.read_data('rentals.json'))
  end
end
