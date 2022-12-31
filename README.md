# LaTeX configuration file that works with Emacs version 28.2

## Quick start
This configuration supports writing in LaTeX and Org-mode.
Git clone to latex-emacs28 to avoid subsequent editing of file paths.

I have to use chemacs2 to run this profile in parallel to the default configuration because Emacs 28.2 does not support selecting a profile on startup.
I have added the following alias to my .bashAppAliases file in my home directory to start Emacs 28 with this configuration.

```bash
e28ld='/Applications/Emacs28.2.app/Contents/MacOS/Emacs --with-profile latex28 --debug-init'
```

## Rationale
The other configurations that I have posted work with Emacs 29.0.5 or emacs 30.
However, many people use Emacs 28.2 and continue to do so for several years.
There are slight differences in available features.
In addition, the packages have to be compiled with the corresponding version of the elisp compiler.

## Where it works
This configuration works with Mac OS 10.15. 
It should work with Windows and Linux out of the box.
On a 2018 MacBook Pro, Emacs finishes loading and garbage collecting in 17 seconds.

## Notes
- The dashboard does not display in a buffer on startup. Invoke and switch to its buffer with Fn-F1.

- I source my yasnippets snippets folder from my default Emacs configuration by using a softlink to the snippets folder in *~./.emacs.defualt30* so adjust as needed.
I do this so that I only need to maintain one set of snippet files.
This can cause newly added snippets not to appear in the pulldown menu.
Hidden files listing the compiled snippets may be interferring with the addition of new snippets.
The solution is to enter in the snippets directory the following bash command: **rm -rf ./\*/.yas-compiled-snippets.el**. 
Then select **reload everything** from the the yasnippets pulldown menu or enter the correspoinding commands in the mini-buffer: **M-x yas-recompile-all** and **M-x yas-reload-all**.

## Structure of the init.el file
The first part of the `init.el' file has the essential package repository information followed by some basic configurations that are package indepenent.
The second part lists the package configurations in alphabetical order.
The org-aggenda and org-roam sections have my customized capture templates.
You will likely want to adjust to suit or comment out.
You may have to change the paths to the corresponding files.

## Theme
I am using the *ef-day* theme from the *ef-themes* package by Protesilaos Stavro--the humble, accomplished, and inspiring Emacsen of YouTube Fame.

<p align="center"><img src="./images/ef-day-example.png" alt="HTML5 Icon" style="width:819px;height:369px;"></p>
