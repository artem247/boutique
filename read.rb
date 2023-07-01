# frozen_string_literal: true

require 'find'

def read_files_from_folder
  buffer = []
  Find.find(Dir.pwd) do |path|
    next unless FileTest.file?(path) && File.extname(path) == '.rb'

    File.open(path, 'r') do |f|
      buffer << f.read
    end
  end
  buffer.join("\n\n")
end

def write_to_output(buffer, output_file)
  File.open(output_file, 'w') do |f|
    f.write(buffer)
  end
end

def main
  puts 'Enter the output file name: '
  output_file = gets.chomp
  buffer = read_files_from_folder
  write_to_output(buffer, output_file)
end

main if __FILE__ == $PROGRAM_NAME
