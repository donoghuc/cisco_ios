require 'spec_helper_acceptance'

describe 'radius_server' do
  before(:all) do
    skip "this device #{device_model} does not support radius server" if ['3560', '3750', '4507', '4948', '6503'].include?(device_model)
  end

  it 'add radius_server' do
    pp = <<-EOS
    radius_server { "2.2.2.2":
      hostname => '1.2.3.4',
      auth_port => 1642,
      acct_port => 1643,
      key => '02574459020A03',
      key_format => 7,
      retransmit_count => 7,
      timeout => 42,
      ensure => 'present',
    }
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server', '2.2.2.2')
    # Does our target device support the 'new' Radius Server syntax?
    # If so, should be present, otherwise we will fail test and a human needs to revisit this
    raise 'Radius server 2.2.2.2 not present, device might not be compatible' unless result =~ %r{ensure.*present}

    expect(result).to match(%r{2.2.2.2.*})
    expect(result).to match(%r{key.*02574459020A03})
    expect(result).to match(%r{key_format.*7})
    expect(result).to match(%r{hostname.*1.2.3.4})
    expect(result).to match(%r{retransmit_count.*7})
    expect(result).to match(%r{acct_port.*1643})
    expect(result).to match(%r{auth_port.*1642})
    expect(result).to match(%r{timeout.*42})
  end

  it 'delete radius_server' do
    result = run_resource('radius_server', '2.2.2.2')
    # Does our target device support the 'new' Radius Server syntax?
    # If so, should be present, otherwise we will fail test and a human needs to revisit this
    raise 'Radius server 2.2.2.2 not present, device might not be compatible' unless result =~ %r{ensure.*present}
    pp = <<-EOS
radius_server { '2.2.2.2':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(allow_changes: true)
    # Are we idempotent
    run_device(allow_changes: false)
    # Check puppet resource
    result = run_resource('radius_server', '2.2.2.2')
    expect(result).to match(%r{2.2.2.2.*})
    expect(result).to match(%r{ensure.*absent})
  end
end
