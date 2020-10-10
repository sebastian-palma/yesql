# frozen_string_literal: true

module YeSQL
  module Cleaning
    def remove_path
      FileUtils.rm_rf(Dir[::YeSQL.config.path])
    end

    def remove_generated_files
      remove_path
      FileUtils.rm_rf(Dir['db/migrate/*'])
      FileUtils.rm_rf(Dir['app/models/**/*'].grep_v(/application_record\.rb/))
    end

    def undo_model_changes
      version = Dir['./db/migrate/*'][0].match(%r{/(\d+)_[^.]+\.rb$})[1]
      run_command("VERSION=#{version} rake db:migrate:down")
      remove_generated_files
    end
  end
end
