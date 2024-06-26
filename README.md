![Version](https://img.shields.io/static/v1?label=latexemacs28&message=0.2&color=brightcolor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)


# LaTeX configuration file that works with Emacs version 28.2

## Quick start
This configuration supports writing in LaTeX and Org-mode.
Git clone to latex-emacs28 to avoid subsequent editing of file paths.
I do not hide this folder by prepending its names with a period.

I use [chemacs2](https://github.com/plexus/chemacs2) to run this profile parallel to the default Emacs configuration in `.emacs.default30` because Emacs 28.2 does not support selecting a profile on startup.
I have added the following alias to my .bashAppAliases file in my home directory to start Emacs 28 with this configuration by entering `e28ld`.
I take this approach because I have Emacs versions 28, 29, and 30 installed.

```bash
e28ld='/Applications/Emacs28.2.app/Contents/MacOS/Emacs --with-profile latex28 --debug-init'
```

## Rationale
The other Emacs configurations posted on MooersLab work with Emacs 29.0.5 or 30.0.5. However, many people use Emacs 28.2 and will continue to do so for several years. There are slight differences in the available features of these configurations. In addition, the packages have to be compiled with the corresponding version of the elisp compiler. So far, my `.emacs.default30` folder has been able to serve Emacs 28.2 and 30.0.5. I might have to make separate `.emacs.default` folders for each version.

## Where it works
This configuration works with Mac OS 10.15 and Mac 13.1. It should work with Windows and Linux out of the box. On a 2018 MacBook Pro, Emacs finishes loading and garbage collecting in about 15 seconds on average. You can speed up the startup time by replacing `use-package` with `require`, but the loss of benefits from use-package outweighs the gain in reduced startup time.

## Notes
- The dashboard does not display in a buffer on startup. Invoke and switch to its buffer by entering `Fn-F1`.

- I source my yasnippets snippets folder from my default Emacs configuration by using a soft link to the snippets folder in ~./.emacs.defualt30, so adjust as needed. I do this so that I only need to maintain one set of snippet files. Beware that newly added snippets may not appear in the pulldown menu. Hidden files listing the compiled snippets may be interfering with the addition of new snippets. The solution is to enter in the snippets directory the following bash command: `rm -rf ./*/.yas-compiled-snippets.el`. Then select `reload everything` from the yasnippets pulldown menu or enter these commands in the mini-buffer: `M-x yas-recompile-all` and `M-x yas-reload-all`.

- To use org-pomodoro, you have to create a logbook under a TODO item in an org file with `C-c C-x TAB` and place the cursor (the point) on the headline of the TODO item and enter `C-c o` to start a "pom". I use one of my org-agenda files for this purpose. These are opened in Emacs when I fire up org-agenda with the `C-c a a` keybinding.

## Structure of the init.el file
The first part of the `init.el' file contains the essential package repository information, followed by some basic configurations that are package-independent.
The second part lists the package configurations in alphabetical order.
The org-agenda and org-roam sections have my customized capture templates.
You will likely want to adjust to suit or comment out.
You may have to change the paths to the corresponding files.

## Theme
I am using the *ef-day* theme from the *ef-themes* package by Protesilaos Stavro--the humble, accomplished, and inspiring Emacsen of YouTube Fame.

<p align="center"><img src="./images/ef-day-example.png" alt="HTML5 Icon" style="width:819px;height:369px;"></p>


## Related Projects on MooersLab
- [latex-emacs](https://github.com/MooersLab/latex-emacs) A configuration file supporting the use of LaTeX in Emacs.
- [Slides about Workflow in LaTeX](https://github.com/MooersLab/BerlinEmacsAugust2022) presented to the Berlin Emacs Meetup August 2022. Not recorded. It was 90-minute lecture.
- [Slideshow Template In LaTeX](https://github.com/MooersLab/slideshowTemplateLaTeX) Slideshow template in Beamer makes slides that do not look like they were made in LaTeX.
- [Poster Template In LaTeX](https://github.com/MooersLab/posterInLaTeX) Uses beamer to make a poster via a simple design. Enables whipping together a poster in a few hours. It is much easier than using powerpoint.
- [LaTeX Manuscript Template](https://github.com/MooersLab/manuscriptInLaTeX/edit/main/README.md) Generic template for the first submission of manuscript for peer review as a PDF.
- [Writing Log Template in LaTeX](https://github.com/MooersLab/writingLogTemplate) Place to track progress and plans behind a manuscript.
- [Annotated Bibliography Template in LaTeX](https://github.com/MooersLab/annotatedBibliography) Every writing project needs one of these.
- [Diary for 2023 in LaTeX](https://github.com/MooersLab/diary2023inLaTeX) 
- [Snippets for latex-mode in Emacs](https://github.com/MooersLab/snippet-latex-mode) My LaTeX code snippets for yasnippets.
- [The Writer's Creed](https://github.com/MooersLab/thewriterslaw) Guidelines for greater productivity.


## Update history
|Version      | Changes                                                                                                                                    | Date                 |
|:-----------:|:------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------:|
| Version 0.2 |  Added badges and update table.                                                                                                            | 2024 May 4           |


## Funding
- NIH: R01 CA242845, R01 AI088011
- NIH: P30 CA225520 (PI: R. Mannel); P20GM103640 and P30GM145423 (PI: A. West)
