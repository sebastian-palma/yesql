# frozen_string_literal: true

module YeSQL
  module Errors
    module FilePathDoesNotExistError
      def validate_file_path_existence(file_path)
        return if file_exists?(file_path)

        raise NotImplementedError, format(MESSAGE, available_files: available_files,
                                                   file_path: file_path, path: ::YeSQL.config.path)
      end

      private

      MESSAGE = <<~MSG

        SQL file "%<file_path>s" does not exist in %<path>s.

        Available SQL files are:

        %<available_files>s
      MSG
      private_constant :MESSAGE

      def file_exists?(file_path)
        path_files.any? { |filename| filename.include?("#{file_path}.sql") }
      end

      def available_files
        path_files.map { |file| "- #{file}\n" }.join
      end

      def path_files
        @path_files ||= Dir["#{::YeSQL.config.path}/**/*.sql"]
      end
    end
  end
end
