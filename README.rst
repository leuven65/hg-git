Hg-Git Mercurial Plugin
=======================

Homepage:
  https://hg-git.github.io/
Repository:
  https://foss.heptapod.net/mercurial/hg-git
Mailing list:
  `hg-git@googlegroups.com <mailto:hg-git@googlegroups.com>`_ (`Google
  Group <https://groups.google.com/g/hg-git>`_)

This is the Hg-Git plugin for Mercurial, adding the ability to push and
pull to/from a Git server repository from Hg. This means you can
collaborate on Git based projects from Hg, or use a Git server as a
collaboration point for a team with developers using both Git and Hg.

The Hg-Git plugin can convert commits/changesets losslessly from one
system to another, so you can push via a Mercurial repository and another Hg
client can pull it and their changeset node ids will be identical -
Mercurial data does not get lost in translation. It is intended that Hg
users may wish to use this to collaborate even if no Git users are
involved in the project, and it may even provide some advantages if
you're using Bookmarks (see below).

Dependencies
============

This plugin is implemented entirely in Python — there are no Git
binary dependencies, and you do not need to have Git installed on your
system. The only dependencies are Mercurial 4.4 or later and a
relatively recent Dulwich.

Installing
==========

A common way to install Mercurial extensions is from their Mercurial repository.  I.e. 
clone this repository somewhere and make the ``[extensions]`` section in your ``~/.hgrc``::


   [extensions]
   hggit = [path-to]/hg-git/hggit

That will enable the Hg-Git extension for you.

Alternatively, you can install the plugin using your favourite package manager,
e.g. ``pip3 install hg-git``, but note that you must make sure to use the version of
python that is used by mercurial.  Thus, the safest way to do this with ``pip`` is:

.. code-block:: bash
  
   PYTHON="$(hg debuginstall -T'{pythonexe}')"  # Point PYTHON to the version used by hg
   "$PYTHON" -m pip install --user hg-git       # Drop the --user if you want a system install

With ``hg-git`` visible to mercurial, it can simply be enabled in your ``~/.hgrc`` with::

   [extensions]
   hggit =

.. note::
   
   ``hg-git`` is an extension and can be used with versions of mercurial already
   installed on your system, but, as mentioned above,  needs to be installed so that
   mercurial can find it.  The version of python mercurial uses is listed by::

      hg debuginstall -T'{pythonexe}'

   This is the reason for setting ``PYTHON`` above.  This will work, for example, if you
   are using a version of mercurial installed by the system, which might depends on
   Python 2.7.  Keep in mind that python 2 reached its end of life in April 2020 and
   will not be supported with versions of ``hg-git`` 0.11 and higher (see `issue #349
   <https://foss.heptapod.net/mercurial/hg-git/-/issues/349>`_.

   Perhaps better, install a more recent version of Mercurial along with ``hg-git`` in
   your working python environment using something like::

      python3 -m pip install mercurial hg-git hg-evolve

   This will also ensure that the |evolve_extension|_ is installed, allowing you to use
   topics as outlined in the `Heptapod workflow <https://octobus.net/blog/2019-09-04-heptapod-workflow.html>`_::

      [extensions]
      hggit =
      evolve =
      topics =

.. |evolve_extension| replace:: ``evolve`` extension
.. _evolve_extension: https://www.mercurial-scm.org/wiki/EvolveExtension


Contributing
============

The primary development location for Hg-Git is `Heptapod
<http://foss.heptapod.net/mercurial/hg-git/>`_, and you can follow
their guide on `how to contribute patches
<https://heptapod.net/pages/quick-start-guide.html>`_.

Alternatively, you can follow the `guide on how to contribute to
Mercurial itself
<https://www.mercurial-scm.org/wiki/ContributingChanges>`_, and send
patches to `the list <https://groups.google.com/g/hg-git>`_.

Usage
=====

You can clone a Git repository from Mercurial by running
``hg clone <url> [dest]``. For example, if you were to run::

   $ hg clone git://github.com/hg-git/hg-git.git

Hg-Git would clone the repository and convert it to a Mercurial
repository for you. Other protocols are also supported, see ``hg help
git`` for details.

If you are starting from an existing Mercurial repository, you have to set up a
Git repository somewhere that you have push access to, add a path entry
for it in your .hg/hgrc file, and then run ``hg push [name]`` from
within your repository. For example::

   $ cd hg-git # (a Mercurial repository)
   $ # edit .hg/hgrc and add the target git url in the paths section
   $ hg push

This will convert all your Mercurial data into Git objects and push them to the
Git server.

Now that you have a Mercurial repository that can push/pull to/from a Git
repository, you can fetch updates with ``hg pull``::

   $ hg pull

That will pull down any commits that have been pushed to the server in
the meantime and give you a new head that you can merge in.

Hg-Git pushes your bookmarks up to the Git server as branches and will
pull Git branches down and set them up as bookmarks.

Hg-Git can also be used to convert a Mercurial repository to Git. You
can use a local repository or a remote repository accessed via SSH, HTTP
or HTTPS. Use the following commands to convert the repository, it
assumes you're running this in ``$HOME``::

   $ mkdir git-repo; cd git-repo; git init; cd ..
   $ cd hg-repo
   $ hg bookmarks hg
   $ hg push ../git-repo

The ``hg`` bookmark is necessary to prevent problems as otherwise
hg-git pushes to the currently checked out branch, confusing Git. The
snippet above will create a branch named ``hg`` in the Git repository.
To get the changes in ``master`` use the following command (only
necessary in the first run, later just use ``git merge`` or ``git
rebase``).

::

   $ cd git-repo
   $ git checkout -b master hg

To import new changesets into the Git repository just rerun the ``hg
push`` command and then use ``git merge`` or ``git rebase`` in your Git
repository.

``.gitignore`` and ``.hgignore``
--------------------------------

If present, ``.gitignore`` will be taken into account provided that there is
no ``.hgignore``. In the latter case, the rules from ``.hgignore`` apply,
regardless of what ``.gitignore`` prescribes.

This has been so since version 0.5.0, released in 2013.

Further reading
===============

See ``hg help -e hggit``.

Alternatives
============

Since version 5.4, Mercurial includes an |extension_called_git|_. It
interacts with a Git repository directly, avoiding the intermediate
conversion. This has certain advantages:

.. |extension_called_git| replace:: extension called ``git``
.. _extension_called_git: https://www.mercurial-scm.org/wiki/GitExtension

 * Each commit only has one node ID, which is the Git hash.
 * Data is stored only once, so the on-disk footprint is much lower.

The extension has certain drawbacks, however:

 * It cannot handle all Git repositories. In particular, it cannot
   handle `octopus merges`_, i.e. merge commits with more than two
   parents. If any such commit is included in the history, conversion
   will fail.
 * You cannot interact with Mercurial repositories.
 * Experimental status.

.. _octopus merges: https://git-scm.com/docs/git-merge

Another extension packaged with Mercurial, the ``convert`` extension,
also has Git support.

Other alternatives exist for Git users wanting to access Mercurial
repositories, such as `git-remote-hg`_.

.. _git-remote-hg: https://pypi.org/project/git-remote-hg/

Configuration
=============


``git.authors``
---------------

Git uses a strict convention for "author names" when representing
changesets, using the form ``[realname] [email address]``. Mercurial
encourages this convention as well but is not as strict, so it's not
uncommon for a Mercurial repository to have authors listed as, for example,
simple usernames. hg-git by default will attempt to translate Mercurial
usernames using the following rules:

-  If the Mercurial username fits the pattern ``NAME <EMAIL>``, the Git
   name will be set to NAME and the email to EMAIL.
-  If the Mercurial username looks like an email (if it contains an
   ``@``), the Git name and email will both be set to that email.
-  If the Mercurial username consists of only a name, the email will be
   set to ``none@none``.
-  Illegal characters (stray ``<``\ s or ``>``\ s) will be stripped out,
   and for ``NAME <EMAIL>`` usernames, any content after the
   right-bracket (for example, a second ``>``) will be turned into a
   url-encoded sigil like ``ext:(%3E)`` in the Git author name.

Since these default behaviors may not be what you want (``none@none``,
for example, shows up unpleasantly on GitHub as "illegal email
address"), the ``git.authors`` option provides for an "authors
translation file" that will be used during outgoing transfers from
Mercurial to Git only, by modifying ``hgrc`` as such::

   [git]
   authors = authors.txt

Where ``authors.txt`` is the name of a text file containing author name
translations, one per each line, using the following format::

   johnny = John Smith <jsmith@foo.com>
   dougie = Doug Johnson <dougiej@bar.com>

Empty lines and lines starting with a "#" are ignored.

It should be noted that this translation is in *the Mercurial to Git
direction only*. Changesets coming from Git back to Mercurial will not
translate back into Mercurial usernames, so it's best that the same
username/email combination be used on both the Mercurial and Git sides; the
author file is mostly useful for translating legacy changesets.


``git.blockdotgit``
-------------------

Blocks exporting revisions to Git that contain a directory named .git or
any letter-case variation thereof. This prevents creating repositories
that newer versions of Git and many Git hosting services block due to
security concerns. Defaults to True.


``git.blockdothg``
------------------

Blocks importing revisions from Git that contain a directory named .hg.
Defaults to True.


``git.branch_bookmark_suffix``
------------------------------

Hg-Git does not convert between Mercurial named branches and git
branches as the two are conceptually different; instead, it uses
Mercurial bookmarks to represent the concept of a Git branch.
Therefore, when translating a Mercurial repository over to Git, you
typically need to create bookmarks to mirror all the named branches
that you'd like to see transferred over to Git. The major caveat with
this is that you can't use the same name for your bookmark as that of
the named branch, and furthermore there's no feasible way to rename a
branch in Mercurial. For the use case where one would like to transfer
a Mercurial repository over to Git, and maintain the same named
branches as are present on the hg side, the ``branch_bookmark_suffix``
might be all that's needed. This presents a string "suffix" that will
be recognized on each bookmark name, and stripped off as the bookmark
is translated to a Git branch::

   [git]
   branch_bookmark_suffix=_bookmark

Above, if a Mercurial repository had a named branch called
``release_6_maintenance``, you could then link it to a bookmark called
``release_6_maintenance_bookmark``. hg-git will then strip off the
``_bookmark`` suffix from this bookmark name, and create a Git branch
called ``release_6_maintenance``. When pulling back from Git to hg, the
``_bookmark`` suffix is then applied back, if and only if a Mercurial named
branch of that name exists. E.g., when changes to the
``release_6_maintenance`` branch are checked into Git, these will be
placed into the ``release_6_maintenance_bookmark`` bookmark on hg. But
if a new branch called ``release_7_maintenance`` were pulled over to hg,
and there was not a ``release_7_maintenance`` named branch already, the
bookmark will be named ``release_7_maintenance`` with no usage of the
suffix.

The ``branch_bookmark_suffix`` option is, like the ``authors`` option,
intended for migrating legacy hg named branches. Going forward, a Mercurial
repository that is to be linked with a Git repository should only use bookmarks for
named branching.


``git.findcopiesharder``
------------------------

Whether to consider unmodified files as copy sources. This is a very
expensive operation for large projects, so use it with caution. Similar
to ``git diff``'s --find-copies-harder option.


``git.intree``
--------------

Hg-Git keeps a Git repository clone for reading and updating. By
default, the Git clone is the subdirectory ``git`` in your local
Mercurial repository. If you would like this Git clone to be at the same
level of your Mercurial repository instead (named ``.git``), add the
following to your ``hgrc``::

   [git]
   intree = True


``git.mindate``
---------------

If set, branches where the latest commit's commit time is older than
this will not be imported. Accepts any date formats that Mercurial does
-- see ``hg help dates`` for more.


``git.public``
--------------

A list of Git branches that should be considered "published", and
therefore converted to Mercurial in the 'public' phase. This is only
used if ``hggit.usephases`` is set.


``git.renamelimit``
-------------------

The number of files to consider when performing the copy/rename
detection. Detection is disabled if the number of files modified in a
commit is above the limit. Detection is O(N^2) in the number of files
modified, so be sure not to set the limit too high. Similar to Git's
``diff.renameLimit`` config. The default is "400", the same as Git.


``git.similarity``
------------------

Specify how similar files modified in a Git commit must be to be
imported as Mercurial renames or copies, as a percentage between "0"
(disabled) and "100" (files must be identical). For example, "90" means
that a delete/add pair will be imported as a rename if more than 90% of
the file has stayed the same. The default is "0" (disabled).


``hggit.mapsavefrequency``
--------------------------

Controls how often the mapping between Git and Mercurial commit hashes
gets saved when importing or exporting changesets. Set this to a number
greater than 0 to save the mapping after converting that many commits.
This can help when the conversion encounters an error partway through a
large batch of changes. Defaults to 0, so that the mapping is saved once
at the end.

Please note that this is meaningless for an initial clone, as any
error or interruption will delete the destination. So instead of
cloning a large Git repository, you might want to pull instead::

  $ hg init linux
  $ cd linux
  $ echo "[paths]\ndefault = https://github.com/torvalds/linux" > .hg/hgrc
  $ hg pull

…and be extremely patient. Please note that converting very large
repositories may take *days* rather than mere *hours*, and may run
into issues with available memory for very long running clones. Even
any small, undiscovered leak will build up when processing hundreds of
thousands of files and commits. Cloning the Linux kernel is likely a
pathological case, but other storied repositories such as CPython do
work well, even if the initial clone requires a some patience.

``hggit.usephases``
-------------------

When converting Git revisions to Mercurial, place them in the 'public'
phase as appropriate. Namely, revisions that are reachable from the
remote Git repository's ``HEAD`` will be marked *public*. For most
repositories, this means the remote ``master`` branch will be
converted as public. Publishing commits prevents their modification,
and speeds up many local Mercurial operations, such as ``hg shelve``.
