# frozen_string_literal: true

require 'spec_helper'
require 'yesql/utils/read'

describe ::YeSQL::Utils::Read, :pg do
  after(:all) do
    on_minimal(:pg) { remove_generated_files }
  end

  it do
    create_sql_file('get_current_time', "SELECT CURRENT_TIME;\n")
    expect(described_class.statement('get_current_time')).to eq("SELECT CURRENT_TIME;\n")
  end

  it do
    create_sql_file('users/by_country', <<~SQL)
      SELECT *
      FROM users
      WHERE country_code = :country_code;
    SQL

    expect(described_class.statement('users/by_country')).to eq(<<~SQL)
      SELECT *
      FROM users
      WHERE country_code = :country_code;
    SQL
  end

  context 'with `readable` true' do
    it do
      expect(described_class.statement('users/by_country', readable: true)).to eq(
        'SELECT * FROM users WHERE country_code = :country_code;'
      )
    end
  end

  context 'when a file name is a substring of another file' do
    let(:top_10_by_country) do
      <<~SQL
        SELECT stats.user_id, SUM(counter) AS total_counter
        FROM stats
        GROUP BY stats.user_id, stats.country
        ORDER BY total_counter DESC
        LIMIT 10;
      SQL
    end
    let(:top_10) do
      <<~SQL
        SELECT stats.user_id, SUM(counter) AS total_counter
        FROM stats
        GROUP BY stats.user_id
        ORDER BY total_counter DESC
        LIMIT 10;
      SQL
    end

    before do
      create_sql_file('users/top_10_by_country', top_10_by_country)
      create_sql_file('users/top_10', top_10)
    end

    it 'uses the file that matches exactly with the given `file_path` plus the ".sql" extension' do
      expect(described_class.statement('users/top_10')).to eq(top_10)
    end
  end
end
