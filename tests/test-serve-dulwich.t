#require serve

Check cloning a Git repository over anonymous HTTP, served up by
Dulwich. The script uses `os.fork()`, so this doesn't work on Windows.

Load commonly used test logic
  $ . "$TESTDIR/testutil"

Enable progress debugging:

  $ cat >> $HGRCPATH <<EOF
  > [progress]
  > delay = 0
  > refresh = 0
  > width = 60
  > format = topic unit total number item bar
  > assume-tty = yes
  > EOF

Create a dummy repository and serve it

  $ git init -q test
  $ cd test
  $ echo foo > foo
  $ git add foo
  $ fn_git_commit -m test
  $ echo bar > bar
  $ git add bar
  $ fn_git_commit -m test
  $ $PYTHON $TESTDIR/testlib/dulwich-serve.py --port=$HGPORT
  $ cd ..

Make sure that clone over unauthenticated HTTP doesn't break

  $ hg clone -U git+http://localhost:$HGPORT copy 2>&1
  \r (no-eol) (esc)
  importing commits 1/2 [================>                  ]\r (no-eol) (esc)
  importing commits 2/2 [==================================>]\r (no-eol) (esc)
                                                              \r (no-eol) (esc)
  importing git objects into hg
  $ hg log -T 'HG:{node|short} GIT:{gitnode|short}\n' -R copy
  HG:221dd250e933 GIT:3af9773036a9
  HG:c4d188f6e13d GIT:b23744d34f97

  $ cd copy
  $ hg up master
  \r (no-eol) (esc)
  updating files 2/2 foo                  [================>]\r (no-eol) (esc)
                                                              \r (no-eol) (esc)
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (activating bookmark master)
  $ echo baz > baz
  $ fn_hg_commit -A -m baz
  $ hg push
  \r (no-eol) (esc)
  find commits to export commits 1/1 152c456b0da423597ed2 [>]\r (no-eol) (esc)
                                                              \r (no-eol) (esc)
  \r (no-eol) (esc)
  exporting 1/1 [==========================================>]\r (no-eol) (esc)
                                                              \r (no-eol) (esc)
  pushing to git+http://localhost:$HGPORT/
  searching for changes
  adding objects
  added 1 commits with 1 trees and 1 blobs
  updating reference refs/heads/master
  $ hg log -T 'HG:{node|short} GIT:{gitnode|short}\n' -r .
  HG:daf1ae153bf8 GIT:ab88565d0614

Prevent the test from hanging:

  $ cat $DAEMON_PIDS | xargs kill

(As an aside, don't use `pkill -F` -- that doesn't work and causes a
hang on Alpine.)
