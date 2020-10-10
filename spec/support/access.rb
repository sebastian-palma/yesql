# frozen_string_literal: true

module YeSQL
  module Access
    def on_minimal(db)
      Dir.chdir("spec/minimal#{db}") { yield }
    end
  end
end
