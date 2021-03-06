require 'spec_helper'

module Puppet::Provider::SyslogServer; end
require 'puppet/provider/syslog_server/cisco_ios'

RSpec.describe Puppet::Provider::SyslogServer::CiscoIos do
  def self.load_test_data
    PuppetX::CiscoIOS::Utility.load_yaml(File.expand_path(__dir__) + '/test_data.yaml', false)
  end

  it_behaves_like 'resources parsed from cli'
  it_behaves_like 'a noop canonicalizer'

  context 'Update tests:' do
    load_test_data['default']['update_tests'].each do |test_name, test|
      it test_name.to_s do
        fake_device(test['device'], test['family'])
        if test['commands'].size.zero?
          expect { described_class.commands_from_instance(test['instance'], test['current']) }.to raise_error(%r{.*})
        else
          result = []
          described_class.commands_from_instance(test['instance'], test['current']).each { |x| result << x.squeeze(' ') }
          expect(result).to eq test['commands']
        end
      end
    end
  end
end
