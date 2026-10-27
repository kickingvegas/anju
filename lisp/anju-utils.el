;;; anju-utils.el --- Anju Utilities                 -*- lexical-binding: t; -*-

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
(require 'seq)
(require 'map)
(require 'mouse)
(require 'rect)
(require 'register)
(require 'window)
(require 'easymenu)
(require 'windmove)

(defgroup anju nil
  "Group settings for Anju, a package that customizes mouse menus and bindings.

If `anju-init' is run, it will make Anju-specific additions to
`context-menu-functions', provided that `context-menu-functions' has not
been set by `customize-variable'.

To customize the context menu, look at `context-menu-functions'."
  :group 'convenience)

(defcustom anju-reconfigure-context-menu-functions-enable t
  "If non-nil, reconfigure the hook `context-menu-functions'.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs. It is also recommended to audit any changes made
to the `context-menu-functions' hook in your Emacs initialization file."
  :type 'boolean
  :group 'anju)

(defcustom anju-reconfigure-main-menu-enable t
  "If non-nil, reconfigure the main menu.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-unset-legacy-mouse-bindings-enable t
  "If non-nil, unset legacy mouse bindings.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-mode-line-bindings-enable t
  "If non-nil, configure mode line to use Anju bindings.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-help-menu-remove-emacs-tutorial nil
  "If non-nil, remove the Emacs tutorial entries.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-file-menu-replace-make-frame-on t
  "If non-nil, replace new frame on menu items in the main menu bar File menu.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-reconfigure-mouse-per-modes-enable t
  "If non-nil, run mode-specific hooks to customize their mouse behavior.

Anju distinguishes modes whose content is treated as a hypertext
document with those whose content is more akin to an application. For
the latter, a single-click <mouse–1> event is treated as a selection
action and a double-click <mouse–1> event is treated as an open action.

Modes reconfigured to support the above distinction are:

- `dired-mode'
- `ibuffer-mode'
- `bookmark-bmenu-mode'

This variable is only evaluated when
`anju-unset-legacy-mouse-bindings-enable' is non-nil. If both variables
are non-nil, then the function `anju-modes-reconfigure-mouse' is run.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-buffer-list-filter-functions
  '((anju-buffer-list-project-filter . 7)
    (anju-buffer-list-compilation-filter . 3)
    (anju-buffer-list-grep-filter . 3)
    (anju-buffer-list-xref-filter . 3)
    (anju-buffer-list-eshell-filter . 3)
    (anju-buffer-list-shell-filter . 3)
    (anju-buffer-list-info-filter . 3)
    (anju-buffer-list-help-filter . 3))

  "Alist used for the pop-up buffers menu from the mode-line buffer name.

This variable is used by the function `anju-buffer-list-menu-items' to
populate the list of buffers used in the pop up menu `anju-popup-buffer-menu'.

This alist is filled using the following key, value pair types:

- key: a buffer list filter function
- value: integer used as the maximum count of buffers to use from the
  filter function

The buffer list filter function is of the form (filter-fn (buffers
&optional count)) where buffers is a list of buffers (usually
`buffer-list') and count is the maximum count of buffers to use.

The order of the buffer list presumes the most recently used buffers are
at the front of the list.

Anju provides the following buffer filters:

- `anju-buffer-list-project-filter'
- `anju-buffer-list-plain-filter'
- `anju-buffer-list-compilation-filter'
- `anju-buffer-list-grep-filter'
- `anju-buffer-list-xref-filter'
- `anju-buffer-list-eshell-filter'
- `anju-buffer-list-shell-filter'
- `anju-buffer-list-info-filter'
- `anju-buffer-list-help-filter'

Users can customize `anju-buffer-list-filter-functions' to re-compose or
add their own filters to define the resulting buffer list returned by
`anju-buffer-list-menu-items'."

  :type '(alist
          :key-type (choice (function-item anju-buffer-list-project-filter)
                            (function-item anju-buffer-list-plain-filter)
                            (function-item anju-buffer-list-compilation-filter)
                            (function-item anju-buffer-list-grep-filter)
                            (function-item anju-buffer-list-xref-filter)
                            (function-item anju-buffer-list-eshell-filter)
                            (function-item anju-buffer-list-shell-filter)
                            (function-item anju-buffer-list-info-filter)
                            (function-item anju-buffer-list-help-filter)
                            (function :tag "Custom buffer list filter"))
          :value-type integer)
  :group 'anju)

(defcustom anju-reconfigure-main-menu-hook
  '(anju-main-menu--reconfigure-file
    anju-main-menu--reconfigure-edit
    anju-main-menu--reconfigure-registers
    anju-main-menu--reconfigure-options
    anju-main-menu--reconfigure-bookmarks
    anju-main-menu--reconfigure-text-mode
    anju-main-menu--reconfigure-tools
    anju-main-menu--reconfigure-help
    anju-main-menu--reconfigure-imenu)
  "Main menu mode hooks to run in `anju-init'.

This hook is a list of functions that reconfigure the main menu. It is
initialized with the following functions:

- `anju-main-menu--reconfigure-file'
- `anju-main-menu--reconfigure-edit'
- `anju-main-menu--reconfigure-registers'
- `anju-main-menu--reconfigure-options'
- `anju-main-menu--reconfigure-bookmarks'
- `anju-main-menu--reconfigure-text-mode'
- `anju-main-menu--reconfigure-tools'
- `anju-main-menu--reconfigure-help'
- `anju-main-menu--reconfigure-imenu'"
  :type 'hook
  :options '(anju-main-menu--reconfigure-file
             anju-main-menu--reconfigure-edit
             anju-main-menu--reconfigure-registers
             anju-main-menu--reconfigure-options
             anju-main-menu--reconfigure-bookmarks
             anju-main-menu--reconfigure-text-mode
             anju-main-menu--reconfigure-tools
             anju-main-menu--reconfigure-help
             anju-main-menu--reconfigure-imenu)
  :group 'anju)

(defvar anju--frame-register-alist nil
  "Internal dictionary for frames used by `anju-toggle-one-window'.")

(defmacro anju-context-menu-item-separator (menu key)
  "Add single line separator to MENU with KEY."
  `(define-key-after ,menu [,key]
     '(menu-item "--")))

(defun anju-utils--command-in-new-frame (cmd)
  "Invoke CMD in a new frame.
This command creates a new frame populated by CMD."
  (other-frame-prefix)
  (call-interactively cmd))

(defun anju-utils--unset-legacy-mouse-bindings ()
  "Unset Emacs legacy mouse keybindings.

Mouse bindings for the following areas are removed:

- Middle mouse button usage
- Mode line bindings
- Secondary selection"

  ;; Remove middle mouse button bindings
  (keymap-global-unset "<mode-line> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<horizontal-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-line> C-<mouse-2>" t)
  (keymap-global-unset "<right-divider> C-<mouse-2>" t)
  (keymap-global-unset "<bottom-divider> C-<mouse-2>" t)

  ;; Remove secondary selection
  (keymap-global-unset "M-<mouse-1>")
  (keymap-global-unset "M-<drag-mouse-1>")  ; was mouse-set-secondary
  (keymap-global-unset "M-<down-mouse-1>")  ; was mouse-drag-secondary
  (keymap-global-unset "M-<mouse-2>")       ; was mouse-yank-secondary
  (keymap-global-unset "M-<mouse-3>")       ; was mouse-secondary-save-then-kill

  ;; Remove mode line bindings
  (keymap-global-unset "<mode-line> <mouse-2>" t)
  (keymap-global-unset "<mode-line> <mouse-3>" t)
  (keymap-global-unset "<mode-line> <double-mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-3>" t))

(defun anju-menu-label (prefix &optional max extent)
  "Generate context menu label with region string prepended by PREFIX.

- MAX defines the truncation length of the region.
- EXTENT defines the length of the truncated string to show from start,
  end of region.

The truncation is done “Apple-style” using `anju-middle-truncate'."
  (let* ((start (region-beginning))
         (end (region-end))
         (rstring (buffer-substring-no-properties start end)))

    (catch 'anju-middle-truncate-exception
        (anju-middle-truncate rstring prefix max extent))))

(defun anju-middle-truncate (rstring prefix &optional max extent)
  "Middle truncate RSTRING prepended by PREFIX.

Implementation of middle (Apple-style) truncation, where RSTRING is
truncated in the middle instead of the right end of its content.

- RSTRING is the source string (typically a region) to be truncated.
- PREFIX is a string to prepend the truncated string.
- MAX defines the truncation length.
- EXTENT defines the length of the truncated string to show from start,
  end of region.

This idea came from Scott Jenson as detailed in the URL
`https://www.linkedin.com/posts/scottjenson_one-of-my-earliest-ux-wins-was-for-mac-system-activity-7275265246053720064-Ozha'."
  (let* ((max (if (not max) 30 max))
         (extent (if (not extent) 12 extent))
         (rlist (string-split rstring "\n")))

    (unless (>= (- (/ max 2) 2) extent)
      (let ((msg (format
                  "ERROR: extent (%d) and max (%d) should \
conform to extent <= (max/2) - 2"
                  extent max)))
        (throw 'anju-middle-truncate-exception msg)))

    (if (> (length rlist) 1)
        (let* ((first (nth 0 rlist))
               (first (if (> (length first) max)
                          (substring first 0 extent)
                        first))
               (last (car (last rlist)))
               (last (if (> (length last) max)
                         (substring last (* -1 extent))
                       last))
               (last (string-trim-left last))
               (last (if (string-equal last "")
                         "␤"
                       last))
               (first (if (string-equal (string-trim first) "")
                         "␣"
                       first)))
          (format "%s “%s…%s”" prefix first last))

      (if (> (length rstring) max)
          (let* ((first (substring rstring 0 extent))
                 (last (string-trim-left (substring rstring (* -1 extent)))))
            (format "%s “%s…%s”" prefix first last))
        (format "%s “%s”" prefix rstring)))))


(easy-menu-define anju-transform-text-menu nil
  "Keymap for Transform Text submenu."
  '("Transform Text"
    :enable (and (use-region-p) (not buffer-read-only))
    ["Make Upper Case" upcase-region
     :help "Convert selected region to upper case"]
    ["Make Lower Case" downcase-region
     :help "Convert selected region to lower case"]
    ["Capitalize" capitalize-region
     :help "Convert the selected region to capitalized form"]))


(easy-menu-define anju-center-text-menu nil
  "Keymap for centering text."
  '("Center"
    :enable (not buffer-read-only)
    ["Line" center-line
     :help "Center the line point is on, within the width specified by ‘fill-column’"]

    ["Region" center-region
     :enable (use-region-p)
     :help "Center each nonblank line starting in the region"]

    ["Paragraph" center-paragraph
     :help "Center each nonblank line in the paragraph at or after point"]))

(easy-menu-define anju-fill-text-menu nil
  "Keymap for fill text."
  '("Fill"
    :enable (not buffer-read-only)
    ["Paragraph" fill-paragraph
     :help "Fill paragraph at or after point"]

    ["Paragraph ⤶" fill-paragraph-semlf
     :visible (fboundp #'fill-paragraph-semlf)
     :help "Fill paragraph at or after point using semantic linefeeds"]

    ["Unfill Paragraph" unfill-paragraph
     :visible (fboundp #'unfill-paragraph)
     :help "Join lines of this paragraph and fix up whitespace at joins"]

    ["Region" fill-region
     :enable (use-region-p)
     :help "Fill each of the paragraphs in the region"]

    ["Region as paragraph" fill-region-as-paragraph
     :enable (use-region-p)
     :help "Fill the region as if it were a single paragraph"]

    ["Region as paragraph ⤶" fill-region-as-paragraph-semlf
     :enable (and (fboundp #'fill-paragraph-semlf) (use-region-p))
     :help "Fill the region using semantic linefeeds as if it were a single paragraph"]

    ["Individual paragraphs" fill-individual-paragraphs
     :enable (use-region-p)
     :help "Fill paragraphs of uniform indentation within the region"]

    ["Non-uniform paragraphs" fill-nonuniform-paragraphs
     :enable (use-region-p)
     :help "Fill paragraphs within the region, allowing varying indentation within each"]))

(defun anju-rectangle-selected-p ()
  "Predicate if rectangle is selected."
  (and (bound-and-true-p rectangle-mark-mode) (use-region-p)))

(easy-menu-define anju-rectangle-menu nil
  "Keymap for rectangle commands."

  '("Rectangle"
    ["Cut" kill-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Delete the region-rectangle and save it as the last killed one"]

    ["Copy" copy-rectangle-as-kill
     :enable (anju-rectangle-selected-p)
     :help "Copy the region-rectangle and save it as the last killed one"]

    ["Paste" yank-rectangle
     :enable (and (not buffer-read-only)
                  (boundp 'killed-rectangle)
                  killed-rectangle)
     :help "Yank the last killed rectangle with upper left corner at point"]

    ["Delete" delete-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Delete rectangle"]

    "--"

    ["Replace…" string-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Replace rectangle contents with STRING on each line"]

    ["Insert…" string-insert-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Insert STRING on each line of region-rectangle, shifting text right"]

    "--"

    ["Number" rectangle-number-lines
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Insert numbers in front of the region-rectangle"]

    ["Clear" clear-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Blank out the region-rectangle"]

    ["Blank" open-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Blank out the region-rectangle, shifting text right"]

    ["Delete leading spaces" delete-whitespace-rectangle
     :enable (and (not buffer-read-only) (anju-rectangle-selected-p))
     :help "Delete all whitespace following a specified column in each line"]))


;;; Delete Window Logic

(defun anju--scrub-frame-register-list ()
  "Scrub `anju--frame-register-alist'."
  (let ((frames (seq-filter (lambda (f) (frame-live-p f)) (frame-list)))
        (keys (map-keys anju--frame-register-alist)))
    (mapc (lambda (key)
            (if (not (member key frames))
                (map-delete anju--frame-register-alist key)))
          keys)))

;; TODO: Audit
(defun anju--new-register-id ()
  "Generate new register identifier."
  (let ((test t)
        (register-id nil))
    (while test
      (setq register-id (+ 8000 (random 1000))) ; TODO: need to parameterize?
      (unless (member register-id (map-values anju--frame-register-alist))
        (setq test nil)))

    (if anju--frame-register-alist
        (setq anju--frame-register-alist
              (map-insert anju--frame-register-alist (selected-frame) register-id))
      (setq anju--frame-register-alist (list `(,(selected-frame) . ,register-id))))
    register-id))

(defun anju--window-configuration-to-register ()
  "Set register identifier."
  (let* ((cache-register-id (map-elt anju--frame-register-alist (selected-frame)))
         (register-id (if cache-register-id
                          cache-register-id
                        (anju--new-register-id))))
    (window-configuration-to-register register-id)))


(defun anju-toggle-one-window (&optional window interactive)
  "Make WINDOW fill its frame.
- INTERACTIVE is passed to `delete-other-windows'."
  (interactive "i\np")
  (anju--scrub-frame-register-list)
  (if (one-window-p t)
      (progn
        (let ((register-id (map-elt anju--frame-register-alist (selected-frame))))
          (if register-id
              (jump-to-register register-id)))
        ;; (message "Returning to last window configuration")
        )
    (progn
      (anju--window-configuration-to-register)
      (delete-other-windows window interactive))))


(defun anju-filename-from-path (path)
  "Extract filename from full PATH."
  (let* ((extension (file-name-extension path))
         (base (file-name-base path)))
    (if extension
        (concat base "." extension)
      base)))


(provide 'anju-utils)
;;; anju-utils.el ends here
