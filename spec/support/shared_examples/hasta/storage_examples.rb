# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  shared_examples_for 'a storage service' do
    describe '#exists?' do
      let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
      let(:bucket_name) { 'my-bucket' }

      context 'given a file uri' do
        let(:path) { 'path/to/a/file.txt' }

        context 'that exists' do
          before do
            bucket = fog_storage.directories.create(:key => bucket_name)
            bucket.files.create(:body => "\n", :key => path)
          end

          it { expect(subject.exists?(s3_uri)).to be_true }
        end

        context 'that does not exist' do
          it { expect(subject.exists?(s3_uri)).to be_false }
        end
      end

      context 'given a directory uri' do
        let(:path) { 'path/to/files/' }

        it { expect(subject.exists?(s3_uri)).to be_false }
      end
    end

    describe '#files_for' do
      context 'given a directory path' do
        before do
          fog_storage.directories.create(:key => bucket_name)
        end

        let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
        let(:bucket_name) { 'my-bucket' }
        let(:path) { 'path/to/files/' }

        let(:result) { subject.files_for(s3_uri) }

        context 'that exists' do
          before do
            bucket = fog_storage.directories.get(bucket_name)
            bucket.files.create(:body => "\n", :key => "#{path}1.txt")
            bucket.files.create(:body => "\n", :key => "#{path}2.txt")
            bucket.files.create(:body => "\n", :key => "path/to/files/tmp/1.txt.swp")
            bucket.files.create(:body => "\n", :key => "path/to/oldfiles/3.txt")
          end

          let(:result_keys) { result.map(&:key) }

          it { expect(subject.exists?(s3_uri)).to be_true }

          it { expect(result.length).to eq(2) }

          it "only returns files in the path/to/files/ directory" do
            expect(result_keys).to include("#{path}1.txt", "#{path}2.txt")
          end
        end

        context 'that does not exist' do
          let(:path) { 'path/to/dev/null/' }

          it { expect(result).to be_empty }
        end
      end

      context 'given a file path' do
        let(:s3_uri) { Hasta::S3URI.new(bucket_name, path) }
        let(:bucket_name) { 'my-bucket' }

        context 'given a file' do
          let(:path) { 'path/to/myfile.txt' }

          context 'that exists' do
            before do
              bucket = fog_storage.directories.create(:key => bucket_name)
              bucket.files.create(:body => contents, :key => path)
            end

            let(:contents) { "WOW\n" }

            it { expect(subject.exists?(s3_uri)).to be_true }
            it { expect(subject.files_for(s3_uri).length).to eq(1) }
            it { expect(subject.files_for(s3_uri).first.each_line.to_a).to eq([contents]) }
          end

          context 'that does not exist' do
            it { expect(subject.exists?(s3_uri)).to_not be_true }

            it 'raises' do
              expect { subject.files_for(s3_uri) }.to raise_error(Hasta::NonExistentPath)
            end
          end
        end
      end
    end
  end
end
