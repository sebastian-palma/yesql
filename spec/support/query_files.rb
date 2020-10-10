# frozen_string_literal: true

module YeSQL
  module QueryFiles
    def create_sql_file(path, statement)
      Pathname("#{::YeSQL.config.path}/#{path}.sql").tap do |pathname|
        pathname.dirname.mkpath
        pathname.write(statement)
      end
    end

    def create_article_stats_by_site
      create_sql_file('article_stats/by_site', <<~SQL)
        SELECT
          :current_site AS current_site,
          id,
          pageviews,
          site
        FROM article_stats
        WHERE site = :site
        AND logdate >= :from_date;
      SQL
    end
  end
end
