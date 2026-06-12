;;; anju-main-menu.el --- Main Menu Customization    -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Charles Choi

;; Author: Charles Choi <kickingvegas@gmail.com>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'simple)
(require 'misc)
(require 'bookmark)
(require 'make-mode)
(require 'org)
(require 'org-agenda)
(require 'whitespace)
(require 'markdown-mode)
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-bookmarks)
(require 'casual-editkit)


;;; File Menu Customization
(easy-menu-define anju-window-swap-menu nil
  "Keymap for mouse window swap menu."
  '("Swap Window"
    :visible (not (one-window-p t))
    ["↑" windmove-swap-states-up
     :visible (window-in-direction 'above)
     :help "Swap window up"]

    ["↓" windmove-swap-states-down
     :visible (window-in-direction 'below)
     :help "Swap window down"]

    ["←" windmove-swap-states-left
     :visible (window-in-direction 'left)
     :help "Swap window left"]

    ["→" windmove-swap-states-right
     :visible (window-in-direction 'right)
     :help "Swap window right"]))

(defun anju-main-menu--reconfigure-file ()
  "Hook function to reconfigure File menu in main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'."
  (easy-menu-add-item global-map '(menu-bar file)
                      anju-window-swap-menu
                      'one-window)

  (when anju-file-menu-replace-make-frame-on
    (define-key global-map [menu-bar file make-frame-on-display] nil t)
    (define-key global-map [menu-bar file make-frame-on-monitor] nil t)

    (easy-menu-add-item global-map '(menu-bar file)
                        [make-frame-on-display
                         make-frame-on-display
                         :label "New Frame on Display Server..."
                         :visible (and (fboundp 'make-frame-on-display)
                                       (eq (window-system) 'x))
                         :help "Open a new frame on a display server"]
                        'delete-this-frame)
    (easy-menu-add-item global-map '(menu-bar file)
                        [make-frame-on-monitor
                         make-frame-on-monitor
                         :label "New Frame on Monitor..."
                         :visible
                         (and (fboundp 'make-frame-on-monitor)
                              (> (length (display-monitor-attributes-list)) 1)
                              (if (eq (window-system) 'ns) ; this is fixed in 31+
                                  (version<= "31" emacs-version)
                                t))
                         :help "Open a new frame on another monitor"]
                        'delete-this-frame)))


;;; Options Menu Customization
(defun anju-main-menu--reconfigure-options ()
  "Hook function to reconfigure Options menu in main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'."
  (define-key global-map [menu-bar options cua-mode] nil t))



;;; Edit Menu Customization
(easy-menu-define anju-transpose-menu nil
  "Keymap for Transpose menu."
  '("Transpose ⇄"
    :visible (not buffer-read-only)
    :enable (not (use-region-p))
    ["Characters" transpose-chars
     :help "Interchange characters around point, moving forward one character"]

    ["Words" transpose-words
     :help "Interchange words around point, leaving point at end of them"]

    ["Lines" transpose-lines
     :help "Exchange current line and previous line, leaving point after both"]

    ["Sentences" transpose-sentences
     :help "Interchange the current sentence with the next one"]

    ["Paragraphs" transpose-paragraphs
     :help "Interchange the current paragraph with the next one"]

    ["Regions" transpose-regions
     :help "region STARTR1 to ENDR1 with STARTR2 to ENDR2"]

    ["Balanced Expressions (sexps)" transpose-sexps
     :help "Like C-t (‘transpose-chars’), but applies to balanced \
expressions (sexps)"]))

(easy-menu-define anju-move-text-menu nil
  "Keymap for Move Text menu."
  '("Move Text"
    :visible (not buffer-read-only)
    :enable (not (use-region-p))
    ["Word →" casual-editkit-move-word-forward
     :help "Move word to the right of point forward one word"]

    ["Word ←" casual-editkit-move-word-backward
     :help "Move word to the right of point backward one word"]

    ["Sentence →" casual-editkit-move-sentence-forward
     :help "Move sentence to the right of point forward one sentence"]

    ["Sentence ←" casual-editkit-move-sentence-backward
     :help "Move sentence to the right of point backward one sentence"]

    ["Balanced Expression (sexp) →" casual-editkit-move-sexp-forward
     :help "Move balanced expression (sexp) to the right of point forward \
one sexp"]

    ["Balanced Expression (sexp) ←" casual-editkit-move-sexp-backward
     :help "Move balanced expression (sexp) to the right of point backward \
one sexp"]))

(easy-menu-define anju-delete-space-menu nil
  "Keymap for Delete text menu."
  '("Delete"
    :visible (not buffer-read-only)
    ["Join Line" join-line
     :help "Join this line to previous and fix up \
whitespace at join"]

    ["Just One Space" just-one-space
     :help "Delete all spaces and tabs around point, leaving \
one space"]

    ["Horizontal Space" delete-horizontal-space
     :help "Delete all spaces and tabs around point"]

    ["Pair" delete-pair
     :help "Delete a pair of characters enclosing ARG sexps that follow point"]

    ["Duplicate Lines" delete-duplicate-lines
     :enable (use-region-p)
     :help "Delete all but one copy of any identical lines in the region"]

    ["Blank Lines" delete-blank-lines
     :help "On blank line, delete all surrounding blank lines, \
leaving just one"]

    ["Whitespace Cleanup" whitespace-cleanup
     :help "Cleanup some blank problems in all buffer or at region"]

    ["Trailing Whitespace" delete-trailing-whitespace
     :help "Delete trailing whitespace between START and END"]

    ["Zap up to…" zap-up-to-char
     :help "Kill up to, but not including occurrence of CHAR"]

    ["Zap to…" zap-to-char
     :help "Kill up to and including occurrence of CHAR"]))


(defun anju-main-menu--reconfigure-edit ()
"Hook function to reconfigure Edit menu in main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'."

  (easy-menu-add-item global-map '(menu-bar edit search)
                      [rgrep rgrep
                       :label "Search in Files…"
                       :help "Recursively grep for REGEXP in FILES in directory tree rooted at DIR"]
                      'project-search)

  (easy-menu-add-item global-map '(menu-bar edit)
                      anju-transpose-menu 'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      anju-move-text-menu 'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      anju-delete-space-menu 'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      [flush-lines flush-lines
                       :label "Flush Lines…"
                       :help "Delete lines containing matches for REGEXP"
                       :visible (not buffer-read-only)]
                      'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      [keep-lines keep-lines
                       :label "Keep Lines…"
                       :help "Delete all lines except those containing matches \
for REGEXP."
                       :visible (not buffer-read-only)]
                      'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      [align-regexp align-regexp
                       :label "Align Regexp…"
                       :help "Align the current region using an ad-hoc rule \
read from the minibuffer"
                       :enable (use-region-p)
                       :visible (not buffer-read-only)]
                      'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      [duplicate-dwim duplicate-dwim
                       :label "Duplicate"
                       :help "Duplicate the current line or region"
                       :visible (not buffer-read-only)]
                      'fill)

  (easy-menu-add-item global-map '(menu-bar edit)
                      anju-rectangle-menu 'Transpose\ ⇄)

  (easy-menu-add-item global-map '(menu-bar edit)
                      "--" 'Transpose\ ⇄)

  (when (eq window-system 'ns)
    (easy-menu-add-item global-map '(menu-bar edit)
                        [ns-popup-color-panel ns-popup-color-panel
                         :label "Colors"
                         :help "Show macOS Color Picker"
                         :visible (eq window-system 'ns)])

    (easy-menu-add-item global-map '(menu-bar edit)
                        [ns-do-show-character-palette
                         ns-do-show-character-palette
                         :label "Emoji & Symbols"
                         :help "Show macOS Character Palette"
                         :visible (eq window-system 'ns)]))

  (define-key global-map [menu-bar edit execute-extended-command] nil t))



;;; Reconfigure Bookmarks Menu
(defun anju-main-menu--reconfigure-bookmarks ()
  "Hook function to add Bookmarks menu to the main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'."
  (easy-menu-add-item global-map '(menu-bar)
                      casual-bookmarks-main-menu
                      'tools)

  (define-key global-map [menu-bar edit bookmark] nil t))



;;; Help Menu Customization

(defun anju-info-in-new-frame ()
  "Create new frame with `info' window."
  (interactive)
  (anju-utils--command-in-new-frame #'info))

(defun anju-new-info-in-new-frame ()
  "Create new frame with new `info' instance."
  (interactive)
  (anju-utils--command-in-new-frame #'info-display-manual))

(defun anju-man-in-new-frame ()
  "Create new frame with `man' instance."
  (interactive)
  (anju-utils--command-in-new-frame #'man))

(defun anju-main-menu--reconfigure-help ()
  "Hook function to reconfigure Help menu in main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'."
  (define-key global-map [menu-bar help-menu  emacs-psychotherapist] nil t)
  (define-key global-map [menu-bar help-menu  more-manuals] nil t)
  (define-key global-map [menu-bar help-menu  emacs-manual] nil t)
  (define-key global-map [menu-bar help-menu  getting-new-versions] nil t)
  (define-key global-map [menu-bar help-menu  describe-no-warranty] nil t)
  (define-key global-map [menu-bar help-menu  about-gnu-project] nil t)
  (define-key global-map [menu-bar help-menu  external-packages] nil t)
  (define-key global-map [menu-bar help-menu  emacs-faq] nil t)
  (define-key global-map [menu-bar help-menu  emacs-news] nil t)
  (define-key global-map [menu-bar help-menu  emacs-known-problems] nil t)
  (define-key global-map [menu-bar help-menu  emacs-manual-bug] nil t)
  (define-key global-map [menu-bar help-menu  send-emacs-bug-report] nil t)
  (define-key global-map [menu-bar help-menu  getting-new-versions] nil t)
  (define-key global-map [menu-bar help-menu  about-gnu-project] nil t)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [anju-info-in-new-frame anju-info-in-new-frame
                       :label "Info in New Frame"
                       :help "Show Info manual in new frame"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [anju-new-info-in-new-frame anju-new-info-in-new-frame
                       :label "New Info in New Frame…"
                       :help "Show new Info manual in new frame"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [anju-man-in-new-frame anju-man-in-new-frame
                       :label "Man Page in New Frame…"
                       :help "Show man page in new frame"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [describe-symbol describe-symbol
                       :label "Describe Symbol…"
                       :help "Describe symbol"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [describe-key describe-key
                       :label "Describe Key or Mouse…"
                       :help "Describe key or mouse operation"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [finder-commentary finder-commentary
                       :label "Library Commentary…"
                       :help "Show commentary for Elisp library"]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [emacs-faq view-emacs-FAQ
                       :label "Emacs FAQ"
                       :help "View Emacs FAQ"]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [emacs-news
                       view-emacs-news
                       :label "Emacs News"
                       :help "View Emacs news about this release"]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [emacs-known-problems
                       view-emacs-problems
                       :label "Emacs Known Problems"
                       :help "View Emacs known problems"]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      [send-emacs-bug-report
                       report-emacs-bug
                       :label "Send Bug Report…"
                       :help "Send Emacs bug report"]
                      'describe-copying)

  (when anju-help-menu-remove-emacs-tutorial
    (define-key global-map [menu-bar help-menu emacs-tutorial] nil t)
    (define-key global-map [menu-bar help-menu emacs-tutorial-language-specific] nil t))

  (define-key global-map [menu-bar help-menu  describe-copying] nil t))



;;; Text Mode Menu Customization

(defun anju-main-menu--reconfigure-text-mode ()
  "Reconfigure Text mode menu."
  (easy-menu-remove-item text-mode-menu nil "Center Line")
  (easy-menu-remove-item text-mode-menu nil "Center Region")
  (easy-menu-remove-item text-mode-menu nil "Center Paragraph")
  (easy-menu-remove-item text-mode-menu nil "Paragraph Indent")
  (easy-menu-remove-item text-mode-menu nil "---")

  (easy-menu-add-item text-mode-menu nil anju-transform-text-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-style-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-center-text-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-fill-text-menu "Auto Fill"))


;;; Imenu Configuration

(defun anju-imenu-add-menubar-index ()
  "Add imenu index to menubar."
  (condition-case err (imenu-add-menubar-index)
    (imenu-unavailable
     (let ((inhibit-message t))
       (message "Warning: %s" (error-message-string err))))))

(defun anju-imenu-auto-rescan ()
  "Set local `imenu-auto-rescan' to t."
  (setq-local imenu-auto-rescan t))

(defun anju-main-menu--reconfigure-imenu ()
  "Hook function to add Index menu to the main menu bar.

This function is intended to be used in
`anju-reconfigure-main-menu-hook'.

Current modes affected:
- `prog-mode'
- `makefile-mode'
- `org-mode'
- `markdown-mode'

Auto rescan `imenu-auto-rescan' is enabled for all affected modes."

  (let ((hooks '(markdown-mode-hook
                 makefile-mode-hook
                 prog-mode-hook
                 org-mode-hook)))

    (mapc (lambda (hook)
            (if (eq hook 'prog-mode-hook)
                (add-hook hook #'anju-imenu-add-menubar-index)
              (add-hook hook #'imenu-add-menubar-index))
            (add-hook hook #'anju-imenu-auto-rescan))
          hooks)

    (if (<= org-imenu-depth 2)
        (setopt org-imenu-depth 7))))


;;; Tools Menu Customization

(easy-menu-define anju-kmacro-menu nil
  "Keymap for keyboard macro commands."

  '("Macro Recorder"
    [kmacro-start-macro
     kmacro-start-macro
     :label "Record"
     :visible (not defining-kbd-macro)
     :help "Record subsequent keyboard input, defining a keyboard macro"]

    [kmacro-end-macro
     kmacro-end-macro
     :label "Stop"
     :visible defining-kbd-macro
     :help "Finish defining a keyboard macro"]

    [kmacro-insert-counter
     kmacro-insert-counter
     :label "Insert counter"
     :visible defining-kbd-macro
     :help "Insert current value of ‘kmacro-counter’, then increment it by ARG"]

    [kmacro-set-format
     kmacro-set-format
     :label "Set counter format…"
     :visible defining-kbd-macro
     :help "Set the format of ‘kmacro-counter’ to FORMAT"]

    [kbd-macro-query
     kbd-macro-query
     :label "Query user"
     :visible defining-kbd-macro
     :help "Query user during kbd macro execution"]

    [kmacro-end-and-call-macro
     kmacro-end-and-call-macro
     :label "Run last"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "Call last keyboard macro, ending it first if currently being defined"]

    [kmacro-name-last-macro
     kmacro-name-last-macro
     :label "Name last…"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "Assign a name to the last keyboard macro defined"]

    [kmacro-bind-to-key
     kmacro-bind-to-key
     :label "Bind last…"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "When not defining or executing a macro, offer to bind last macro to a key"]

    [kmacro-edit-macro
     kmacro-edit-macro
     :label "Edit last"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "As edit last keyboard macro, but without kmacro-repeat property"]

    [kmacro-step-edit-macro
     kmacro-step-edit-macro
     :label "Step edit macro…"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "Step edit and execute last keyboard macro"]

    [edit-kbd-macro
     edit-kbd-macro
     :label "Edit with binding…"
     :enable (not defining-kbd-macro)
     :help "Edit a keyboard macro"]

    [insert-kbd-macro
     insert-kbd-macro
     :label "Insert macro named…"
     :enable (not defining-kbd-macro)
     :help "Insert in buffer the definition of kbd macro MACRONAME, as Lisp code"]

    [kmacro-menu
     kmacro-menu
     :label "List macros"
     :enable (and (not defining-kbd-macro) last-kbd-macro)
     :help "List run-time defined keyboard macros"]))

;; TODO: make a context menu for `kmacro-menu-mode'.

(defun anju-main-menu--reconfigure-tools ()
  "Reconfigure Tools menu."
  (easy-menu-add-item global-map '(menu-bar tools)
                      anju-kmacro-menu
                      'grep)

  (keymap-set-after (lookup-key global-map [menu-bar tools])
    "<separator-tools-kmacro>"
    '(menu-item "--")
    'Macro\ Recorder)

  (easy-menu-add-item global-map '(menu-bar tools)
                      [org-store-link
                       org-store-link
                       :label "Org Store Link"
                       :help "Store a link to the current location"]
                      'grep)

  (easy-menu-add-item global-map '(menu-bar tools)
                      [org-capture
                       org-capture
                       :label "Org Capture…"
                       :help "Capture something"]
                      'grep)



  (easy-menu-add-item global-map '(menu-bar tools)
                      [org-agenda
                       org-agenda
                       :label "Org Agenda…"
                       :help "Dispatch agenda commands to collect entries to \
  the agenda buffer"]
                      'grep)

  (keymap-set-after (lookup-key global-map [menu-bar tools])
    "<separator-tools-org>"
    '(menu-item "--")
    #'org-agenda))

(provide 'anju-main-menu)
;;; anju-main-menu.el ends here
