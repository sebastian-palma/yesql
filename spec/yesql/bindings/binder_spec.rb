# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/binder'

describe ::YeSQL::Bindings::Binder, :minimalpg do
  after(:all) do
    on_minimal(:pg) { remove_generated_files }
  end

  let(:sql_file) { 'article_stats/select_text_pageviews' }

  context 'when casting with ::' do
    before do
      create_sql_file(sql_file, <<~SQL)
        SELECT pageviews::text
        FROM article_stats
        WHERE country_code = :country_code;
      SQL
    end

    it 'does not replace the double colon with a bind param' do
      expect(described_class.bind_statement(sql_file, { country_code: 'AF' })).to eq(
        'SELECT pageviews::text FROM article_stats WHERE country_code = $1;'
      )
    end
  end

  context 'when using the same bind more than once' do
    before do
      create_sql_file(sql_file, "SELECT :keyword::TEXT, CONCAT(:keyword::TEXT, ' Shakala!');")
    end

    it 'replaces the named binds with a single positional bind' do
      expect(described_class.bind_statement(sql_file, { keyword: 'BOOM' })).to eq(
        "SELECT $1::TEXT, CONCAT($1::TEXT, ' Shakala!');"
      )
    end
  end
end
