;; ######################################## INSTALL PACKAGES ######################################
(require 'package)

(add-to-list 'package-archives
         '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
         '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
        '("org" . "http://orgmode.org/elpa/") t)  ;; for newest version of org mode


(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(unless (package-installed-p `better-defaults) (package-install `better-defaults))
(unless (package-installed-p `material-theme) (package-install `material-theme))
(unless (package-installed-p `auto-complete) (package-install `auto-complete))



;; automate package updating. It is silly to do this manually.
;; (use-package auto-package-update
;;   :custom
;;   (auto-package-update-interval 31)
;;   (auto-package-update-delete-old-versions t)
;;   (auto-package-update-prompt-before-update t)
;;   (auto-package-update-show-preview t)
;;   :config
;;   (auto-package-update-maybe))


;; *** Straight
;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
  
  
;; ##################################### BASIC CUSTOMIZATION ######################################
(setq inhibit-startup-message t) ;; hide the startup message
;; (load-theme 'material t) ;; load material theme
;; (global-linum-mode t) ;; enable line numbers globally
(set-default 'truncate-lines t) ;; do not wrap
(prefer-coding-system 'utf-8) ;; use UTF-8


;;### Shell configuration
(use-package exec-path-from-shell
  :init
  (setenv "SHELL" "/bin/zsh")
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "GOPATH" "PYTHONPATH"))
  (exec-path-from-shell-initialize))


;; ** Print out the start-time 
;; Source https://systemcrafters.cc/emacs-from-scratch/cut-start-up-time-in-half/
(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                   (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)


(defun buffer-in-window-list ()
  (let (buffers)
    (walk-windows (lambda (window) (push (window-buffer window) buffers)) t t)
    buffers))

(defun display-all-buffers ()
  (interactive)
  (let (buffers-in-window (buffer-in-window-list))
    (dolist (buffer (buffer-list))
      (when (and (not (string-match "\\`[[:space:]]*\\*" (buffer-name buffer)))
                 (not (memq buffer buffers-in-window)))
        (set-window-buffer (split-window (get-largest-window)) buffer)))
    (balance-windows)))
(global-unset-key (kbd "C-x C-b"))


;;### Faked full screen
(use-package maxframe
     :ensure t)
(defvar my-fullscreen-p t "Check if fullscreen is on or off")
(defun my-toggle-fullscreen ()
  (interactive)
  (setq my-fullscreen-p (not my-fullscreen-p))
  (if my-fullscreen-p
	  (restore-frame)
	(maximize-frame)))
;; (global-set-key (kbd "M-RET") 'toggle-frame-fullscreen) ;; conflicts with an auctex command to insert an \item in a list.

;;### Turn on font-locking or syntax highlighting
(global-font-lock-mode t)

;;### font size in the modeline
(set-face-attribute 'mode-line nil  :height 140)

;; set default coding of buffers
(setq default-buffer-file-coding-system 'utf-8-unix)

;; Switch from tabs to spaces for indentation
;; Set the indentation level to 4.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)


;;### hippie-expand M-/
(global-set-key [remap dabbrev-expand]  'hippie-expand)


;; GUI related settings
(if (display-graphic-p)
    (progn
      ;; Removed some UI elements
      ;; (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      ;; Show battery status
      (display-battery-mode 1)))


;; Hey, stop being a whimp and learn the Emacs keybindings!
;; ;; Set copy+paste 
;;  (cua-mode t)
;;     (setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
;;     (transient-mark-mode 1) ;; No region when it is not highlighted
;;     (setq cua-keep-region-after-copy t) ;; Standard Windows behaviour

;; REMOVE THE SCRATCH BUFFER AT STARTUP
;; Makes *scratch* empty.
;; (setq initial-scratch-message "")
;; Removes *scratch* from buffer after the mode has been set.
;; (defun remove-scratch-buffer ()
;;   (if (get-buffer "*scratch*")
;;       (kill-buffer "*scratch*")))
;; (add-hook 'after-change-major-mode-hook 'remove-scratch-buffer)


;; Disable the C-z sleep/suspend key
;; See http://stackoverflow.com/questions/28202546/hitting-ctrl-z-in-emacs-freezes-everything
(global-unset-key (kbd "C-z"))

;; Disable the C-x C-b key, use helm (C-x b) instead
;; (global-unset-key (kbd "C-x C-b"))


;; Make copy and paste use the same clipboard as emacs.
(setq select-enable-primary t
      select-enable-clipboard t)


(setq display-time-default-load-average nil)
(setq display-time-day-and-date t display-time-24hr-format t)
(display-time-mode t)


;; delete word under point
;; https://stackoverflow.com/questions/33442027/how-to-deleteor-kill-the-current-word-in-emacs

(defun my-kill-thing-at-point (thing)
  "Kill the `thing-at-point' for the specified kind of THING."
  (let ((bounds (bounds-of-thing-at-point thing)))
    (if bounds
        (kill-region (car bounds) (cdr bounds))
      (error "No %s at point" thing))))

(defun my-kill-word-at-point ()
  "Kill the word at point."
  (interactive)
  (my-kill-thing-at-point 'word))

(global-set-key (kbd "s-w") 'my-kill-word-at-point)

;; dired-icon-mode

(add-hook 'dired-mode-hook 'dired-icon-mode)

;; replace dired with dirvish
(dirvish-override-dired-mode)


;; Revert Dired and other buffers after changes to files in directories on disk.
;; Source: [[https://www.youtube.com/watch?v=51eSeqcaikM&list=PLEoMzSkcN8oNmd98m_6FoaJseUsa6QGm2&index=2][Dave Wilson]]
(setq global-auto-revert-non-file-buffers t)




;; customize powerline
;; (line above the command line at the bottom of the screen)
(use-package powerline
  :ensure t)
(require 'powerline)
(powerline-default-theme)


;; Add line numbers.
;; (global-nlinum-mode t)

;; highlight current line
(global-hl-line-mode +1)
(set-face-background hl-line-face "#1c1f26")
(set-face-attribute 'mode-line nil  :height 360)

;; List recently opened files.
(recentf-mode 1)


;; Revert buffers when the underlying file has changed.
(global-auto-revert-mode 1)


;; Save history going back 25 commands.
;; Use M-p to get previous command used in the minibuffer.
;; Use M-n to move to next command.
(setq history-length 25)
(savehist-mode 1)


;; Save place in a file.
(save-place-mode 1)


;; sets monday to be the first day of the week in calendar
(setq calendar-week-start-day 1)

;; save emacs backups in a different directory
;; (some build-systems build automatically all files with a prefix, and .#something.someending breakes that)
(setq backup-directory-alist '(("." . "~/.emacsbackups")))


;; Enable show-paren-mode (to visualize paranthesis) and make it possible to delete things we have marked
(show-paren-mode 1)
(delete-selection-mode 1)


;; use y or n instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; These settings enables using the same configuration file on multiple platforms.
;; Note that windows-nt includes [[https://www.gnu.org/software/emacs/manual/html_node/elisp/System-Environment.html][windows 10]].
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))
(defconst *is-windows* (eq system-type 'windows-nt))
(defconst *is-cygwin* (eq system-type 'cygwin))
(defconst *is-unix* (not *is-windows*))


;; See this [[http://ergoemacs.org/emacs/emacs_hyper_super_keys.html][ for more information.]]
;; set keys for Apple keyboard, for emacs in OS X 
;; Source http://xahlee.info/emacs/emacs/emacs_hyper_super_keys.html
(setq mac-command-modifier 'meta) ; make cmd key do Meta
(setq mac-option-modifier 'super) ; make option key do Super. 
(setq mac-control-modifier 'control) ; make Control key do Control
(setq mac-function-modifier 'hyper)  ; make Fn key do Hyper. Only works on Apple produced keyboards.  
(setq mac-right-command-modifier 'hyper)


;; Switch to previous buffer
(define-key global-map (kbd "s-<left>") 'previous-buffer)
;; Switch to next buffer
(define-key global-map (kbd "s-<right>") 'next-buffer)


;; Minibuffer history keybindings
;; The calling up of a previously issued command in the minibuffer with ~M-p~ saves times.
(autoload 'edit-server-maybe-dehtmlize-buffer "edit-server-htmlize" "edit-server-htmlize" t)
(autoload 'edit-server-maybe-htmlize-buffer "edit-server-htmlize" "edit-server-htmlize" t)
(add-hook 'edit-server-start-hook 'edit-server-maybe-dehtmlize-buffer)
(add-hook 'edit-server-done-hook  'edit-server-maybe-htmlize-buffer)
(define-key minibuffer-local-map (kbd "M-p") 'previous-complete-history-element)
(define-key minibuffer-local-map (kbd "M-n") 'next-complete-history-element)
(define-key minibuffer-local-map (kbd "<up>") 'previous-complete-history-element)
(define-key minibuffer-local-map (kbd "<down>") 'next-complete-history-element)


;; Bibtex configuration
(defconst blaine/bib-libraries (list "~/Documents/global.bib")) 

;; Combined with emacs-mac, this gives good PDF quality for [[https://www.aidanscannell.com/post/setting-up-an-emacs-playground-on-mac/][retina display]].
(setq pdf-view-use-scaling t)


;; PDF default page width behavior
(setq-default pdf-view-display-size 'fit-page)


;; Set delay in the matching parenthesis to zero.
(setq show-paren-delay 0)
(show-paren-mode t)


;; rainbow-delimiters
(use-package rainbow-delimiters
      :ensure t)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
(set-face-attribute 'rainbow-delimiters-unmatched-face nil
            :foreground "magenta"
            :inherit 'error
            :box t)



;; ############################## Package Configurations ################################

;;## A

;; *** ado-mode 
;; Package for working with stata files from Emacs.

(use-package ado-mode
    :ensure t)

;;### auto-complete
;; do default config for auto-complete
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)
(ac-flyspell-workaround)



;;;### auto-complete-auctex.el --- auto-completion for auctex

;; Copyright (C) 2012 Christopher Monsanto
     
;; Author: Christopher Monsanto <chris@monsan.to>
;; Version: 1.0
;; Package-Requires: ((yasnippet "0.6.1") (auto-complete "1.4"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; You can install this by (require 'auto-complete-auctex).
;; Feel free to contribute better documentation!

;;;#### Code:

(require 'tex)
(require 'latex)

(eval-when-compile
  (require 'auto-complete)
  (require 'yasnippet))

(defvar ac-auctex-arg-lookup-table
  '((TeX-arg-define-macro . ("\\MacroName"))
    (TeX-arg-counter . ("Counter"))
    (TeX-arg-define-counter . ("\\CounterName"))
    (TeX-arg-file . ("Filename"))
    (TeX-arg-bibliography . ("Filename"))
    (TeX-arg-bibstyle . ("Style"))
    (TeX-arg-environment . ("Environment"))
    (TeX-arg-define-environment . ("EnvironmentName"))
    (TeX-arg-size . ("(w, h)"))
    (TeX-arg-ref . ("Name"))
    (TeX-arg-index . ("Index"))
    (TeX-arg-define-label . ("Label"))
    (LaTeX-arg-usepackage . (["opt1,..."] "Package"))
    (LaTeX-env-label . nil)
    (LaTeX-amsmath-env-aligned . (["htbp!"]))
    (LaTeX-amsmath-env-alignat . (["# Columns"]))
    (LaTeX-env-array . (["bct"] "lcrpmb|"))
    (LaTeX-env-item . nil)
    (LaTeX-env-document . nil)
    (LaTeX-env-figure . (["htbp!"]))
    (LaTeX-env-contents . ("Filename"))
    (LaTeX-env-minipage . (["htbp!"] "Width"))
    (LaTeX-env-list . ("Label" "\\itemsep,\\labelsep,..."))
    (LaTeX-env-picture . ("(w, h)" "(x, y)"))
    (LaTeX-env-tabular* . ("Width" ["htbp!"] "lcrpmb|><"))
    (LaTeX-env-bib . ("WidestLabel"))
    (TeX-arg-conditional . ([""]))
    (2 . ("" ""))
    (3 . ("" "" ""))
    (4 . ("" "" "" ""))
    (5 . ("" "" "" "" ""))
    (6 . ("" "" "" "" "" ""))
    (7 . ("" "" "" "" "" "" ""))
    (8 . ("" "" "" "" "" "" "" ""))
    (9 . ("" "" "" "" "" "" "" "" "")))
  "Anything not in this table defaults to '(\"\")")

(defun ac-auctex-expand-arg-info (arg-info)
  (loop for item in arg-info
	append (cond
		((or (stringp item) (and (vectorp item) (stringp (elt item 0))))
		 (list item))
		((vectorp item)
		 (loop for item-2 in (or (assoc-default (or (car-safe (elt item 0)) (elt item 0))
							ac-auctex-arg-lookup-table 'equal) '(""))
		       collect [item-2]))
		(t
		 (or (assoc-default (or (car-safe item) item) ac-auctex-arg-lookup-table) '(""))))))

(defun ac-auctex-snippet-arg (n arg)
  (let* ((opt (vectorp arg))
	 (item (if opt (elt arg 0) arg))
	 (m (if (vectorp arg) (1+ n) n))
	 (var (format "${%s}" item)))
    (list (1+ m)
	  (if opt
	      (concat (format "${[") var "]}")
	    (concat "{" var "}")))))

;;;#### Macros
;;

(defun ac-auctex-expand-args (str env)
  (yas/expand-snippet (ac-auctex-macro-snippet (assoc-default str env))))

(defun ac-auctex-macro-snippet (arg-info)
  (let ((count 1))
    (apply 'concat (loop for item in (ac-auctex-expand-arg-info arg-info)
			 collect (destructuring-bind (n val)
				     (ac-auctex-snippet-arg count item)
				   (setq count n)
				   val)))))

(defun ac-auctex-macro-candidates ()
   (let ((comlist (if TeX-symbol-list
		      (mapcar (lambda (item)
			        (or (car-safe (car item)) (car item)))
			    TeX-symbol-list))))
    (all-completions ac-prefix comlist)))

(defun ac-auctex-macro-action ()
  (yas/expand-snippet (ac-auctex-macro-snippet (assoc-default candidate TeX-symbol-list)))) 

(ac-define-source auctex-macros
  '((init . TeX-symbol-list)
    (candidates . ac-auctex-macro-candidates)
    (action . ac-auctex-macro-action)
    (requires . 0)
    (symbol . "m")
    (prefix . "\\\\\\([a-zA-Z]*\\)\\=")))

;;;#### Symbols

(defun ac-auctex-symbol-candidates ()
  (all-completions ac-prefix (mapcar 'cadr LaTeX-math-default)))

(defun ac-auctex-symbol-action ()
  (re-search-backward candidate)
  (delete-region (1- (match-beginning 0)) (match-end 0))
  (if (texmathp)
      (progn
	(insert "\\" candidate)
	(yas/expand-snippet (ac-auctex-macro-snippet (assoc-default candidate TeX-symbol-list))))
    (insert "$\\" candidate "$")
    (backward-char)
    (yas/expand-snippet (ac-auctex-macro-snippet (assoc-default candidate TeX-symbol-list)))))

(defun ac-auctex-symbol-document (c)
  (let* ((cl (assoc c (mapcar 'cdr LaTeX-math-default)))
         (decode (if (nth 2 cl) (char-to-string (decode-char 'ucs (nth 2 cl))) ""))
         (st (nth 1 cl))
         (hs (if (listp st) (mapconcat 'identity st " ") st)))
    (and decode (concat hs " == " decode))))

(ac-define-source auctex-symbols
  '((init . LaTeX-math-mode)
    (candidates . ac-auctex-symbol-candidates)
    (document . ac-auctex-symbol-document)
    (action . ac-auctex-symbol-action)
    (requires . 0)
    (symbol . "s")
    (prefix . "\\\\\\([a-zA-Z]*\\)\\=")))


;;;#### Environments

(defvar ac-auctex-environment-prefix "beg")

(defun ac-auctex-environment-candidates ()
  (let ((envlist (mapcar (lambda (item) (concat ac-auctex-environment-prefix (car item)))
			 LaTeX-environment-list)))
    (all-completions ac-prefix envlist)))

(defun ac-auctex-environment-action ()
  (re-search-backward candidate)
  (delete-region (1- (match-beginning 0)) (match-end 0))
  (let ((candidate (substring candidate (length ac-auctex-environment-prefix))))
    (yas/expand-snippet (format "\\begin{%s}%s\n$0\n\\end{%s}"
				candidate
				(ac-auctex-macro-snippet (assoc-default candidate LaTeX-environment-list))
				candidate)))) 

(ac-define-source auctex-environments
  '((init . LaTeX-environment-list)
    (candidates . ac-auctex-environment-candidates)
    (action .  ac-auctex-environment-action)
    (requires . 0)
    (symbol . "e")
    (prefix . "\\\\\\([a-zA-Z]*\\)\\=")))


;;;#### Refs

(defun ac-auctex-label-candidates ()
  (all-completions ac-prefix (mapcar 'car LaTeX-label-list)))

(ac-define-source auctex-labels
  '((init . LaTeX-label-list)
    (candidates . ac-auctex-label-candidates)
    (requires . 0)
    (symbol . "r")
    (prefix . "\\\\ref{\\([^}]*\\)\\=")))


;;;#### Bibs

(defun ac-auctex-bib-candidates ()
  (all-completions ac-prefix (mapcar 'car LaTeX-bibitem-list)))

(ac-define-source auctex-bibs
  `((init . LaTeX-bibitem-list)
    (candidates . ac-auctex-bib-candidates)
    (requires . 0)
    (symbol . "b")
    (prefix . ,(concat "\\\\cite"
		       "\\(?:"
		         "\\[[^]]*\\]"
		       "\\)?"
		       "{\\([^},]*\\)"
		       "\\="))))

;;;#### Setup

(defun ac-auctex-setup ()
  (setq ac-sources (append
                      '(ac-source-auctex-symbols
                        ac-source-auctex-macros
			ac-source-auctex-environments
			ac-source-auctex-labels
			ac-source-auctex-bibs)
                      ac-sources)))

(add-to-list 'ac-modes 'latex-mode)
(add-hook 'LaTeX-mode-hook 'ac-auctex-setup)

(provide 'auto-complete-auctex)

;;; auto-complete-auctex.el ends here

;; indent with spaces instead of tabs for pep8 compatibility
(setq tab-width 4)
(setq-default indent-tabs-mode nil)

;; atomic-chrome, used to interact with GhostText extension for Google Chrome.
(use-package atomic-chrome
      :ensure t)
;; (atomic-chrome-start-server)
(setq atomic-chrome-default-major-mode 'python-mode)
(setq atomic-chrome-extension-type-list '(ghost-text))
;;(atomic-chrome-start-httpd)
(setq atomic-chrome-server-ghost-text-port 4001)
(setq atomic-chrome-url-major-mode-alist
      '(("github\\.com" . gfm-mode)
        ("overleaf.com" . latex-mode)
        ("750words.com" . latex-mode)))
; Select the style of opening the editing buffer by atomic-chrome-buffer-open-style.
; full: Open in the selected window.
; split: Open in the new window by splitting the selected window (default).
; frame: Create a new frame and window in it. Must be using some windowing pacakge.
(setq atomic-chrome-buffer-open-style 'split)


;; awesome-tab
(use-package awesome-tab
  :load-path "~/latex-emacs28/elisp/awesome-tab"
  :config
  (awesome-tab-mode t))




;; avy
;; Navigate buffer after selecting all sites starting with the same one or two letters.
;; After entering the avy command in the minibuffer, selected sites will be highlighted but they will be indexed with letters.
;; Enter a letter to go to a desired site.
;; See https://github.com/abo-abo/avy for documentation. 
;; 

(use-package avy
    :ensure t
    :bind ("M-s" . avy-goto-char)
         ("M-d" . avy-goto-char-2)
         ("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
)

;;## B


;;### bibtex-mode related
;; Fetch bibtex for the given DOI. Insert at point, which should be in your global.bib file.
;; Needs code to reformat the bibtex key.
;;
;; https://www.anghyflawn.net/blog/2014/emacs-give-a-doi-get-a-bibtex-entry/

(defun get-bibtex-from-doi (doi)
 "Get a BibTeX entry from the DOI"
 (interactive "MDOI: ")
 (let ((url-mime-accept-string "text/bibliography;style=bibtex"))
   (with-current-buffer 
     (url-retrieve-synchronously 
       (format "http://dx.doi.org/%s" 
       	(replace-regexp-in-string "http://dx.doi.org/" "" doi)))
     (switch-to-buffer (current-buffer))
     (goto-char (point-max))
     (setq bibtex-entry 
     	  (buffer-substring 
          	(string-match "@" (buffer-string))
              (point)))
     (kill-buffer (current-buffer))))
 (insert (decode-coding-string bibtex-entry 'utf-8))
 (define-key bibtex-mode-map (kbd "C-c C-b") 'get-bibtex-from-doi)
 (bibtex-fill-entry))
;; I want run the above function to define it upon entry into a Bibtex file. 
(add-hook
   'bibtex-mode-hook
   (lambda ()
       (get-bibtex-from-doi nil)))

;; Hook to add imenu to menubar in bibtex mode
;; http://www.jonathanleroux.org/bibtex-mode.html
(add-hook
  'bibtex-mode-hook
  (lambda ()
    (imenu-add-to-menubar "Imenu")))

;; Fetch bibtex information from DOI.
;; Source https://chainsawriot.com/postmannheim/2022/12/13/aoe13.html
;; Copy the DOI from Firefox (or any source)
;; 1. Go back to emacs (By C . e)
;; 2. Run the custom command: M-x add-doi and paste yank the DOI (C-y)
;; 3. Auto: Fetch the BIBTEX
;; 4. from Crossref
;; 5. Auto: Add it into “~/dev/dotfiles/bib.bib”
;; 6. Save it
(defun add-doi ()
  (interactive)
  (progn
    (setq doi-to-query (read-string "DOI "))
    (find-file "~/Documents/global.bib")
    (end-of-buffer)
    (doi-insert-bibtex doi-to-query)
    )
  )

(use-package biblio
      :ensure t
  :config
  (setq-default
   biblio-bibtex-use-autokey t
   bibtex-autokey-name-year-separator ""
   bibtex-autokey-year-title-separator ""
   bibtex-autokey-year-length 4
   bibtex-autokey-titlewords 7
   bibtex-autokey-titleword-length -1 ;; -1 means exactly one
   bibtex-autokey-titlewords-stretch 0
   bibtex-autokey-titleword-separator ""
   bibtex-autokey-titleword-case-convert 'upcase)
  )


;; ** C

(setq org-babel-clojure-backend 'cider)
(use-package cider
 :ensure t)
(setq org-edit-src-content-indentation 0
     org-src-tab-acts-natively t
     org-src-fontify-natively t
     org-confirm-babel-evaluate nil)
(setq nrepl-hide-special-buffers t
     cider-repl-pop-to-buffer-on-connect nil
     cider-popup-stacktraces nil
     cider-repl-popup-stacktraces t)

;; Useful keybindings when using Clojure from Org
;; (org-defkey org-mode-map "\C-x\C-e" 'cider-eval-last-sexp)
;; (org-defkey org-mode-map "\C-c\C-d" 'cider-doc)


;; git clone --single-branch --branch correlations-heatmap https://github.com/BlaineMooersLab/clojure-sandbox.git
;; (inspired by: https://github.com/clojure-emacs/cider/issues/3094)
;;(require 'cider-mode)

(defun cider-tap (&rest r) ; inspired by https://github.com/clojure-emacs/cider/issues/3094
  (cons (concat "(let [__value "
                (caar r)
                "] (tap> {:clay-tap? true :form (quote " (caar r) ") :value __value}) __value)")
        (cdar r)))

(advice-add 'cider-nrepl-request:eval
:filter-args #'cider-tap)


;; Clay related functions from Daniel Slutsky
;; https://scicloj.github.io/clay/#Setup

(defun scittle-show ()
  (interactive)
  (save-buffer)
  (let
      ((filename
        (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(scicloj.clay.v2.api/show-doc! \"" filename "\" {})")))))
(define-key clojure-mode-map "\C-c\C-s" 'scittle-show)

(defun scittle-show-and-write ()
  (interactive)
  (save-buffer)
  (let
      ((filename
        (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(scicloj.clay.v2.api/show-doc-and-write-html! \"" filename "\" {:toc? true})")))))
(define-key clojure-mode-map "\C-c\C-w" 'scittle-show-and-write)


;; Clerk is another "notebook"--really a brower interface
;;

(defun clerk-show ()
  (interactive)
  (when-let
      ((filename
        (buffer-file-name)))
    (save-buffer)
    (cider-interactive-eval
     (concat "(nextjournal.clerk/show! \"" filename "\")"))))

(define-key clojure-mode-map (kbd "<M-return>") 'clerk-show)
  




;; ** D 

;; Getting pretty icons 
(use-package all-the-icons
      :ensure t)

(use-package dashboard
  :ensure t    
  :init
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-banner-logo-title "Let's get stuff done!")
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-set-navigator t)
;;   (dashboard-navigator-buttons '((("⤓" " Install system package" " Install system package" (lambda (&rest _) (helm-system-packages))))))
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-items '((projects . 10)
                     (recents . 15)
                     (hackernews . 5))))

(use-package dashboard-hackernews
      :ensure t)

(defun new-dashboard ()
  "Jump to the dashboard buffer. If it doesn't exist, create one. Refresh while at it."
  (interactive)
  (switch-to-buffer dashboard-buffer-name)
  (dashboard-mode)
  (dashboard-insert-startupify-lists)
  (dashboard-refresh-buffer))
(global-set-key (kbd "<f1>") 'new-dashboard)


;;# ** Dired related
(use-package dired-subtree 
  :ensure t
  :after dired
  :config
  (bind-key "<tab>" #'dired-subtree-toggle dired-mode-map)
  (bind-key "<backtab>" #'dired-subtree-cycle dired-mode-map))


;; *** dot-mode
;; This minor mode enables the use of C-. to repeat the last command.
;; I want to mimic this great Vi command enabled globally.

(use-package dot-mode
    :ensure t)
(global-dot-mode t)



;; ** E

;; *** ef-theme
;; by Protesilaos Stavro

(use-package ef-themes
    :ensure t)
;; If you like two specific themes and want to switch between them, you
;; can specify them in `ef-themes-to-toggle' and then invoke the command
;; `ef-themes-toggle'.  All the themes are included in the variable
;; `ef-themes-collection'.
(setq ef-themes-to-toggle '(ef-light ef-summer ef-winter))

;; Make customisations that affect Emacs faces BEFORE loading a theme
;; (any change needs a theme re-load to take effect).

(setq ef-themes-headings ; read the manual's entry or the doc string
      '((0 . (variable-pitch light 1.9))
        (1 . (variable-pitch light 1.8))
        (2 . (variable-pitch regular 1.7))
        (3 . (variable-pitch regular 1.6))
        (4 . (variable-pitch regular 1.5))
        (5 . (variable-pitch 1.4)) ; absence of weight means `bold'
        (6 . (variable-pitch 1.3))
        (7 . (variable-pitch 1.2))
        (t . (variable-pitch 1.1))))

;; They are nil by default...
(setq ef-themes-mixed-fonts t
      ef-themes-variable-pitch-ui t)

;; Disable all other themes to avoid awkward blending:
(mapc #'disable-theme custom-enabled-themes)

;; Load the theme of choice:
(load-theme 'ef-day :no-confirm)

;; The themes we provide:
;;
;; Light: `ef-day', `ef-light', `ef-spring', `ef-summer'.
;; Dark:  `ef-autumn', `ef-dark', `ef-night', `ef-winter'.
;;
;; Also those which are optimized for deuteranopia (red-green color
;; deficiency): `ef-deuteranopia-dark', `ef-deuteranopia-light'.

;; We also provide these commands, but do not assign them to any key:
;;
;; - `ef-themes-toggle'
;; - `ef-themes-select'
;; - `ef-themes-load-random'
;; - `ef-themes-preview-colors'
;; - `ef-themes-preview-colors-current'#+END_SRC



;; *** Electric-pair mode. Add matching pairs of quotes and parentheses.
(electric-pair-mode)


;; *** electric-spacing
;; An emacs minor-mode to automatically add spacing around [[https://github.com/xwl/electric-spacing][operators] in math expressions.].
;; Backspace over the whitespaces to remove them when none are permitted.
(use-package electric-spacing
      :ensure t)

;; git clone https://github.com/walmes/electric-spacing.git into .emacs.default30/elisp
;; byte-compile with (byte-compile-file "~/latex-emacs28/elisp/electric-spacing/electric-spacing.el")
;; byte-compile with (byte-compile-file "~/latex-emacs28/elisp/electric-spacing/electric-spacing-r.el")
(add-to-list 'load-path "~/latex-emacs28/elisp/electric-spacing")
(require 'electric-spacing-r)
(add-hook 'ess-mode-hook #'electric-spacing-mode)
;; restrict to limited number of modes to keep it out of the minibuffer
(defvar my-electic-pair-modes '(python-mode julia-mode org-mode latex-mode))
(defun my-inhibit-electric-pair-mode (char)
  (not (member major-mode my-electic-pair-modes)))
(setq electric-pair-inhibit-predicate #'my-inhibit-electric-pair-mode)


;; *** Emojis
(use-package emojify
      :ensure t
  :init
  (add-hook 'after-init-hook #'global-emojify-mode))


;; Eros: Evaluation Result OverlayS for Emacs Lisp.
;; Eros is on MELPA.
;; Eros is by Tianxiang Xiong.
;; He has developed two other Emacs Lisp Packages.
;; https://github.com/xiongtx/eros
;; Eros provides Cider like behavoir for elisp with the output resturned in-line.
;; I learned about eros from yantar92 during the 2023-01-01 meeting of Mastering Emacs bookclub.

(use-package eros
      :ensure t
      :init
      (eros-mode 1))


;; *** eshell related functions
;; source: Mickey Petersen https://www.masteringemacs.org/article/pcomplete-context-sensitive-completion-emacs
(defconst pcmpl-git-commands
  '("add" "bisect" "branch" "checkout" "clone"
    "commit" "diff" "fetch" "grep"
    "init" "log" "merge" "mv" "pull" "push" "rebase"
    "reset" "rm" "show" "status" "tag" )
  "List of `git' commands.")

(defvar pcmpl-git-ref-list-cmd "git for-each-ref refs/ --format='%(refname)'"
  "The `git' command to run to get a list of refs.")

(defun pcmpl-git-get-refs (type)
  "Return a list of `git' refs filtered by TYPE."
  (with-temp-buffer
    (insert (shell-command-to-string pcmpl-git-ref-list-cmd))
    (goto-char (point-min))
    (let ((ref-list))
      (while (re-search-forward (concat "^refs/" type "/\\(.+\\)$") nil t)
        (add-to-list 'ref-list (match-string 1)))
      ref-list)))

(defun pcomplete/git ()
  "Completion for `git'."
  ;; Completion for the command argument.
  (pcomplete-here* pcmpl-git-commands)
  ;; complete files/dirs forever if the command is `add' or `rm'
  (cond
   ((pcomplete-match (regexp-opt '("add" "rm")) 1)
    (while (pcomplete-here (pcomplete-entries))))
   ;; provide branch completion for the command `checkout'.
   ((pcomplete-match "checkout" 1)
    (pcomplete-here* (pcmpl-git-get-refs "heads")))))





;; ** F


;; *** FlySpell (spell checking)
(dolist (flyspellmodes '(text-mode-hook
					   org-mode-hook
					   latex-mode-hook))
(add-hook flyspellmodes 'turn-on-flyspell))

;; comments and strings in code
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; sets american english as defult 
(setq ispell-dictionary "american")

;; let us cycle american english (best written english) and norwegian 
(defun change-dictionary ()
(interactive)
(ispell-change-dictionary (if (string-equal ispell-current-dictionary "american")
							  "norsk"
							"american")))

;; helm functionality for flyspell. To make it more user friendly
(use-package helm-flyspell
      :ensure t
:after flyspell
:init
;; Disable standard keys for flyspell correct, and make my own for helm.
(define-key flyspell-mode-map (kbd "C-.") nil)
(define-key flyspell-mode-map (kbd "C-,") #'helm-flyspell-correct))


;; *** Focus
;; Highlights the current section or function.
(use-package focus
      :ensure t)

;; ** G

;; Source: https://github.com/emacs-gnuplot/gnuplot


;; M-x gnuplot-mode : start gnuplot-mode in the current buffer
;; M-x gnuplot-make-buffer : open a new buffer (which is not visiting a file) and start gnuplot-mode in that buffer

;; When gnuplot-mode is on, the following keybindings are available:
;; C-c C-l	send current line to gnuplot
;; C-c C-v	send current line to gnuplot and move forward 1 line
;; C-c C-r	send current region to gnuplot
;; C-c C-b	send entire buffer to gnuplot
;; C-c C-f	send a file to gnuplot
;; C-c C-i	insert filename at point
;; C-c C-n	negate set option on current line
;; C-c C-c	comment region
;; C-c C-o	set arguments for command at point
;; S-mouse-2	set arguments for command under mouse cursor
;; C-c C-d	read the gnuplot info file
;; C-c C-e	show-gnuplot-buffer
;; C-c C-k	kill gnuplot process
;; C-c C-z	customize gnuplot-mode
;; M-tab or M-ret	complete keyword before point
;; ret	newline and indent
;; tab	indent current line
;; 
;; With the exception of the commands for sending commands to Gnuplot, most of the above commands also work in the Gnuplot comint buffer, in addition to the following:
;; M-C-p	plot the most recent script buffer line-by-line
;; M-C-f	save the current script buffer and load that file
;; C-c C-e	pop back to most recent script buffer

(add-to-list 'Info-default-directory-list "/opt/local/bin/gnuplot")

;; (autoload 'gnuplot-mode "gnuplot" "Gnuplot major mode" t)
;; (autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot-mode" t)
;; (setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode)) auto-mode-alist))


;; ** H
;; *** Helm
;; Use ivy or helm but not both.
;; (use-package helm
;;  :after (projectile helm-projectile)
;;
;;  :init
;;  (helm-mode 1)
;;  (projectile-mode +1)
;;  (helm-projectile-on)
;;  (helm-adaptive-mode 1)
;;  ;; hide uninteresting buffers from buffer list
;;  (add-to-list 'helm-boring-buffer-regexp-list (rx "magit-"))
;;  (add-to-list 'helm-boring-buffer-regexp-list (rx "*helm"))
;;
;;  :custom
;;  (helm-M-x-fuzzy-match t)
;;  (projectile-completion-system 'helm)
;;  (helm-split-window-in-side-p t)
;;
;;  :bind
;;  (("M-x" . helm-M-x)
;;   ("C-x C-f" . helm-find-files)
;;   ;; get the awesome buffer list instead of the standard stuff
;;   ("C-x b" . helm-mini)))
;;
;;;; *** helm-system-packages
;;;;(use-package helm-system-packages
;;;;    :after helm)
;;
;;;; *** Helm-bibtex
;;;; Can only use helm-bitex or ivy-bibtex
;;;; See https://github.com/tmalsburg/helm-bibtex for extensive documentation and configuration.
;;(use-package helm-bibtex
;;    :ensure t
;;    :config
;;    (setq bibtex-completion-library-path '("~/0labeledPapers" "~/0bookaLabeled"))
;;    (setq bibtex-completion-pdf-field "File")
;;    (setq bibtex-completion-notes-path '("~/0labeledPapers/notes" "~/0papersLabeled/notes"))
;;    (setq org-cite-follow-processor 'helm-bibtex-org-cite-follow)
;;    (setq bibtex-completion-display-formats
;;        '((article       . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${journal:40}")
;;          (inbook        . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
;;          (incollection  . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
;;          (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
;;          (t             . "${=has-pdf=:1}${=has-note=:1} ${=type=:3} ${year:4} ${author:36} ${title:*}")))
;;    (setq bibtex-completion-additional-search-fields '(keywords))
;;    (setq bibtex-completion-pdf-symbol "⌘")
;;    (setq bibtex-completion-notes-symbol "✎")
;;    (setq bibtex-completion-pdf-open-function
;;      (lambda (fpath)
;;        (call-process "open" nil 0 nil "-a" "/Applications/Skim.app" fpath)))
;;    (setq bibtex-completion-find-additional-pdfs t)
;;    (setq bibtex-completion-browser-function
;;      (lambda (url _) (start-process "firefox" "*firefox*" "firefox" url)))
;;      (setq bibtex-completion-format-citation-functions
;;        '((org-mode      . bibtex-completion-format-citation-org-title-link-to-PDF)
;;          (latex-mode    . bibtex-completion-format-citation-cite)
;;          (markdown-mode . bibtex-completion-format-citation-pandoc-citeproc)
;;          (default       . bibtex-completion-format-citation-default)))
;;      (setq bibtex-completion-additional-search-fields '(tags))
;;)
;; 
;;;; (require 'helm-config)
;;;; 
;;(global-set-key (kbd "<menu>") 'helm-command-prefix)
;;
;;(define-key helm-command-map "b" 'helm-bibtex)
;;(define-key helm-command-map "B" 'helm-bibtex-with-local-bibliography)
;;(define-key helm-command-map "n" 'helm-bibtex-with-notes)
;;(define-key helm-command-map (kbd "<menu>") 'helm-resume)
;;
;;(defun helm-bibtex-my-publications (&optional arg)
;;  "Search BibTeX entries authored by “Blaine Mooers”.
;;
;;With a prefix ARG, the cache is invalidated and the bibliography reread."
;;  (interactive "P")
;;  (helm-bibtex arg nil "Blaine Mooers"))
;;
;;;; Bind this search function to Ctrl-x p:
;;(global-set-key (kbd "C-x p") 'helm-bibtex-my-publications)
;;
;;;; 
;;(helm-add-action-to-source
;; "Open annotated PDF (if present)" 'helm-bibtex-open-annotated-pdf
;; helm-source-bibtex 1)
;;
;;(helm-delete-action-from-source "Insert BibTeX key" helm-source-bibtex)
;;(helm-add-action-to-source "Insert BibTeX key" 'helm-bibtex-insert-key helm-source-bibtex 0)
;;
;;(helm-bibtex-helmify-action bibtex-completion-<action> helm-bibtex-<action>)
;;
;;;; (setq tmalsburg-pdf-watch
;;;;       (file-notify-add-watch bibtex-completion-library-path
;;;;       '(change)
;;;;        (lambda (event) (bibtex-completion-candidates))))
;;


;; I was reminded about the helpful package by yantar92 during the 2023-01-01 meeting of Mastering Emacs bookclub.
;; Yantar92 has 23 Emacs Lisp repos on GitHub: https://github.com/yantar92?tab=repositories&q=&type=&language=emacs+lisp&sort=
;; Most are org-mode related.
;; yantar92 also shows up at the Berlin Emacs meeting.
;;
;; Helfpful does look to be more useful than the built-in help commands.
;; I have remapped the keybindings as suggested by the developer Wilfred Hughes https://github.com/Wilfred/helpful
;; He is a Emacs power users with 141 repos in Emacs Lisp.
(use-package helpful
  :ensure t)

;; Note that the built-in `describe-function' includes both functions
;; and macros. `helpful-function' is functions only, so we provide
;; `helpful-callable' as a drop-in replacement.
(global-set-key (kbd "C-h f") #'helpful-callable)

(global-set-key (kbd "C-h v") #'helpful-variable)
(global-set-key (kbd "C-h k") #'helpful-key)

;; Lookup the current symbol at point. C-c C-d is a common keybinding
;; for this in lisp modes.
(global-set-key (kbd "C-c C-d") #'helpful-at-point)

;; Look up *F*unctions (excludes macros).
;;
;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
;; already links to the manual, if a function is referenced there.
(global-set-key (kbd "C-h F") #'helpful-function)

;; Look up *C*ommands.
;;
;; By default, C-h C is bound to describe `describe-coding-system'. I
;; don't find this very useful, but it's frequently useful to only
;; look at interactive functions.
(global-set-key (kbd "C-h C") #'helpful-command)


;;  Emacs minor mode that highlights defined Emacs Lisp symbols in source code.
;;  Currently it recognizes Lisp function, built-in function, macro, face and variable names.
(use-package highlight-defined
  :ensure t)
(add-hook 'emacs-lisp-mode-hook 'highlight-defined-mode)





;; **  I

;; *** inkscape.el
;; Use M-x inkscape (or M-x ink) to
;;    1. Query for a file name to edit from the figure directory (./figures/ by default)
;;    2. If the file does not exist, create it from the template (stored in inkscape-plain-svg-template, by default the contents of template.svg)
;;    3. Open Inkscape (asynchronically) on the file
;;    4. Once the process exits, compile the file to pdf_tex by default (controlled by inkscape-compilation-args)
;;    5. Check that the target file exists. If it does, copy the include string (\def\svgwidth{0.7\textwidth} \input{./figures/%s.pdf_tex} by default).
;;(use-package inkscape
;;  :straight (:host github
;;             :repo "ymarco/inkscape.el"
;;             :files ("*.el" "*.svg")))
;;
;; *** ivy
;; Use ivy or helm but not both.
(use-package ivy
 :ensure t
 :init
 (ivy-mode 1)
 (global-set-key "\C-s" 'swiper)
 (unbind-key "S-SPC" ivy-minibuffer-map)
 (setq ivy-height 15
       ivy-use-virtual-buffers t
       ivy-count-format "(%d/%d) "
       ivy-use-selectable-prompt t))
(use-package ivy-bibtex
   :ensure t)


;; ** L


;; *** LanguageTool

;; I downloaded Language Tool and installed it in ~/.languagetool.
;; source: https://github.com/PillFall/languagetool.el


(use-package languagetool
  :ensure t
  :defer t
  :commands (languagetool-check
             languagetool-clear-suggestions
             languagetool-correct-at-point
             languagetool-correct-buffer
             languagetool-set-language
             languagetool-server-mode
             languagetool-server-start
             languagetool-server-stop)
  :config
  (setq languagetool-java-arguments '("-Dfile.encoding=UTF-8")
        languagetool-console-command "~/.languagetool/languagetool-commandline.jar"
        languagetool-server-command "~/.languagetool/languagetool-server.jar"))

(setq languagetool-java-arguments '("-Dfile.encoding=UTF-8"))

(setq languagetool-console-command "~/.languagetool/languagetool-commandline.jar"
      languagetool-server-command "~/.languagetool/languagetool-server.jar")

;;### LaTeX helpher functions
;;#### M-x description
;; Converts a selected list into a description list.
;; The elements of the list must begin with a dash.
;; The terms to be inserted into the square brackets
;; have to be added after running the function.
(defun description (beg end) 
 "wrap the active region in an 'itemize' environment,
  converting hyphens at the beginning of a line to \item"
  (interactive "r")
  (save-restriction
    (narrow-to-region beg end)
    (beginning-of-buffer)
    (insert "\\begin{description}\n")
    (while (re-search-forward "^- " nil t)
      (replace-match "\\\\item[ ]"))
    (end-of-buffer)
    (insert "\\end{description}\n")))


;;#### M-x enumerate
;; Converts a selected list into an enumerated list.
;; The elements of the list must begin with a dash.
(defun enumerate (beg end) 
 "wrap the active region in an 'itemize' environment,
  converting hyphens at the beginning of a line to \item"
  (interactive "r")
  (save-restriction
    (narrow-to-region beg end)
    (beginning-of-buffer)
    (insert "\\begin{enumerate}\n")
    (while (re-search-forward "^- " nil t)
      (replace-match "\\\\item "))
    (end-of-buffer)
    (insert "\\end{enumerate}\n")))


;;#### M-x itemize
;; Converts a selected list into an itemized list.
;; The elements of the list must begin with a dash.
;; A similar function could be made to make an enumerated list
;; and a description list.
;; Source: \url{https://tex.stackexchange.com/questions/118958/emacsauctex-prevent-region-filling-when-inserting-itemize}
(defun itemize (beg end) 
 "wrap the active region in an 'itemize' environment,
  converting hyphens at the beginning of a line to \item"
  (interactive "r")
  (save-restriction
    (narrow-to-region beg end)
    (beginning-of-buffer)
    (insert "\\begin{itemize}\n")
    (while (re-search-forward "^- " nil t)
      (replace-match "\\\\item "))
    (end-of-buffer)
    (insert "\\end{itemize}\n")))


;;#### LaTeX related
(unless (package-installed-p `auctex) (package-install `auctex))

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

(setq doc-view-continuous t) ;; scroll over all pages in doc view 

;; Settings for minted package issue
(eval-after-load "tex" 
  '(setcdr (assoc "LaTeX" TeX-command-list)
          '("%`%l%(mode) -shell-escape%' %t"
          TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX")
    )
  )

;; Outline-minor-mode key map Source: https://www.emacswiki.org/emacs/OutlineMinorMode
(define-prefix-command 'cm-map nil "Outline-")
; HIDE
(define-key cm-map "q" 'hide-sublevels)    ; Hide everything but the top-level headings
(define-key cm-map "t" 'hide-body)         ; Hide everything but headings (all body lines)
(define-key cm-map "o" 'hide-other)        ; Hide other branches
(define-key cm-map "c" 'hide-entry)        ; Hide this entry's body
(define-key cm-map "l" 'hide-leaves)       ; Hide body lines in this entry and sub-entries
(define-key cm-map "d" 'hide-subtree)      ; Hide everything in this entry and sub-entries
;; SHOW
(define-key cm-map "a" 'show-all)          ; Show (expand) everything
(define-key cm-map "e" 'show-entry)        ; Show this heading's body
(define-key cm-map "i" 'show-children)     ; Show this heading's immediate child sub-headings
(define-key cm-map "k" 'show-branches)     ; Show all sub-headings under this heading
(define-key cm-map "s" 'show-subtree)      ; Show (expand) everything in this heading & below
;; MOVE
(define-key cm-map "u" 'outline-up-heading)                ; Up
(define-key cm-map "n" 'outline-next-visible-heading)      ; Next
(define-key cm-map "p" 'outline-previous-visible-heading)  ; Previous
(define-key cm-map "f" 'outline-forward-same-level)        ; Forward - same level
(define-key cm-map "b" 'outline-backward-same-level)       ; Backward - same level
(global-set-key "\M-o" cm-map)


;; Increase size of LaTeX fragment previews in org files
;; (plist-put org-format-latex-options :scale 2)



;; ## nlinum for line numbers
;; (global-nlinum-mode t)


;; *** LSP = Language Server Protocol 
;; lsp-mode uses LSP servers to provides IDE functionality like code completion 
;; (intellisense like using company-capf), navigation (jump to symbol), 
;; refactoring functionality and so on. lsp-ui is used to get prettier boxes and 
;; more info visible in an easy way (like javadoc). 
;; Currently dap-mode is added because I play a bit with it, 
;; and my first impressions are great so far 
;; (for the few times I use a debugger, I know I’m weird for not needing it much at all).

(use-package lsp-mode
      :ensure t
  :bind
  ("M-RET" . lsp-execute-code-action))

;; helper boxes and other nice functionality (like javadoc for java)
(defun lsp-ui-show-doc-helper ()
  (interactive)
  (if (lsp-ui-doc--visible-p)
      (lsp-ui-doc-hide)
      (lsp-ui-doc-show)))

(use-package lsp-ui
      :ensure t
  :after lsp-mode
  :custom
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-doc-position 'at-point)
  :bind
  ("M-s M-d" . lsp-ui-show-doc-helper))

;; Additional helpers using treemacs
;; (symbols view, errors, dependencies for Java etc.)
(use-package lsp-treemacs
      :ensure t
  :after lsp-mode
  :config
  (lsp-treemacs-sync-mode 1))

;; debugger component (for the few times I need it)
(use-package dap-mode
      :ensure t
  :after lsp-mode
  :init
  (dap-auto-configure-mode))

(use-package flycheck
      :ensure t
  :custom
  (flycheck-indication-mode nil)
  (flycheck-highlighting-mode 'lines))


;; ** M
;; *** magit
(use-package magit
  :ensure t
  :commands magit-status
  :bind
  ("C-x g" . magit-status))

;; show todos in magit status buffer
(use-package magit-todos
  :ensure t
  :after (magit)
  :hook
  (magit-status-mode . magit-todos-mode)
  :bind
  ("C-x t" . helm-magit-todos))

(use-package git-gutter
  :ensure git-gutter-fringe
  :after magit
  :init
  (global-git-gutter-mode 1)
  (setq-default left-fringe-width 20)
  :hook
  (magit-post-refresh . git-gutter:update-all-windows))

;; *** Configured for GitHub Markdown
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . gfm-mode)
  :commands (markdown-mode gfm-mode)
  :config
  (setq markdown-command "pandoc -t html5"))
;;Install simple-httpd and impatient-mode packages.

(use-package simple-httpd
  :ensure t
  :config
  (setq httpd-port 7070)
  (setq httpd-host (system-name)))
;; The impatient-mode package takes the content of your buffer, passes it through a filter, and serves the result via simple-httpd HTTP server.

(use-package impatient-mode
  :ensure t
  :commands impatient-mode)
;; Create a filter function to process the Markdown buffer. 
;; The function my-markdown-filter uses github-markdown-css to mimic the look of GitHub.
(defun my-markdown-filter (buffer)
  (princ
   (with-temp-buffer
     (let ((tmp (buffer-name)))
       (set-buffer buffer)
       (set-buffer (markdown tmp))
       (format "<!DOCTYPE html><html><title>Markdown preview</title><link rel=\"stylesheet\" href = \"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css\"/>
<body><article class=\"markdown-body\" style=\"box-sizing: border-box;min-width: 200px;max-width: 980px;margin: 0 auto;padding: 45px;\">%s</article></body></html>" (buffer-string))))
   (current-buffer)))
;; Create the function my-markdown-preview to show the preview. 
(defun my-markdown-preview ()
  "Preview markdown."
  (interactive)
  (unless (process-status "httpd")
    (httpd-start))
  (impatient-mode)
  (imp-set-user-filter 'my-markdown-filter)
  (imp-visit-buffer))
;; Run my-markdown-preview in any Markdown buffer.
;; It will open a new window in your browser and update it as you type.


;; ;; Let's try an org-mode previewer
;; (require 'org-mode
;;   :mode ("\\.org\\'" . gfm-mode)
;;   :commands (org-mode gfm-mode)
;;   :config
;;   (setq org-command "pandoc -t html5"))
;;
;;   (defun my-org-filter (buffer)
;;     (princ
;;      (with-temp-buffer
;;        (let ((tmp (buffer-name)))
;;          (set-buffer buffer)
;;          (set-buffer (org tmp))
;;          (format "<!DOCTYPE html><html><title>Markdown preview</title><link rel=\"stylesheet\" href = \"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css\"/>
;;   <body><article class=\"markdown-body\" style=\"box-sizing: border-box;min-width: 200px;max-width: 980px;margin: 0 auto;padding: 45px;\">%s</article></body></html>" (buffer-string))))
;;      (current-buffer)))
;;   ;; Create the function my-org-preview to show the preview.
;;
;; (defun my-org-preview ()
;;   "Preview org."
;;   (interactive)
;;   (unless (process-status "httpd")
;;     (httpd-start))
;;   (impatient-mode)
;;   (imp-set-user-filter 'my-og-filter)
;;   (imp-visit-buffer))


;;### Move selected regions up or down
;; It is commands like these one that enable rapid reorganization of your prose when writing one sentence per row.
;; Thank you to DivineDomain for the suggested upgrade.
;; Source: https://www.emacswiki.org/emacs/MoveText 
(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-line-region-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-line-region-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

(global-set-key (kbd "M-<down>") 'move-line-region-down)
(global-set-key (kbd "M-<up>") 'move-line-region-up)



;; ;;### Move lines up an down
;; It is commands like these one that enable rapid reorganization of your prose when writing one sentence per row.
;; Retained for those who have not mastered regions.
;; (defun move-line (n)
;;   "Move the current line up or down by N lines."
;;   (interactive "p")
;;   (setq col (current-column))
;;   (beginning-of-line) (setq start (point))
;;   (end-of-line) (forward-char) (setq end (point))
;;   (let ((line-text (delete-and-extract-region start end)))
;;     (forward-line n)
;;     (insert line-text)
;;     ;; restore point to original column in moved line
;;     (forward-line -1)
;;     (forward-char col)))

;; (defun move-line-up (n)
;;   "Move the current line up by N lines."
;;   (interactive "p")
;;   (move-line (if (null n) -1 (- n))))

;; (defun move-line-down (n)
;;   "Move the current line down by N lines."
;;   (interactive "p")
;;   (move-line (if (null n) 1 n)))

;; (global-set-key (kbd "M-<up>") 'move-line-up)
;; (global-set-key (kbd "M-<down>") 'move-line-down)

;; Sometimes we want to edit multiple places in the file at the same time. 
;; Most of the time this is just adding the same characters multiple places 
;; in the file in places with the same pattern, 
;; other times it is inserting a sequence of numbers.

(use-package multiple-cursors
    :ensure t
    :bind
  ("C->" . mc/mark-next-like-this))


;; ** O

;; *** Olivetti 
;; Improves readability. 
;; Olivetti centers the entire buffer like a sheet 
;; of paper and truncates the content. 
;; This helps my eyes when writing things that are 
;; more natural flowing text (articles, books, other org mode stuff).

(use-package olivetti
  :ensure t
  :if window-system
  :after org
  :custom
  (olivetti-minimum-body-width 100)
  (olivetti-body-width 0.8)
  :hook
  (org-mode . olivetti-mode))


;; <<<<<<< BEGINNING of org-agenda >>>>>>>>>>>>>>
(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)

(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
;; org-capture
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-cl" 'org-store-link)

(setq org-columns-default-format "%50ITEM(Task) %10CLOCKSUM %16TIMESTAMP_IA")

(setq org-agenda-files '("~/gtd/tasks/JournalArticles.org"
 "~/gtd/tasks/Proposals.org"
 "~/gtd/tasks/Books.org"
 "~/gtd/tasks/Talks.org"
 "~/gtd/tasks/Posters.org"
 "~/gtd/tasks/ManuscriptReviews.org"
 "~/gtd/tasks/Private.org"
 "~/gtd/tasks/Service.org"
 "~/gtd/tasks/Teaching.org"
 "~/gtd/tasks/Workshops.org"
 "~/gtd/tasks/grasscatchers.org"))

;; Cycle through these keywords with shift right or left arrows.
(setq org-todo-keywords
        '((sequence "TODO(t)" "INITIATED(i!)" "WAITING(w!)" "CAL(a)" "SOMEDAY(s!)" "PROJ(j)" "|" "DONE(d!)" "CANCELLED(c!)")))

(setq org-refile-targets '(("~/gtd/tasks/JournalArticles.org" :maxlevel . 2)
   ("~/gtd/tasks/Proposals.org" :maxlevel . 2)
   ("~/gtd/tasks/Books.org" :maxlevel . 2)
   ("~/gtd/tasks/Talks.org" :maxlevel . 2)
   ("~/gtd/tasks/Posters.org" :maxlevel . 2)
   ("~/gtd/tasks/ManuscriptReviews.org" :maxlevel . 2)
   ("~/gtd/tasks/Private.org" :maxlevel . 2)
   ("~/gtd/tasks/Service.org" :maxlevel . 2)
   ("~/gtd/tasks/Teaching.org" :maxlevel . 2)
   ("~/gtd/tasks/grasscatcer.org" :maxlevel . 2)
   ("~/gtd/tasks/Workshops.org" :maxlevel . 2)))
(setq org-refile-use-outline-path 'file)

;; ***** customized agenda views
;; 
;; These are my customized agenda views by project.
;; The letter is the last parameter.
;; For example, enter ~C-c a b~ and then enter 402 at the prompt to list all active tasks related to 402 tasks.
;; 
;; I learned about this approach [[https://tlestang.github.io/blog/keeping-track-of-tasks-and-projects-using-emacs-and-org-mode.html][here]].
;; 
;; The CATEGORY keyword resides inside of a Properties drawer.
;; The drawers are usually closed.
;; I am having trouble opening my drawers in may org files.
;; In addition, I do not want to have to add a drawer to each TODO.
;; 
;; I am loving Tags now.
;; I may switch to using Tags because they are visible in org files.
;; I tried and they are not leading to the expect list of TODOs in org-agenda.
;; I am stumped.
;; 
;; In the meantime, enter ~C-c \~ inside JournalArticles.org to narrow the focus to the list of TODOs or enter ~C-c i b~ to get an indirect buffer.
;; 

(setq org-agenda-custom-commands
      '(
	("b"
             "List of all active 402 tasks."
             tags-todo
             "402\"/TODO|INITIATED|WAITING")
	("c"
             "List of all active 523 RNA-drug crystallization review paper tasks."
             tags-todo
             "CATEGORY=\"523\"/TODO|INITIATED|WAITING")
	("d"
             "List of all active 485PyMOLscGUI tasks."
             tags-todo
             "CATEGORY=\"485\"/TODO|INITIATED|WAITING")
	("e"
             "List of all active 2104 Emacs tasks"
             tags-todo
             "2104+CATEGORY=\"2104\"/NEXT|TODO|INITIATED|WAITING")
	("n"
             "List of all active 651 ENAX2 tasks"
             tags-todo
             "651+CATEGORY=\"651\"/NEXT|TODO|INITIATED|WAITING")
	("q"
             "List of all active 561 charge density review"
             tags
             "561+CATEGORY=\"211\"/NEXT|TODO|INITIATED|WAITING")
	("r"
             "List of all active 211 rcl/dnph tasks"
             tags-todo
             "211+CATEGORY=\"211\"/NEXT|TODO|INITIATED|WAITING")
	("P"
         "List of all projects"
         tags
         "LEVEL=2/PROJ")))


;; I usually know the project to which I want to assign a task.
;; I loathe having to come back latter to refile my tasks.
;; I want to do the filing at the time of capture.
;; I found a solution [[https://stackoverflow.com/questions/9005843/interactively-enter-headline-under-which-to-place-an-entry-using-capture][here]].
;; 
;; A project has two or more tasks.
;; I believe that the 10,000 projects is the upper limit for a 30 year academic career.
;; There are about 10,000 workdays in a 30 year career if you work six days a week.
;; Of course, most academics work seven a week and many work longer than 30 years, some even reach 60 years.
;; 
;; I have my projects split into ten org files.
;; Each org file has a limit of 1000 projects for ease of scrolling.
;; 
;; It is best to let Emacs insert new task because it is easy to accidently delete sectons in an org file, especially when sections are folded.
;; I know that many love folded sections.
;; There is a strong appeal to being able to collapse sections of text.
;; However, folded sections are not for me; I have experienced too many catastrophes.
;;
;; I open all of my org files with all sections fully open.
;; I can use swiper to navigate if I do not want to scroll.
;;
;; Enter ~C-c c~ to start the capture menu.
;; The settings below show a single letter option for selecting the appropriate org-file.
;; After entering the single-letter code, you are prompted for the headline name.
;; You do not have to include the TODO keyword.
;; However, I changed "Headline" to "Tag" because I have the project ID as one of the tags on the same line as the project headline.
;; I am now prompted for the tag.
;; After entering the tag, I fill out the task entry.
;; I then enter ~C-c C-c~ to save the capture.
;; 
;;This protocol can be executed from inside the target org file or from a different buffer.
;;
;;I learned about the following function, which I modified by changing "Headline " to "Tag", from
;;[[https://stackoverflow.com/questions/9005843/interactively-enter-headline-under-which-to-place-an-entry-using-capture][Lionel Henry]] with the modification by Phil on July 1, 2018.
;;
;; There is an intersting discussion on using hydras in org-capture and org-refiling.
;; https://www.mollermara.com/blog/Fast-refiling-in-org-mode-with-hydras/
;; 
(defun org-ask-location ()
  (let* ((org-refile-targets '((nil :maxlevel . 9)))
         (hd (condition-case nil
                 (car (org-refile-get-location "Tag" nil t))
               (error (car org-refile-history)))))
    (goto-char (point-min))
    (outline-next-heading)
    (if (re-search-forward
         (format org-complex-heading-regexp-format (regexp-quote hd))
         nil t)
        (goto-char (point-at-bol))
      (goto-char (point-max))
      (or (bolp) (insert "\n"))
      (insert "* " hd "\n")))
  (end-of-line))


(setq org-capture-templates
 '(
    ("j" "JournalArticles" entry
       (file+function "~/gtd/tasks/JournalArticles.org" org-ask-location)
       "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
       :empty-lines 1)

    ("0" "018 018FrancisRNAdrug" entry
       (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 018FrancisRNAdrug")
       "*** TODO %^{title}\n:Properties:\n:CATEGORY: 018\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
       :empty-lines 1)

    ("1" "026 CCN2023" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 026CCN2023")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 026 \n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

    ("2" "408 PSADwithTPS" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 408PSADwithTPS")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 408\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

    ("3" "523 RNA drug crystallization" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 523 RNA drug crystallization")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 523\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

    ("4" "531 Tools to ease the use of PyMOL" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 531ToolsToEasePyMOL")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 531\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

    ("5" "422 ioADM" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 422ioADM")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 422\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)


     ("6" "409 RNApsad With Overloads" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 409RNApsadWithOverloads")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 409\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

     ("7" "411 RNAisad" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 411RNAisad")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 411\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)

     ("8" "413 RNA practical Optimization Barat" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 413RNApracticalOptimizationBarat")
      "*** TODO %^{title}\n:Properties:\n:CATEGORY: 413\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
      :empty-lines 1)
     
     ("9" "416 Amalgamated molecular visualization on Colab" entry
      (file+headline "~/gtd/tasks/JournalArticles.org" "PROJ 416scipy2022 Amalgamated molecular visualization on Colab")
       "*** TODO %^{title}\n:Properties:\n:CATEGORY: 416\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n %?"
       :empty-lines 1)

    
    
    ("g" "GrantProposals" entry
    (file+function "~/gtd/tasks/Proposals." org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("b" "Books" entry
    (file+function "~/gtd/tasks/Books.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("e" "2104 Emacs" entry
    (file+headline "~/gtd/tasks/Books.org" "PROJ 2104 Emacs")
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: 2104\n:END:\n <%<%Y-%m-%d %a %T>>\n%^{Add your notes here. Enter C-c C-c when finished.}\n%?"
    :empty-lines 1)
    ("t" "talks" entry
    (file+function "~/gtd/tasks/Talks.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("p" "Posters" entry
    (file+function "~/gtd/tasks/Posters.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("r" "ManuscriptReviews" entry
    (file+function "~/gtd/tasks/ManuscriptReviews.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("v" "Private" entry
    (file+function "~/gtd/tasks/Private.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("S" "Service" entry
    (file+function "~/gtd/tasks/Service.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("T" "Teaching" entry
    (file+function "~/gtd/tasks/Teaching.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("w" "Workshop" entry
    (file+function "~/gtd/tasks/Workshops.org" org-ask-location)
    "*** TODO %^{title}\n:Properties:\n:CATEGORY: %^{project id number}\n :END:\n <%<%Y-%m-%d %a %T>>\n %^{Add your notes here. Enter C-c C-c when finished.}\n %?"
    :empty-lines 1)
    ("s" "Slipbox" entry  (file "~/gtd/tasks/refile.org")
           "* %?\n")
    ))


;; ;; Source: https://www.mollermara.com/blog/Fast-refiling-in-org-mode-with-hydras/
;; (defun ap/org-agenda-current-subtree-or-region (prefix)
;; "Display an agenda view for the current subtree or region.
;; With prefix, display only TODO-keyword items."
;; ;; BUG: This doesn't work properly in indirect or narrowed (both?)
;; ;; buffers: it acts upon the whole buffer instead. It works in
;; ;; direct buffers.
;; (interactive "p")
;; (let (header)
;; (if (use-region-p)
;; (progn
;; (setq header "Region")
;; (put 'org-agenda-files 'org-restrict (list (buffer-file-name (current-buffer))))
;; (setq org-agenda-restrict (current-buffer))
;; (move-marker org-agenda-restrict-begin (region-beginning))
;; (move-marker org-agenda-restrict-end
;; (save-excursion
;; ;; If point is at beginning of line, include heading on that line by moving point forward 1 char
;; (goto-char (1+ (region-end)))
;; (org-end-of-subtree))))
;; (progn
;; ;; No region; restrict to subtree
;; (setq header "Subtree")
;; (org-agenda-set-restriction-lock 'subtree)))
;; 
;; ;; Sorting doesn't seem to be working, but the header is
;; (let ((org-agenda-sorting-strategy '(priority-down timestamp-up))
;; (org-agenda-overriding-header header))
;; (org-search-view (if (>= prefix 4) t nil) "*"))
;; (org-agenda-remove-restriction-lock t)
;; (message nil)))
;; 
;; 
;; 
;; 
;; ;; source http://doc.norang.ca/org-mode.html#Capture
;; (setq org-directory "~/gtd/tasks")
;; (setq org-default-notes-file "~/gtd/tasks/refile.org")
;; 
;; ;; I use C-c c to start capture mode
;; (global-set-key (kbd "C-c c") 'org-capture)
;; 
;; ;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
;; (setq org-capture-templates
;;       (quote (("t" "todo" entry (file "~/gtd/tasks/refile.org")
;;                "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
;;               ("r" "respond" entry (file "~/gtd/tasks/refile.org")
;;                "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
;;               ("n" "note" entry (file "~/gtd/tasks/refile.org")
;;                "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
;;               ("j" "Journal" entry (file+datetree "~/gtd/tasks/diary.org")
;;                "* %?\n%U\n" :clock-in t :clock-resume t)
;;               ("w" "org-protocol" entry (file "~/gtd/tasks/refile.org")
;;                "* TODO Review %c\n%U\n" :immediate-finish t)
;;               ("m" "Meeting" entry (file "~/gtd/tasks/refile.org")
;;                "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
;;               ("p" "Phone call" entry (file "~/gtd/tasksrefile.org")
;;                "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
;;               ("h" "Habit" entry (file "~~/gtd/tasks/refile.org")
;;                "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

;; ;; Remove empty LOGBOOK drawers on clock out
;; (defun bh/remove-empty-drawer-on-clock-out ()
;;   (interactive)
;;   (save-excursion
;;     (beginning-of-line 0)
;;     (org-remove-empty-drawer-at "LOGBOOK" (point))))
;; 
;; (add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)
;; 
;; ;; refile configuratoin
;; ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
;; (setq org-refile-targets (quote ((nil :maxlevel . 9)
;;                                  (org-agenda-files :maxlevel . 9))))
;; 
;; ;; Use full outline paths for refile targets - we file directly with IDO
;; (setq org-refile-use-outline-path t)
;; 
;; ;; Targets complete directly with IDO
;; (setq org-outline-path-complete-in-steps nil)
;; 
;; ;; Allow refile to create parent tasks with confirmation
;; (setq org-refile-allow-creating-parent-nodes (quote confirm))
;; 
;; ;; Use IDO for both buffer and file completion and ido-everywhere to t
;; (setq org-completion-use-ido t)
;; (setq ido-everywhere t)
;; (setq ido-max-directory-size 100000)
;; (ido-mode (quote both))
;; ;; Use the current window when visiting files and buffers with ido
;; (setq ido-default-file-method 'selected-window)
;; (setq ido-default-buffer-method 'selected-window)
;; ;; Use the current window for indirect buffer display
;; (setq org-indirect-buffer-display 'current-window)
;; 
;; ;;;; Refile settings
;; ;; Exclude DONE state tasks from refile targets
;; (defun bh/verify-refile-target ()
;;   "Exclude todo keywords with a done state from refile targets"
;;   (not (member (nth 2 (org-heading-components)) org-done-keywords)))
;; 
;; (setq org-refile-target-verify-function 'bh/verify-refile-target)
;; 
;; 
;; 
;; 
;; 
;; (defun jethro/org-capture-slipbox ()
;;     (interactive)
;;     (org-capture nil "s"))

;; The code below requires navigating to the approprite headline in the correct file.
;; Source: https://emacs.stackexchange.com/questions/58008/file-org-capture-entry-under-current-headline-at-point
;; This works great!
;; Create ‘C-u 2 M-x org-capture’ command to refile org-capture template under
;; headline at point.
;; 
;; Similar to C-0 C-c c <x>, which inserts the capture at point.
(defun my-org-capture-under-headline (&optional _goto keys)
  "Capture under the headline at current point.

This finds an appropriate point at the end of the subtree to capture the new
entry to, then call ‘org-capture’ with \"C-u 0\" to capture at this new point,
and finally fixes the level of the newly-captured entry to be a child of the
headline at which this function was called.

KEYS are passed to ‘org-capture’ in its KEYS argument.  _GOTO corresponds to the
GOTO argument of ‘org-capture’, but is is ignored because we intentionally place
the point where we want it."
  (interactive "P")
  (unwind-protect
      (progn
        (unless (eq major-mode 'org-mode)
          (user-error "Must be called from an Org-mode buffer"))
        (org-with-point-at (point)
          (org-back-to-heading t)
          (let* ((headline-marker (point-marker))
                 (headline-level (org-current-level)))
            (org-end-of-subtree t)
            (unless (org--line-empty-p 1)
              (end-of-line)
              (open-line 1)
              (forward-line 1))
            (cl-letf*
                (((symbol-function 'my-org-capture-under-headline--fixup-level)
                  (lambda ()
                    ;; If :begin-marker doesn’t point to a buffer, the capture
                    ;; has already been finalized, so don’t try to do any work
                    ;; in that case.
                    (when-let* ((begin-marker (org-capture-get :begin-marker))
                                ((marker-buffer begin-marker)))
                      ;; Go to the capture buffer.
                      (org-goto-marker-or-bmk begin-marker)
                      ;; Make the captured headline one level below the original headline.
                      (while (< (org-current-level) (+ 1 headline-level))
                        (save-excursion (org-demote-subtree)))
                      (while (> (org-current-level) (+ 1 headline-level))
                        (save-excursion (org-promote-subtree))))))
                 ;; Store the original ‘org-capture-finalize’ for the override before.
                 ((symbol-function 'org-capture-finalize-orig) (symbol-function 'org-capture-finalize))
                 ;; Need to fixup level in case ‘:immediate-finish’ set in ‘org-capture-templates’
                 ((symbol-function 'org-capture-finalize)
                  (lambda (&optional stay-with-capture)
                    (my-org-capture-under-headline--fixup-level)
                    (org-capture-finalize-orig stay-with-capture))))
              (apply #'org-capture 0 keys)
              ;; If the template didn’t contain ‘:immediate-finish’, we fix up
              ;; levels now.
              (my-org-capture-under-headline--fixup-level)))))))

(defun my-org-capture-under-headline-prefix (_orig-fn &rest _args)
  "Provide an additional “C-u 2” prefix arg to `org-capture'.

When ‘org-capture’ is called with this prefix argument, it will capture a
headline according to the template you select, and then immediately refile that
headline under the headline at the current point."
  (let ((goto (nth 0 _args)))
    (if (equal goto 2)
        (apply #'my-org-capture-under-headline _args)
      (apply _orig-fn _args))))
(advice-add 'org-capture :around #'my-org-capture-under-headline-prefix)





;; <<<<<<< END of org-agenda >>>>>>>>>>>>>>


;; org-drill for spaced repetition learning in org-mode
;; You have to install org-drill from MELPA.;; This is a YouTube video about how to use org-drill[[https://www.youtube.com/watch?v=uraPXeLfWcM][to learn Chinese]].
;;You can use org tables to generate [[https://github.com/chrisbarrett/org-drill-table][flashcards]].
(use-package org-drill
             :ensure t
             :config (progn
                          (add-to-list 'org-modules 'org-drill)
                          (setq org-drill-add-random-noise-to-intervals-p t)
                          (setq org-drill-hint-separator "||")
                          (setq org-drill-left-cloze-delimiter "<[")
                          (setq org-drill-right-cloze-delimiter "]>")
                          (setq org-drill-learn-fraction 0.25)
             )
)


;; org-hyperscheduler
;; 

(straight-use-package 
    '(org-hyperscheduler 
        :type git 
        :host github
        :repo "dmitrym0/org-hyperscheduler"
        :files ("*")))
    
;;  :straight
;;  ( :repo "dmitrym0/org-hyperscheduler"
;;    :host github
;;    :type git
;;    :files ("*"))
;;   :bind
;;   (("C-c h o" . org-hyperscheduler-open)
;;   ("C-c h s" . org-hyperscheduler-stop-server))
;;   )


;; org-pomodoro
;; 
(use-package org-pomodoro
    :ensure t
    :commands (org-pomodoro)
    :config
    (setq alert-user-configuration (quote ((((:category . "org-pomodoro")) libnotify nil)))))

;; (use-package sound-wav)
;; (setq org-pomodoro-ticking-sound-p nil)
;; ; (setq org-pomodoro-ticking-sound-states '(:pomodoro :short-break :long-break))
;; (setq org-pomodoro-ticking-sound-states '(:pomodoro))
;; (setq org-pomodoro-ticking-frequency 1)
;; (setq org-pomodoro-audio-player "mplayer")
;; (setq org-pomodoro-finished-sound-args "-volume 0.9")
;; (setq org-pomodoro-long-break-sound-args "-volume 0.9")
;; (setq org-pomodoro-short-break-sound-args "-volume 0.9")
;; (setq org-pomodoro-ticking-sound-args "-volume 0.3")

(global-set-key (kbd "C-c o") 'org-pomodoro)



;; <<<<<<< BEGIN org-ref >>>>>>>>>>>>>>
(use-package org-ref 
    :ensure t)
(require 'org-ref-ivy )
(require 'bibtex)
(setq bibtex-completion-bibliography '("~/Documents/global.bib")
	bibtex-completion-library-path '("~/0papersLabeled/")
	bibtex-completion-notes-path "~/Documents/notes/"
	bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"
	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath)))
      
(setq bibtex-autokey-year-length 4
      bibtex-autokey-name-year-separator "-"
      bibtex-autokey-year-title-separator "-"
      bibtex-autokey-titleword-separator "-"
      bibtex-autokey-titlewords 2
      bibtex-autokey-titlewords-stretch 1
      bibtex-autokey-titleword-length 5)

;; H is the hyper key. I have bound H to Fn. For the MacAlly keyboard, it is bound to right-command.
(define-key bibtex-mode-map (kbd "H-b") 'org-ref-bibtex-hydra/body)
(define-key org-mode-map (kbd "H-c") org-ref-insert-cite-function)
(define-key org-mode-map (kbd "H-r") org-ref-insert-ref-function)
(define-key org-mode-map (kbd "H-l") org-ref-insert-label-function)
(define-key org-mode-map (kbd "H-d") 'doi-add-bibtex-entry)


;; <<<<<<< END org-ref >>>>>>>>>>>>>>




;; <<<<<<< BEGIN org-roam >>>>>>>>>>>>>>
 
;; ** Basic org-roam config
(use-package org-roam
   :ensure t
   :custom
   (org-roam-directory (file-truename "~/org-roam/"))
   :bind (("C-c n l" . org-roam-buffer-toggle)
          ("C-c n f" . org-roam-node-find)
          ("C-c n g" . org-roam-graph)
          ("C-c n i" . org-roam-node-insert)
          ("C-c n c" . org-roam-capture)
          ;; Dailies
          ("C-c n j" . org-roam-dailies-capture-today))
   :config
    (org-roam-ui-mode)
   ;; If you're using a vertical completion framework, you might want a more informative completion interface
   (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
   (org-roam-db-autosync-mode)

   ;; If using org-roam-protocol
   (require 'org-roam-protocol))


;; ** Basic org-roam config
;; Following https://jethrokuan.github.io/org-roam-guide/

(setq org-roam-capture-templates
      '(("m" "main" plain
         "%?"
         :if-new (file+head "main/${slug}.org" "#+title: ${title}\n\n\n\n* References\n\n* Backlinks\n\n#+created_at: %U\n#+last_modified: %U\n")
         :immediate-finish t
         :unnarrowed t)
        ("r" "reference" plain "%?"
         :if-new
         (file+head "reference/${title}.org" "#+title: ${title}\n\n\n\n\n* References\n\n* Backlinks\n\n#+created_at: %U\n#+last_modified: %U\n")
         :immediate-finish t
         :unnarrowed t)
        ("a" "article" plain "%?"
         :if-new
         (file+head "articles/${title}.org" "#+title: ${title}\n#+filetags: :article:\n\n\n\n\n* References\n\n* Backlinks\n\n#+created_at: %U\n#+last_modified: %U\n")
         :immediate-finish t
         :unnarrowed t)))


(setq org-roam-node-display-template
    (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))


(defun jethro/org-roam-node-from-cite (keys-entries)
    (interactive (list (citar-select-ref :multiple nil :rebuild-cache t)))
    (let ((title (citar--format-entry-no-widths (cdr keys-entries)
                                                "${author editor} :: ${title}")))
      (org-roam-capture- :templates
                         '(("r" "reference" plain "%?" :if-new
                            (file+head "reference/${citekey}.org"
                                       ":PROPERTIES:
:ROAM_REFS: [cite:@${citekey}]
:END:
#+title: ${title}\n")
                            :immediate-finish t
                            :unnarrowed t))
                         :info (list :citekey (car keys-entries))
                         :node (org-roam-node-create :title title)
                         :props '(:finalize find-file))))


(defun jethro/tag-new-node-as-draft ()
  (org-roam-tag-add '("draft")))
(add-hook 'org-roam-capture-new-node-hook #'jethro/tag-new-node-as-draft)



;; settings to enable rendering of LaTeX equations with org-latex-preview with C-c C-x C-l
;; I tried to get org-latex-preview to work without success on 12-10-2022
;; I had to install texlive-xelatex via macports.
;;


(setq org-preview-latex-default-process 'dvisvgm)

(setq org-latex-to-pdf-process 
  '("xelatex -interaction nonstopmode %f"
     "xelatex -interaction nonstopmode %f")) ;; for multiple passes

;; Increase size of LaTeX fragment previews. Note that the previews do not scale up with C-x +
(plist-put org-format-latex-options :scale 2)

;; *** Create the property “type” on my nodes.

;; (cl-defmethod org-roam-node-type ((node org-roam-node))
;;   "Return the TYPE of NODE."
;;   (condition-case nil
;;       (file-name-nondirectory
;;        (directory-file-name
;;         (file-name-directory
;;          (file-relative-name (org-roam-node-file node) org-roam-directory))))
;;     (error "")))
;; 

;;(setq org-roam-node-display-template
;;          (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
;;



;; *** org-roam-bibtex config

(use-package org-roam-bibtex
      :ensure t
      :hook (org-roam-mode . org-roam-bibtex-mode))

    (setq orb-preformat-keywords
          '("citekey" "title" "url" "author-or-editor" "keywords" "file")
          orb-process-file-keyword t
          orb-file-field-extensions '("pdf"))

    (setq orb-templates
          '(("r" "ref" plain(function org-roam-capture--get-point)
             ""
             :file-name "${citekey}"
             :head "#+TITLE: ${citekey}: ${title}\n#+ROAM_KEY: ${ref}
  - tags ::
  - keywords :: ${keywords}

  *Notes
  :PROPERTIES:
  :Custom_ID: ${citekey}
  :URL: ${url}
  :AUTHOR: ${author-or-editor}
  :NOTER_DOCUMENT: ${file}
  :NOTER_PAGE:
  :END:")))
  

(use-package citar-org-roam
      :ensure t
  :after citar org-roam
  :no-require
  :config (citar-org-roam-mode))


(use-package citar
      :ensure t
  :bind (("C-c b" . citar-insert-citation)
         :map minibuffer-local-map
         ("M-b" . citar-insert-preset))
  :custom
  (citar-bibliography '("~/Documents/global.bib")))

(setenv "PATH" (concat ":/opt/local/bin/" (getenv "PATH")))
(add-to-list 'exec-path "/opt/local/bin/")

;; ;; *** emacs-jupyter and stata_kernel
;; ;; Source: https://rlhick.people.wm.edu/posts/stata_kernel_emacs.html
;; ;; This post is from 2020. An earlier post in 2019 is outdated.
;; ;; Suggests that it is best to export the plot and then reload it via an internal link.
;; 
;; 
;; (when (functionp 'module-load)
;;      (use-package jupyter
;;          :ensure t)
;;      (with-eval-after-load 'org
;;        (org-babel-do-load-languages
;; 	'org-babel-load-languages
;; 	'((jupyter . t))))
;;      (with-eval-after-load 'jupyter
;;        (define-key jupyter-repl-mode-map (kbd "C-l") #'jupyter-repl-clear-cells)
;;        (define-key jupyter-repl-mode-map (kbd "TAB") #'company-complete-common-or-cycle)
;;        (define-key jupyter-org-interaction-mode-map (kbd "TAB") #'company-complete-common-or-cycle)
;;        (define-key jupyter-repl-interaction-mode-map (kbd "C-c C-r") #'jupyter-eval-line-or-region)
;;        (define-key jupyter-repl-interaction-mode-map (kbd "C-c M-r") #'jupyter-repl-restart-kernel)
;;        (define-key jupyter-repl-interaction-mode-map (kbd "C-c M-k") #'jupyter-shutdown-kernel)
;;        (add-hook 'jupyter-org-interaction-mode-hook (lambda () (company-mode)
;; 						     (setq company-backends '(company-capf))))
;;        (add-hook 'jupyter-repl-mode-hook (lambda () (company-mode)
;; 					  :config (set-face-attribute
;; 						   'jupyter-repl-input-prompt nil :foreground "black")
;; 					  :config (set-face-attribute
;; 						   'jupyter-repl-output-prompt nil :foreground "grey")
;; 					  (setq company-backends '(company-capf))))
;;        (setq jupyter-repl-prompt-margin-width 4)))

   ;; associated jupyter-stata with stata (fixes fontification if using pygmentize for html export)
   (add-to-list 'org-src-lang-modes '("jupyter-stata" . stata))
   (add-to-list 'org-src-lang-modes '("Jupyter-Stata" . stata)) 
   ;; you **may** need this for latex output syntax highlighting
   ;; (add-to-list 'org-latex-minted-langs '(stata "stata"))   


;; org-preview-latex-process-alist

;; org-preview-latex-default-process

;; <<<<<<< END org-roam >>>>>>>>>>>>>>


;; source: https://www.reddit.com/r/emacs/comments/zjv1gj/org_files_to_docx/

(defun hm/convert-org-to-docx-with-pandoc ()
  "Use Pandoc to convert .org to .docx.
  Comments:
  The `-N' flag numbers the headers lines.
  Use the `--from org' flag to have this function work on files
  that are in Org syntax but do not have a .org extension"
  (interactive)
  (message "exporting .org to .docx")
  (shell-command
   (concat "pandoc -N --from org " (buffer-file-name)
           " -o "
           (file-name-sans-extension (buffer-file-name))
           (format-time-string "-%Y-%m-%d-%H%M%S") ".docx")))

(defalias 'o2d 'hm/convert-org-to-docx)






;; ** P

;; Paredit makes paranthesis handling a breeze in Lisp-languages.
;; Only setting I really need is to make it possible to select something 
;; and delete the selection (including the paranthesis).

;; (use-package paredit
;;   :config
;;   ;; making paredit work with delete-selection-mode
;;   ;; found on the excellent place called what the emacs d.
;;   (put 'paredit-forward-delete 'delete-selection 'supersede)
;;   (put 'paredit-backward-delete 'delete-selection 'supersede)
;;   (put 'paredit-open-round 'delete-selection t)
;;   (put 'paredit-open-square 'delete-selection t)
;;   (put 'paredit-doublequote 'delete-selection t)
;;   (put 'paredit-newline 'delete-selection t)
;;   :hook
;;   ((emacs-lisp-mode . paredit-mode)
;;    (scheme-mode . paredit-mode)))


;; *** Move to cursor to previously visited window
;; From the book Writing GNU Emacs Extensions by Bill Glickstein.
(defun other-window-backward (&optional n)
  "Select Nth previous window."
  (interactive "P")
  (other-window (- (prefix-numeric-value n))))

(global-set-key "\C-xp" 'other-window-backward)


;; **  pdb-tools

;;Marcin Magnus's updated fork of pdb-tools by Charlie Bond and David Love.
;;[[https://github.com/mmagnus/emacs-pdb-mode][Gitub repo]]]


;; pdb.el
;;(load-file "~/.emacs.default30/plugins/emacs-pdb-mode/pdb-mode.el")
;;(setq pdb-rasmol-name "/Applications/PyMOL.app/Contents/bin/pymol")
;;(setq auto-mode-alist
;;     (cons (cons "pdb$" 'pdb-mode)
;;           auto-mode-alist ) )
;;(autoload 'pdb-mode "PDB")




;;### pdf-tools

;; This is an alternative to the built-in DocView package.
;; I allows smooth scrolling and it superior in general.
;; I could load several PDFs, including 500 pages books.
;; 
;; 
;; The pdf-tools package runs on top of pdf-view package.
;; This making capturing text from PDFs much easier.
;; 
;; I followed a [[http://pragmaticemacs.com/emacs/view-and-annotate-pdfs-in-emacs-with-pdf-tools][blog post]].
;; You enter highlights by selecting with the mouse and entering C-c C-a h.
;; An annotation menu opens in the minibuffer.
;; Enter ~C-c C-c~ to save the annotation.
;; Enter ~C-c C-a t~ to enter text notes.
;; Enter the note and enter ~C-c C-c~ to save.
;; Right-click the mouse to get a menu of more options.


(use-package pdf-tools
      :ensure t
  ;;:pin manual ;; manually update
  :config
  ;; initialise
  (pdf-tools-install)

  ;; This means that pdfs are fitted to width by default when you open them
  (setq-default pdf-view-display-size 'fit-width)
  ;; open pdfs scaled to fit page
  ;;  (setq-default pdf-view-display-size 'fit-page)
   ;; automatically annotate highlights
  (setq pdf-annot-activate-created-annotations t)
  ;; use normal isearch
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))
  ;; Setting for sharper images with Macs with Retina displays
  (setq pdf-view-use-scaling t)



;; **** Useful keybindings for viewing PDFs
;; |------------------------------------------+-----------------|
;; | Display                                  |                 |
;; |------------------------------------------+-----------------|
;; | Zoom in / Zoom out                       | ~+~ / ~-~       |
;; | Fit height / Fit width / Fit page        | ~H~ / ~W~ / ~P~ |
;; | Trim margins (set slice to bounding box) | ~s b~           |
;; | Reset margins                            | ~s r~           |
;; | Reset z oom                              | ~0~             |
;; |------------------------------------------+-----------------|
;; 
;; **** Useful keybindings for navigating PDFs
;; 
;; |-----------------------------------------------+-----------------------|
;; | Navigation                                    |                       |
;; |-----------------------------------------------+-----------------------|
;; | Scroll Up / Down by Page-full                 | ~space~ / ~backspace~ |
;; | Scroll Up / Down by Line                      | ~C-n~ / ~C-p~         |
;; | Scroll Right / Left                           | ~C-f~ / ~C-b~         |
;; | First Page / Last Page                        | ~<~ / ~>~             |
;; | Next Page / Previous Page                     | ~n~ / ~p~             |
;; | First Page / Last Page                        | ~M-<~ / ~M->~         |
;; | Incremental Search Forward / Backward         | ~C-s~ / ~C-r~         |
;; | Occur (list all lines containing a phrase)    | ~M-s o~               |
;; | Jump to Occur Line                            | ~RETURN~              |
;; | Pick a Link and Jump                          | ~F~                   |
;; | Incremental Search in Links                   | ~f~                   |
;; | History Back / Forwards                       | ~l~ / ~r~             |
;; | Display Outline                               | ~o~                   |
;; | Jump to Section from Outline                  | ~RETURN~              |
;; | Jump to Page                                  | ~M-g g~               |
;; | Store position / Jump to position in register | ~m~ / ~'~             |
;; |-----------------------------------------------+-----------------------|
;; 


;; *** projectile
(use-package projectile
 :ensure t)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)


;; *** Python

;; I sometimes write Python code for various things, sometimes as a calculator 
;; :P (SymPy, NumPy and MatplotLib <3 ). 
;;     
;; I choose to start lsp manually due to sometimes not needing a language server 
;; for minor edits (which is what I mostly do with Python).

(use-package lsp-pyright
      :ensure t
  :after lsp-mode
  :init
  (require 'lsp-pyright))



;;** S





;;### pdf-drop-mode
(straight-use-package
  '(pdf-drop-mode :type git :host github :repo "rougier/pdf-drop-mode"))


(require 'pdf-drop-mode)

(defun my/pdf-process (file doi)
  (message "%s : %s" file doi))

(setq pdf-drop-search-hook #'my/pdf-process)
(pdf-drop-mode)


;;### Swiper related confg from https://github.com/zamansky/using-emacs/blob/lesson-6-swiper/init.el
(use-package try
	:ensure t)


;; Org-mode stuff
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(defalias 'list-buffers 'ibuffer)
;; (defalias 'list-buffers 'ibuffer-other-window)

; If you like a tabbar 
;(use-package tabbar
;  :ensure t
;  :config
;  (tabbar-mode 1))


(use-package ace-window
  :ensure t
  :init
  (progn
    (global-set-key [remap other-window] 'ace-window)
    (custom-set-faces
     '(aw-leading-char-face
       ((t (:inherit ace-jump-face-foreground :height 3.0))))) 
    ))


;; it looks like counsel is a requirement for swiper
;;(use-package counsel
;;  :ensure t
;;  )
;;
;;(use-package swiper
;;  :ensure try
;;  :config
;;  (progn
;;    (ivy-mode 1)
;;    (setq ivy-use-virtual-buffers t)
;;    (global-set-key "\C-c s" 'swiper)
;;    (global-set-key (kbd "C-c C-r") 'ivy-resume)
;;    (global-set-key (kbd "<f6>") 'ivy-resume)
;;    (global-set-key (kbd "M-x") 'counsel-M-x)
;;    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;;    (global-set-key (kbd "<f1> f") 'counsel-describe-function)
;;    (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;;    (global-set-key (kbd "<f1> l") 'counsel-load-library)
;;    (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;;    (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;;    (global-set-key (kbd "C-c g") 'counsel-git)
;;    (global-set-key (kbd "C-c j") 'counsel-git-grep)
;;    (global-set-key (kbd "C-c k") 'counsel-ag)
;;    (global-set-key (kbd "C-x l") 'counsel-locate)
;;    (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
;;    (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
;;    ))




;; ;; ** T
;; ;; *** tabspaces
;; ;; Source: 
;; 
;; (use-package tabspaces
;;   ;; use this next line only if you also use straight, otherwise ignore it. 
;;   :straight (:type git :host github :repo "mclear-tools/tabspaces")
;;   :hook (after-init . tabspaces-mode) ;; use this only if you want the minor-mode loaded at startup. 
;;   :commands (tabspaces-switch-or-create-workspace
;;              tabspaces-open-or-create-project-and-workspace)
;;   :custom
;;   (tabspaces-use-filtered-buffers-as-default t)
;;   (tabspaces-default-tab "Default")
;;   (tabspaces-remove-to-default t)
;;   (tabspaces-include-buffers '("*scratch*"))
;;   ;; sessions
;;   (tabspaces-session t)
;;   (tabspaces-session-auto-restore t))
;;   
;; (defvar tabspaces-command-map
;;   (let ((map (make-sparse-keymap)))
;;     (define-key map (kbd "C") 'tabspaces-clear-buffers)
;;     (define-key map (kbd "b") 'tabspaces-switch-to-buffer)
;;     (define-key map (kbd "d") 'tabspaces-close-workspace)
;;     (define-key map (kbd "k") 'tabspaces-kill-buffers-close-workspace)
;;     (define-key map (kbd "o") 'tabspaces-open-or-create-project-and-workspace)
;;     (define-key map (kbd "r") 'tabspaces-remove-current-buffer)
;;     (define-key map (kbd "R") 'tabspaces-remove-selected-buffer)
;;     (define-key map (kbd "s") 'tabspaces-switch-or-create-workspace)
;;     (define-key map (kbd "t") 'tabspaces-switch-buffer-and-tab)
;;     map)
;;   "Keymap for tabspace/workspace commands after `tabspaces-keymap-prefix'.")
;; 
;; ;; If you use ivy you can use this function to limit your buffer search to only those in the tabspace.
;; (defun tabspaces-ivy-switch-buffer (buffer)
;;   "Display the local buffer BUFFER in the selected window.
;; This is the frame/tab-local equivilant to `switch-to-buffer'."
;;   (interactive
;;    (list
;;     (let ((blst (mapcar #'buffer-name (tabspaces-buffer-list))))
;;       (read-buffer
;;        "Switch to local buffer: " blst nil
;;        (lambda (b) (member (if (stringp b) b (car b)) blst))))))
;;   (ivy-switch-buffer buffer))
;; 
;; 
;; ;; By default the *scratch* buffer is included in all workspaces. 
;; ;; You can modify which buffers are included by default by changing the value of tabspaces-include-buffers.
;; ;; If you want emacs to startup with a set of initial buffers in a workspace, do something like the following:
;; 
;; 
;; 
;; (defun my--tabspace-setup ()
;;   "Set up tabspace at startup."
;;   ;; Add *Messages* and *splash* to Tab \`Home\'
;;   (tabspaces-mode 1)
;;   (progn
;;     (tab-bar-rename-tab "Home")
;;     (when (get-buffer "*Messages*")
;;       (set-frame-parameter nil
;;                            'buffer-list
;;                            (cons (get-buffer "*Messages*")
;;                                  (frame-parameter nil 'buffer-list))))
;;     (when (get-buffer "*splash*")
;;       (set-frame-parameter nil
;;                            'buffer-list
;;                            (cons (get-buffer "*splash*")
;;                                  (frame-parameter nil 'buffer-list))))))
;; 
;; (add-hook 'after-init-hook #'my--tabspace-setup)
;; 
;; ;; *** TeXcount setup for TeXcount version 2.3 and later
;; ;; See https://app.uio.no/ifi/texcount/howto.html to use from the command line.
;; (defun texcount ()
;;   (interactive)
;;   (let*
;;     ( (this-file (buffer-file-name))
;;       (enc-str (symbol-name buffer-file-coding-system))
;;       (enc-opt
;;         (cond
;;           ((string-match "utf-8" enc-str) "-utf8")
;;           ((string-match "latin" enc-str) "-latin1")
;;           ("-encoding=guess")
;;       ) )
;;       (word-count
;;         (with-output-to-string
;;           (with-current-buffer standard-output
;;             (call-process "/opt/local/bin/texcount" nil t nil "-0" enc-opt this-file)
;;     ) ) ) )
;;     (message word-count)
;; ) )
;; (add-hook 'LaTeX-mode-hook (lambda () (define-key LaTeX-mode-map "\C-cw" 'texcount)))
;; (add-hook 'latex-mode-hook (lambda () (define-key latex-mode-map "\C-cw" 'texcount)))



;; *** activate word count mode
;; This mode will count the LaTeX markup, but it does give the count of incrementally added words.
(use-package wc-mode
      :ensure t)
(add-hook 'text-mode-hook 'wc-mode)
;; Suggested setting
(global-set-key "\C-cw" 'wc-mode)

;; *** Do NOT MESS with the code below
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-menu-height 15)
 '(ivy-height 20)
 '(org-agenda-files
   '("~/430PSADwaveOpt/430gh/main.org" "~/gtd/tasks/JournalArticles.org" "~/gtd/tasks/Proposals.org" "~/gtd/tasks/Books.org" "~/gtd/tasks/Talks.org" "~/gtd/tasks/Posters.org" "~/gtd/tasks/ManuscriptReviews.org" "~/gtd/tasks/Private.org" "~/gtd/tasks/Service.org" "~/gtd/tasks/Teaching.org" "~/gtd/tasks/Workshops.org"))
 '(package-selected-packages
   '(counsel ace-window org-bullets which-key try languagetool org-ref org-pomodoro pdf-tools dirvish dired-icon 0xc org-pdftools multiple-cursors 0blayout dired-subtree org-roam-timestamps org-roam-bibtex org-roam-ui org-roam org-preview-html impatient-mode ef-themes yasnippet wc-mode use-package rainbow-delimiters powerline maxframe material-theme exec-path-from-shell electric-spacing better-defaults auto-complete auctex atomic-chrome))
 '(warning-suppress-log-types '(((tar link)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))


;; *** Tramp
;; Set default connection mode to SSH
(setq tramp-default-method "ssh")


;; *** tree-sitter

;; (require 'tree-sitter)
;; (require 'tree-sitter-langs)
;; (require 'evil-textobj-tree-sitter)
;; (global-tree-sitter-mode)
;; 


;; ;; ** U
;; ;; *** undo-tree
;; (use-package undo-tree
;;     :init
;;     (global-undo-tree-mode)
;;     :custom
;;     (undo-tree-history-directory-alist '(("." . "~/latex-emacs/undo")))
;;     )


;; ** V


;; Vertico completion family of packages
(use-package vertico
    :ensure t
    :bind (:map vertico-map
         ("C-j" . vertico-next)
         ("C-k" . vertico-previous)
         ("C-f" . vertico-exit)
         :map minibuffer-local-map
         ("M-b" . backward-kill-word))
    :custom
    (vertico-cycle t)
    :init
    (vertico-mode))
    
    
;; save history of recently selected files in a folder to speed up your selection of files and commands.
(use-package savehist
  :init
  (savehist-mode))

;; Provides annotations similar to ivy-rich. Like ls -ltr.
(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))


;; consult
(use-package consult
    :ensure t)

(global-set-key "\C-s" 'consult-line)

(use-package consult-yasnippet
    :ensure t
)

;; orderless
(use-package orderless
        :ensure t)


;; corfu
(use-package corfu
    :ensure t)



;; ** W 
;; *** Which help

(use-package which-key
     :ensure t
     :custom
     (which-key-idle-delay 2)
     :config
     (which-key-mode))

;; *** writeroom
;; writeroom-mode for distraction-free writing.

(with-eval-after-load 'writeroom-mode
       (define-key writeroom-mode-map (kbd "C-M-<") #'writeroom-decrease-width)
       (define-key writeroom-mode-map (kbd "C-M->") #'writeroom-increase-width)
       (define-key writeroom-mode-map (kbd "C-M-=") #'writeroom-adjust-width))




;; ** Y 
;; *** yasnippet related
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
  :bind
  ("C-c y i" . yas-insert-snippet)
  ("C-c y n" . yas-new-snippet)
  )
(global-set-key "\C-o" 'yas-expand)

(use-package popup
  :ensure t)
;; (require 'yasnippet)
;; ;; add some shotcuts in popup menu mode
;; (define-key popup-menu-keymap (kbd "M-n") 'popup-next)
;; (define-key popup-menu-keymap (kbd "TAB") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<tab>") 'popup-next)
;; (define-key popup-menu-keymap (kbd "<backtab>") 'popup-previous)
;; (define-key popup-menu-keymap (kbd "M-p") 'popup-previous)
;;
;; (defun yas/popup-isearch-prompt (prompt choices &optional display-fn)
;;   (when (featurep 'popup)
;;     (popup-menu*
;;      (mapcar
;;       (lambda (choice)
;;         (popup-make-item
;;          (or (and display-fn (funcall display-fn choice))
;;              choice)
;;          :value choice))
;;       choices)
;;      :prompt prompt
;;      ;; start isearch mode immediately
;;      :isearch t
;;      )))
;; (setq yas/prompt-functions '(yas/popup-isearch-prompt yas/no-prompt))
;;
;; (defun complete-if-yas-field (&rest _)
;;   (let ((field (yas-current-field)))
;;     (when (and field
;;                (not (yas--field-modified-p field)))
;;       (company-manual-begin))))
;;
;; (advice-add 'company-complete-selection :after 'complete-if-yas-field)
;; (advice-add 'yas-next-field :after 'complete-if-yas-field)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(which-key-posframe tabbar paredit olivetti org-wc markdown-preview-mode ac-clang git-gutter+ magit-todos magit flycheck dap-mode lsp-treemacs lsp-ui lsp-mode exec-path-from-shell org-roam-timestamps impatient-mode markdown-mode helm-system-packages atomic-chrome tree-sitter-langs org-pomodoro dired-subtree yasnippet try avy-menu maxframe material-theme powerline better-defaults which-key focus dired-icon ace-window nlinum emojify electric-spacing helm-bibtex 0xc dirvish helm-flyspell org-noter-pdftools auctex org-bullets counsel multiple-cursors org-ref org-roam-bibtex rainbow-delimiters org-preview-html git-gutter-fringe org-roam-ui wc-mode org-drill 0blayout evil-textobj-tree-sitter use-package languagetool auto-complete)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
