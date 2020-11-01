# frozen_string_literal: true

require 'spec_helper'

require 'yesql/statement'

require "#{RSPEC_ROOT}/minimalpg/config/environment"
require "#{RSPEC_ROOT}/yesql/shared/statement"

describe ::YeSQL::Statement, :statement do
  describe '.bound', :pg do
    include_context 'when binding a statement'

    it_behaves_like 'a regular bound statement', "SELECT $1, CONCAT($1, ' Shakala!');"

    context 'with a view' do
      it_behaves_like 'a quoted bound statement'
      it_behaves_like 'an unquoted bound statement'
    end
  end

  describe('.to_s', :pg) { include_context 'when converting to string' }

  describe '.view?', :pg do
    include_context 'when processing a view statement'

    it_behaves_like 'not a view', 'ALTER VIEW tmp;'
    it_behaves_like 'a view', 'CREATE VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE OR REPLACE VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE OR REPLACE TEMP VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE OR REPLACE TEMPORARY VIEW tmp AS'
    it_behaves_like 'a view', 'CREATE RECURSIVE VIEW tmp(id, name) AS'
    it_behaves_like 'a view', <<~SQL
      CREATE VIEW tmp AS WITH RECURSIVE tmp(id, name) AS (SELECT * FROM t WHERE name = :name)
      SELECT * FROM tmp;
    SQL
  end
end
