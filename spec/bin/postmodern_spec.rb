require 'spec_helper'

describe 'postmodern' do
  describe 'archive' do
    let(:command) { `bin/postmodern archive --path filepath --filename filename` }

    before do
      double_cmd('postmodern_archive.local')
      double_cmd('which', exit: 0)
    end

    it 'exports second argument as WAL_ARCHIVE_FILE' do
      expect(command).to include('Archiving file: filename')
    end

    it 'exports first argument WAL_ARCHIVE_PATH' do
      expect(command).to include('path: filepath')
    end

    context 'when local script is present' do
      before { double_cmd('which postmodern_archive.local', exit: 0) }

      it 'succeeds' do
        expect { command }.to have_exit_status(0)
      end

      it 'calls a local file with file name and path' do
        expect { command }.to shellout('postmodern_archive.local filepath filename')
      end
    end

    context 'when local script is not present' do
      before { double_cmd('which postmodern_archive.local', exit: 1) }

      it 'succeeds' do
        expect { command }.to have_exit_status(0)
      end

      it 'does nothing' do
        expect { command }.not_to shellout('pg_wal_archive.local filepath filename')
      end
    end
  end

  describe 'restore' do
    let(:command) { `bin/postmodern restore --path filepath --filename filename` }

    before do
      double_cmd('postmodern_restore.local')
      double_cmd('which', exit: 0)
    end

    it 'exports second argument as WAL_restore_FILE' do
      expect(command).to include('Restoring file: filename')
    end

    it 'exports first argument WAL_restore_PATH' do
      expect(command).to include('path: filepath')
    end

    context 'when local script is present' do
      before { double_cmd('which postmodern_restore.local', exit: 0) }

      it 'succeeds' do
        expect { command }.to have_exit_status(0)
      end

      it 'calls a local file with file name and path' do
        expect { command }.to shellout('postmodern_restore.local filepath filename')
      end
    end

    context 'when local script is not present' do
      before { double_cmd('which postmodern_restore.local', exit: 1) }

      it 'succeeds' do
        expect { command }.to have_exit_status(0)
      end

      it 'does nothing' do
        expect { command }.not_to shellout('pg_wal_restore.local filepath filename')
      end
    end
  end
end
