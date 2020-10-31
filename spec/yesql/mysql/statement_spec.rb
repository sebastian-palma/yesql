# frozen_string_literal: true

require 'spec_helper'

require 'yesql/statement'

require "#{RSPEC_ROOT}/minimalmysql/config/environment"
require "#{RSPEC_ROOT}/yesql/shared/statement"

describe ::YeSQL::Statement, :statement do
  describe '.bound', :mysql do
    include_context 'when binding a statement'

    it_behaves_like 'a regular bound statement', "SELECT ?, CONCAT(?, ' Shakala!');"

    context 'with a view' do
      it_behaves_like 'a quoted bound statement'
      it_behaves_like 'an unquoted bound statement'
    end
  end

  describe('.to_s', :mysql) { include_context 'when converting to string' }

  describe '.view?', :mysql do
    include_context 'when processing a view statement'

    it_behaves_like 'not a view', 'SHOW CREATE VIEW tmp;'
    it_behaves_like 'a view', 'CREATE VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE OR REPLACE VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE OR REPLACE ALGORITHM=MERGE VIEW tmp AS'
  end
end
