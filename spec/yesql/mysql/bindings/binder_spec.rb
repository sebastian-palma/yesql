# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/binder'
require_relative './../../../minimalmysql/config/environment'

describe ::YeSQL::Bindings::Binder, :mysql do
  context 'when using the same bind more than once' do
    let(:sql_file) { 'article_stats/select_text_pageviews' }

    before do
      create_sql_file(sql_file, <<~SQL)
        SELECT :keyword, CONCAT(:keyword, ' Shakala!');
      SQL
    end

    after { remove_generated_files }

    it 'replaces a single named bind with two positional binds' do
      expect(described_class.bind_statement(sql_file, { keyword: 'BOOM' })).to(
        eq("SELECT ?, CONCAT(?, ' Shakala!');")
      )
    end
  end
end
