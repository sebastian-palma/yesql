# frozen_string_literal: true

require 'spec_helper'

describe ::YeSQL::Config::Configuration do
  context 'when configuring ::YeSQL.config.path' do
    let(:new_path) { 'here/sql_files' }

    before { ::YeSQL.configure { |config| config.path = new_path } }
    after { remove_path }

    it do
      expect(::YeSQL.config.path).to eq(new_path)
    end
  end

  describe '#reset_config' do
    let(:new_path) { 'here/sql_files' }

    before do
      ::YeSQL.configure { |config| config.path = new_path }
      ::YeSQL.reset_config
    end

    after { remove_path }

    it { expect(::YeSQL.config.path).to eq(::YeSQL::Config::Configuration::DEFAULT_PATH) }
    it { expect(::YeSQL.reset_config).to eq(::YeSQL) }
  end
end
