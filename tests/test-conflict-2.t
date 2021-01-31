Load commonly used test logic
  $ . "$TESTDIR/testutil"

  $ hg init hgrepo1
  $ cd hgrepo1
  $ echo A > afile
  $ hg add afile
  $ hg ci -m "origin"

  $ echo B > afile
  $ hg ci -m "A->B"

  $ hg up -r0
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ echo C > afile
  $ hg ci -m "A->C"
  created new head

  $ hg merge -r1 2>&1 | sed 's/-C ./-C/' | egrep -v '^merging afile' | sed 's/incomplete.*/failed!/'
  warning: conflicts.* (re)
  0 files updated, 0 files merged, 0 files removed, 1 files unresolved
  use 'hg resolve' to retry unresolved file merges or 'hg *' to abandon (glob)
resolve using second parent
  $ echo B > afile
  $ hg resolve -m afile | egrep -v 'no more unresolved files' || true
  $ hg ci -m "merge to B"

  $ hg log --graph --style compact | sed 's/\[.*\]//g'
  @    3:2,1   120385945d08   1970-01-01 00:00 +0000   test
  |\     merge to B
  | |
  | o  2:0   ea82b67264a1   1970-01-01 00:00 +0000   test
  | |    A->C
  | |
  o |  1   7205e83b5a3f   1970-01-01 00:00 +0000   test
  |/     A->B
  |
  o  0   5d1a6b64f9d0   1970-01-01 00:00 +0000   test
       origin
  

  $ cd ..

  $ git init --bare gitrepo
  Initialized empty Git repository in $TESTTMP/gitrepo/

  $ cd hgrepo1
  $ hg bookmark -r tip master
  $ hg push -r master ../gitrepo
  pushing to ../gitrepo
  searching for changes
  adding objects
  added 4 commits with 3 trees and 3 blobs
  $ cd ..

  $ hg clone gitrepo hgrepo2
  importing git objects into hg
  updating to branch default
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
expect the same revision ids as above
  $ hg -R hgrepo2 log --graph --style compact | sed 's/\[.*\]//g'
  @    3:1,2   120385945d08   1970-01-01 00:00 +0000   test
  |\     merge to B
  | |
  | o  2:0   7205e83b5a3f   1970-01-01 00:00 +0000   test
  | |    A->B
  | |
  o |  1   ea82b67264a1   1970-01-01 00:00 +0000   test
  |/     A->C
  |
  o  0   5d1a6b64f9d0   1970-01-01 00:00 +0000   test
       origin
  
