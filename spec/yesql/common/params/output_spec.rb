# frozen_string_literal: true

require 'spec_helper'
require 'yesql/params/output'

describe ::YeSQL::Params::Output do
  describe '.columns?' do
    it { expect(described_class.new(:columns).columns?).to eq(true) }
    it { expect(described_class.new(:columnitas).columns?).to eq(false) }
  end

  describe '.rows?' do
    it { expect(described_class.new(:rows).rows?).to eq(true) }
    it { expect(described_class.new(:rząd).rows?).to eq(false) }
  end

  describe '.hash?' do
    it { expect(described_class.new(:hash).hash?).to eq(true) }
    it { expect(described_class.new(:hachikō).hash?).to eq(false) }
  end
end
