# Copyright Swipely, Inc.  All rights reserved.

shared_context 'local fog storage' do
  after do
    FileUtils.rm_rf(tmpdir)
  end

  let(:fog_storage) {
    Fog::Storage.new(
      :provider => 'Local',
      :local_root => tmpdir,
      :endpoint => 'http://example.com'
    )
  }

  let(:tmpdir) { Dir.mktmpdir('hasta_local_storage_test') }
end
