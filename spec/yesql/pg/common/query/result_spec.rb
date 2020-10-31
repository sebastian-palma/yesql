# frozen_string_literal: true

require 'spec_helper'
require 'yesql/query/result'

require "#{RSPEC_ROOT}/minimalpg/config/environment"
require "#{RSPEC_ROOT}/yesql/shared/query/result"

describe ::YeSQL::Query::Result do
  describe '.call' do
    include_context 'with ::YeSQL::Query::Result'

    it_behaves_like 'an exec_query execution', :pg,  :rails5
    it_behaves_like 'an exec_query execution', :pg
    it_behaves_like 'a view exec_query execution', :pg
  end
end
