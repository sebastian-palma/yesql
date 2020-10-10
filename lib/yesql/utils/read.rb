# frozen_string_literal: true

module YeSQL
  module Utils
    module Read
      def self.statement(file_path, readable: false)
        Dir["./#{::YeSQL.config.path}/**/*.sql"]
          .find { |dir_file_path| dir_file_path.include?("#{file_path}.sql") }
          .tap do |sql_file_path|
          break File.readlines(sql_file_path, chomp: true).join(' ') if readable == true

          break File.read(sql_file_path)
        end
      end
    end
  end
end
