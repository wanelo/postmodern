require 'spec_helper'
require 'postmodern/backup/backup'

describe Postmodern::Backup::Backup do
  let(:stdout) { double(to_s: '') }
  let(:stderr) { double(to_s: '') }
  let(:status) { double(exitstatus: 0) }

  let(:directory) { '/tmp/pg_backup' }
  let(:user) { 'pg' }
  let(:host) { '127.0.0.1' }
  let(:name) { 'host.com' }
  let(:port) { 5433 }
  let(:current_date) { Time.now.strftime('%Y%m%d') }
  let(:arguments) { %W(--user #{user} --directory #{directory} --host #{host} --name #{name} --port #{port}) }

  subject(:backup) { Postmodern::Backup::Backup.new(arguments) }

  before do
    allow(Open3).to receive(:capture3).and_return([stdout, stderr, status])
    allow($stderr).to receive(:puts)
    allow(backup).to receive(:exit)
  end

  describe '#run' do
    let(:backup_command) { "pg_basebackup --checkpoint=fast -F tar -D - -U #{user} -h #{host} -p #{port}" }

    it 'archives the data directory with gzip' do
      backup.run
      expect(Open3).to have_received(:capture3).with(
        {
          'PATH' => anything
        },
        "#{backup_command} | gzip -9 > #{directory}/#{name}.basebackup.#{current_date}.tar.gz"
      )
    end

    context 'with --pigz' do
      let(:arguments) { %W(-U #{user} -d #{directory} -H #{host} -n #{name} -p #{port} --pigz 12) }

      it 'archives the data directory with pigz' do
        backup.run
        expect(Open3).to have_received(:capture3).with(
          {
            'PATH' => anything
          },
          "#{backup_command} | pigz -9 -p 12 > #{directory}/#{name}.basebackup.#{current_date}.tar.gz"
        )
      end
    end
  end
end

