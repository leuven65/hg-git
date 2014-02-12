  $ rmpwd="import sys; print sys.stdin.read().replace('$(dirname $(pwd))/', '')"
  $ git clone ../gitrepo1 . | python -c "$rmpwd" | sed "$clonefilt" | egrep -v '^done\.$'
  $ git submodule add ../gitsubrepo subrepo | python -c "$rmpwd" | sed "$clonefilt" | egrep -v '^done\.$'
  $ git commit -m 'rm subrepo' | sed 's/, 0 deletions(-)//' | sed 's/, 0 insertions(+)//'
  [master 7e4c934] rm subrepo
   2 files changed, 4 deletions(-)
   delete mode 160000 subrepo
  $ hg -R hgrepo log --graph  | grep -v ': *master'
  @  changeset:   2:76fda365fbbb
  |  summary:     rm subrepo
  o  changeset:   1:2f69b1b8a6f8
  o  changeset:   0:3442585be8a6

we should have some bookmarks
  $ hg -R hgrepo book
   * master                    2:76fda365fbbb