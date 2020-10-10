# frozen_string_literal: true

require 'spec_helper'
require 'yesql/bindings/binder'

describe ::YeSQL::Bindings::Binder, :minimalpg do
  after(:all) do
    on_minimal(:pg) { remove_generated_files }
  end

  context 'when casting with ::' do
    let(:sql_file) { 'article_stats/select_text_pageviews' }

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
end
