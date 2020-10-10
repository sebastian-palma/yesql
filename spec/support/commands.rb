# frozen_string_literal: true

module YeSQL
  module Commands
    def run_command(cmd, env: { 'RAILS_ENV' => 'test' })
      output, err, status = Open3.capture3(env, cmd)

      puts "\n\nCOMMAND:\n#{cmd}\n\nOUTPUT:\n#{output}\nERROR:\n#{err}\n" if ENV['LOG']

      [status, output, err]
    end
  end
end
