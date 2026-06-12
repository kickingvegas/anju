;;; test-anju-main-menu.el --- Main menu tests       -*- lexical-binding: t; -*-

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
(require 'cl-lib)
(require 'anju-main-menu)
(require 'anju-test-utils)

(defun test--anju-window-swap-menu (kmap)
  (anju-test-keymap
   kmap
   "Swap Window"
   4
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i)
                            "↑"
                            #'windmove-swap-states-up
                            "Swap window up")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "↓"
                            #'windmove-swap-states-down
                            "Swap window down")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "←"
                            #'windmove-swap-states-left
                            "Swap window left")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "→"
                            #'windmove-swap-states-right
                            "Swap window right")))))

(ert-deftest test-anju-window-swap-menu ()
  (test--anju-window-swap-menu anju-window-swap-menu))

(ert-deftest test-anju-main-menu--reconfigure-file ()
  (anju-main-menu--reconfigure-file)

  (let ((swap-map (lookup-key global-map [menu-bar file Swap\ Window]))
        (mfd (lookup-key global-map [menu-bar file make-frame-on-display]))
        (mfm (lookup-key global-map [menu-bar file make-frame-on-monitor])))
    (test--anju-window-swap-menu swap-map)
    (should mfd)
    (should mfm)))

;; -------------------------------------------------------------------

(ert-deftest test-anju-main-menu--reconfigure-options ()
  (anju-main-menu--reconfigure-options)

  (let ((cua-mode (lookup-key global-map [menu-bar options cua-mode])))
    (should (not cua-mode))))


;; -------------------------------------------------------------------

(defun test--anju-transpose-menu (kmap)
  (anju-test-keymap
   kmap
   "Transpose ⇄"
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Characters"
        #'transpose-chars
        "Interchange characters around point, moving forward one character")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Words"
        #'transpose-words
        "Interchange words around point, leaving point at end of them")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Lines"
        #'transpose-lines
        "Exchange current line and previous line, leaving point after both")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentences"
        #'transpose-sentences
        "Interchange the current sentence with the next one")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Paragraphs"
        #'transpose-paragraphs
        "Interchange the current paragraph with the next one")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Regions"
        #'transpose-regions
        "region STARTR1 to ENDR1 with STARTR2 to ENDR2")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expressions (sexps)"
        #'transpose-sexps
        "Like C-t (‘transpose-chars’), but applies to balanced \
expressions (sexps)")))))

(ert-deftest test-anju-transpose-menu ()
  (test--anju-transpose-menu anju-transpose-menu))


;; -------------------------------------------------------------------

(defun test--anju-move-text-menu (kmap)
  (anju-test-keymap
   kmap
   "Move Text"
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Word →"
        #'casual-editkit-move-word-forward
        "Move word to the right of point forward one word")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Word ←"
        #'casual-editkit-move-word-backward
        "Move word to the right of point backward one word")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentence →"
        #'casual-editkit-move-sentence-forward
        "Move sentence to the right of point forward one sentence")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentence ←"
        #'casual-editkit-move-sentence-backward
        "Move sentence to the right of point backward one sentence")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expression (sexp) →"
        #'casual-editkit-move-sexp-forward
        "Move balanced expression (sexp) to the right of point forward \
one sexp")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expression (sexp) ←"
        #'casual-editkit-move-sexp-backward
        "Move balanced expression (sexp) to the right of point backward \
one sexp")))))

(ert-deftest test-anju-move-text-menu ()
  (test--anju-move-text-menu anju-move-text-menu))



;; -------------------------------------------------------------------
(defun test--anju-delete-space-menu (kmap)
  (anju-test-keymap
   kmap
   "Delete"
   10
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Join Line"
        #'join-line
        "Join this line to previous and fix up \
whitespace at join")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Just One Space"
        #'just-one-space
        "Delete all spaces and tabs around point, leaving \
one space")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Horizontal Space"
        #'delete-horizontal-space
        "Delete all spaces and tabs around point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Pair"
        #'delete-pair
        "Delete a pair of characters enclosing ARG sexps that follow point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Duplicate Lines"
        #'delete-duplicate-lines
        "Delete all but one copy of any identical lines in the region")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Blank Lines"
        #'delete-blank-lines
        "On blank line, delete all surrounding blank lines, \
leaving just one")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Whitespace Cleanup"
        #'whitespace-cleanup
        "Cleanup some blank problems in all buffer or at region")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Trailing Whitespace"
        #'delete-trailing-whitespace
        "Delete trailing whitespace between START and END")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Zap up to…"
        #'zap-up-to-char
        "Kill up to, but not including occurrence of CHAR")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Zap to…"
        #'zap-to-char
        "Kill up to and including occurrence of CHAR")))))

(ert-deftest test-anju-delete-space-menu ()
  (test--anju-move-text-menu anju-move-text-menu))


;; -------------------------------------------------------------------

(ert-deftest test-anju-main-menu--reconfigure-edit ()
  (anju-main-menu--reconfigure-edit)

  (let ((transpose-menu (easy-menu-get-map global-map '(menu-bar edit Transpose\ ⇄)))
        (move-text-menu (easy-menu-get-map global-map '(menu-bar edit Move\ Text)))
        (delete-menu (easy-menu-get-map global-map '(menu-bar edit Delete)))
        (rectangle-menu (easy-menu-get-map global-map '(menu-bar edit Rectangle)))
        (rgrep-item (lookup-key global-map [menu-bar edit search rgrep]))
        (flush-lines-item (lookup-key global-map [menu-bar edit flush-lines]))
        (keep-lines-item (lookup-key global-map [menu-bar edit keep-lines]))
        (align-regexp-item (lookup-key global-map [menu-bar edit align-regexp]))
        (duplicate-item (lookup-key global-map [menu-bar edit duplicate-dwim])))

    (should (eq rgrep-item 'rgrep))
    (should (eq duplicate-item 'duplicate-dwim))
    (should (eq flush-lines-item 'flush-lines))
    (should (eq keep-lines-item 'keep-lines))
    (should (eq align-regexp-item 'align-regexp))

    (test--anju-rectangle-menu rectangle-menu)
    (test--anju-transpose-menu transpose-menu)
    (test--anju-move-text-menu move-text-menu)
    (test--anju-delete-space-menu delete-menu)))

(ert-deftest test-anju-main-menu--reconfigure-bookmarks ()
  "Test for `anju-main-menu--reconfigure-bookmarks'."
  (anju-main-menu--reconfigure-bookmarks)

  ;; casual-bookmarks-main-menu is external

  (let* ((bookmarks-keymap (easy-menu-get-map global-map '(menu-bar Bookmarks))))
    (anju-test-keymap
     bookmarks-keymap
     "Bookmarks"
     5
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Edit Bookmarks"
          #'list-bookmarks
          "Display a list of existing bookmarks.")

         (should (string-equal "--" (nth 1 (seq-elt items (cl-incf i)))))

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Add Bookmark…"
          #'bookmark-set-no-overwrite
          "Set a bookmark named NAME at the current location.")

         (should (string-equal "--" (nth 1 (seq-elt items (cl-incf i)))))

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Jump to Bookmark…"
          #'bookmark-jump
          "Jump to bookmark"))))))


(ert-deftest test-anju-main-menu--reconfigure-help ()
  "Test for `anju-main-menu--reconfigure-help'."
  (anju-main-menu--reconfigure-help)

  (let ((help-map (easy-menu-get-map global-map '(menu-bar help-menu))))
    (anju-test-keymap
     help-map
     nil
     20 ; 20 because of tutorials
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Info in New Frame"
          #'anju-info-in-new-frame
          "Show Info manual in new frame")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "New Info in New Frame…"
          #'anju-new-info-in-new-frame
          "Show new Info manual in new frame")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Man Page in New Frame…"
          #'anju-man-in-new-frame
          "Show man page in new frame")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Describe Symbol…"
          #'describe-symbol
          "Describe symbol")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Describe Key or Mouse…"
          #'describe-key
          "Describe key or mouse operation")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Library Commentary…"
          #'finder-commentary
          "Show commentary for Elisp library")

         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))
         (seq-elt items (cl-incf i))

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Emacs FAQ"
          #'view-emacs-FAQ
          "View Emacs FAQ")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Emacs News"
          #'view-emacs-news
          "View Emacs news about this release")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Emacs Known Problems"
          #'view-emacs-problems
          "View Emacs known problems")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Send Bug Report…"
          #'report-emacs-bug
          "Send Emacs bug report"))))))

(ert-deftest test-anju-main-menu--reconfigure-text-mode ()
  "Test for `anju-main-menu--reconfigure-text-mode'."

  (anju-main-menu--reconfigure-text-mode)

  (let* ((textmap (lookup-key text-mode-map [menu-bar text]))
         (transform-map (lookup-key text-mode-map [menu-bar text Transform\ Text]))
         (style-map (lookup-key text-mode-map [menu-bar text Style]))
         (center-map (lookup-key text-mode-map [menu-bar text Center]))
         (fill-map (lookup-key text-mode-map [menu-bar text Fill]))
         (auto-fill (lookup-key text-mode-map [menu-bar text Auto\ Fill])))


    (anju-test-keymap
     transform-map
     "Transform Text"
     3
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Make Upper Case"
          #'upcase-region
          "Convert selected region to upper case")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Make Lower Case"
          #'downcase-region
          "Convert selected region to lower case")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Capitalize"
          #'capitalize-region
          "Convert the selected region to capitalized form"))))

    (anju-test-keymap
     style-map
     "Style"
     7
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Bold"
          #'anju-style-bold
          "Bold selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Italic"
          #'anju-style-italic
          "Italic selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Code"
          #'anju-style-code
          "Code selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Underline"
          #'anju-style-underline
          "Underline selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Verbatim"
          #'anju-style-verbatim
          "Verbatim selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Strike Through"
          #'anju-style-strike-through
          "Strike-through selected region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Remove"
          #'anju-style-remove
          "Remove markup from selected region"))))

    (anju-test-keymap
     center-map
     "Center"
     3
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Line"
          #'center-line
          "Center the line point is on, within the width specified by ‘fill-column’")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Region"
          #'center-region
          "Center each nonblank line starting in the region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Paragraph"
          #'center-paragraph
          "Center each nonblank line in the paragraph at or after point"))))

    (anju-test-keymap
     fill-map
     "Fill"
     5
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Paragraph"
          #'fill-paragraph
          "Fill paragraph at or after point")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Region"
          #'fill-region
          "Fill each of the paragraphs in the region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Region as paragraph"
          #'fill-region-as-paragraph
          "Fill the region as if it were a single paragraph")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Individual paragraphs"
          #'fill-individual-paragraphs
          "Fill paragraphs of uniform indentation within the region")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Non-uniform paragraphs"
          #'fill-nonuniform-paragraphs
          "Fill paragraphs within the region, allowing varying indentation within each"))))))


;; -------------------------------------------------------------------
;; Tools Menu Tests

(defun test--anju-kmacro-menu (kmap)
  "Test KMAP for `anju-kmacro-menu'."

  (anju-test-keymap
   kmap
   "Macro Recorder"
   13
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Record"
        #'kmacro-start-macro
        "Record subsequent keyboard input, defining a keyboard macro")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Stop"
        #'kmacro-end-macro
        "Finish defining a keyboard macro")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Insert counter"
        #'kmacro-insert-counter
        "Insert current value of ‘kmacro-counter’, then increment it by ARG")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Set counter format…"
        #'kmacro-set-format
        "Set the format of ‘kmacro-counter’ to FORMAT")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Query user"
        #'kbd-macro-query
        "Query user during kbd macro execution")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Run last"
        #'kmacro-end-and-call-macro
        "Call last keyboard macro, ending it first if currently being defined")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Name last…"
        #'kmacro-name-last-macro
        "Assign a name to the last keyboard macro defined")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Bind last…"
        #'kmacro-bind-to-key
        "When not defining or executing a macro, offer to bind last macro to a key")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Edit last"
        #'kmacro-edit-macro
        "As edit last keyboard macro, but without kmacro-repeat property")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Step edit macro…"
        #'kmacro-step-edit-macro
        "Step edit and execute last keyboard macro")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Edit with binding…"
        #'edit-kbd-macro
        "Edit a keyboard macro")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Insert macro named…"
        #'insert-kbd-macro
        "Insert in buffer the definition of kbd macro MACRONAME, as Lisp code")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "List macros"
        #'kmacro-menu
        "List run-time defined keyboard macros")))))

(ert-deftest test-anju-kmacro-menu ()
  "Test for `anju-kmacro-menu'."
  (test--anju-kmacro-menu anju-kmacro-menu))


(ert-deftest test-anju-main-menu--reconfigure-tools ()
  (anju-main-menu--reconfigure-tools)

  (let* ((tools (easy-menu-get-map global-map '(menu-bar tools)))
         (macro-menu (easy-menu-get-map tools '(Macro\ Recorder)))
         (macro-sep (easy-menu-get-map tools '(separator-tools-kmacro)))
         (org-store-link-item (easy-menu-get-map tools '(org-store-link)))
         (org-capture-item (easy-menu-get-map tools '(org-capture)))
         (org-agenda-item (easy-menu-get-map tools '(org-agenda)))
         (org-sep (easy-menu-get-map tools '(separator-tools-org))))

    (test--anju-kmacro-menu macro-menu)
    (should macro-sep)
    (should org-store-link-item)
    (should org-capture-item)
    (should org-agenda-item)
    (should org-sep)))


(provide 'test-anju-main-menu)
;;; test-anju-main-menu.el ends here
