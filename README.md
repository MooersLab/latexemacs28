# LaTeX configuration file that works with Emacs version 28.2

This configuration supports writing in LaTeX and Org-mode.
Git clone to latex-emacs28 to avoid subsequent editing of file paths.

## Rationale
The other configurations that I have posted work with Emacs 29.0.5 or emacs 30.
However, many people use Emacs 28.2 and continue to do so for several years.
There are slight differences in available features.
In addition, the packages have to be compiled with the corresponding version of the elisp compiler.
This configuration works with Mac OS 10.15. 
It should work with Windows and Linux out of the box.
On a 2018 MacBook Pro, Emacs finishes loading and garbage collecting in 17 seconds.

Note that I source my yasnippets snippets folder from my default Emacs configuration by using a softlink to the snippets folder in `~./.emacs.defualt' so adjust as needed.
I do this so that I only have to maintain one set of snippet files.
This can cause some newly added snippets not to appear in the pulldown menu.
The solution is to ????

I have to use chemacs2 to run this profile in parallel to the default configuration because Emacs 28.2 does not support selecting a profile on startup.
I have added the following alias to my .bashAppAliases file in my home directory to start Emacs 28 with this configuration.

```bash
e28ld='/Applications/Emacs28.2.app/Contents/MacOS/Emacs --with-profile latex28 --debug-init'
```

The first part of the `init.el' file has the essential package repository information followed by some basic configurations that are package indepenent.
The second part lists the package configurations in alphabetical order.
The org-aggenda and org-roam sections have my customized capture templates.
You will likely want to adjust to suit or comment out.
You may have to change the paths to the corresponding files.
