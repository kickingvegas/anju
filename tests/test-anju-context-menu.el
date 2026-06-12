;;; test-anju-context-menu.el --- Context Menu Tests  -*- lexical-binding: t; -*-

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
(require 'anju-context-menu)
(require 'anju-test-utils)

;; (ert-deftest test-anju-occur-selected-region ()
;;   "Test for `anju-occur-selected-region'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-at-org-table-p ()
;;   "Test for `anju-at-org-table-p'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-dired-duplicate-file ()
;;   "Test for `anju-dired-duplicate-file'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-org-stored-links-p ()
;;   "Test for `anju-org-stored-links-p'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-yank-markdown-as-org ()
;;   "Test for `anju-yank-markdown-as-org'."
;;   ;; Untested
;; )


;;; Context Menu Function Inventory

(defvar anju-test-context-menu--inventory
  '(anju-context-menu-dired
    anju-context-menu-org-mode
    anju-context-menu-info-mode
    anju-context-menu-make-mode
    anju-context-menu-compile
    anju-context-menu-elisp
    anju-context-menu-edebug-eval
    anju-context-menu-scratch
    anju-context-menu-buffers
    anju-context-menu-region
    anju-context-menu-dictionary
    anju-context-menu-narrow
    anju-context-menu-open-in
    anju-context-menu-vc
    anju-context-menu-markup
    anju-context-menu-wordcount
    anju-context-menu-rectangle
    anju-context-menu-window
    anju-context-menu-region-extension)
  "Control inventory list of context menu functions.")

(ert-deftest test-anju-context-menu--inventory ()
  "Test for `anju-context-menu--inventory'."
  (let* ((inventory anju-test-context-menu--inventory)
         (count (length inventory)))

    (mapc (lambda (x)
            (should (seq-contains-p anju-context-menu--inventory x)))
          inventory)

    (should (= count (length anju-context-menu--inventory)))))


(ert-deftest test-anju-extend-context-menu-functions-options ()
  "Test for `anju-extend-context-menu-functions-options'."

  (anju-extend-context-menu-functions-options anju-context-menu--inventory)

  (let* ((inventory anju-test-context-menu--inventory)
         (count (length inventory)))
    (mapc (lambda (fn)
            (let* ((current-type (get 'context-menu-functions 'custom-type))
                   (function-items (cdr (nth 1 current-type)))
                   (item `(function-item ,fn)))
              (should (seq-contains-p function-items item))))
          inventory)))


;; -------------------------------------------------------------------
;; Context Menu: Region Extension

(defun test--anju-context-menu-org-copy-as-menu (kmap)
  "Test KMAP for `anju-context-menu-org-copy-as-menu'."

  (anju-test-keymap
   kmap
   "Copy as…"
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "GFM"
        #'anju-org-copy-region-as-gfm
        "Copy region as GitHub Flavored Markdown to clipboard")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Markdown"
        #'anju-org-copy-region-as-markdown
        "Copy region as Markdown to clipboard")


       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "LaTeX"
        #'anju-org-copy-region-as-latex
        "Copy region as LaTeX to clipboard")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "HTML"
        #'anju-org-copy-region-as-html
        "Copy region as HTML to clipboard")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "ASCII"
        #'anju-org-copy-region-as-ascii
        "Copy region as ASCII to clipboard")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Slack"
        #'org-slack-export-to-clipboard-as-slack
        "Copy as Slack to clipboard")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "RTF"
        #'anju-org-copy-region-as-rtf
        "Copy as RTF to clipboard")))))

(ert-deftest test-anju-context-menu-org-copy-as-menu ()
  "Test for `anju-context-menu-org-copy-as-menu'."
  (test--anju-context-menu-org-copy-as-menu anju-context-menu-org-copy-as-menu))


(ert-deftest test-anju-context-menu-region-extension ()
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-region-extension
   4
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Paste Last Org Link"
        #'org-insert-last-stored-link
        "Insert the last link stored in org-stored-links")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Paste Markdown as Org"
        #'anju-yank-markdown-as-org
        "Convert clipboard (latest yank) of Markdown text to Org, then paste")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Paste Media"
        #'yank-media
        "Paste (yank) media")

       (let* ((copy-as-item (seq-elt items (cl-incf i)))
              (copy-as-kmap (seq-elt copy-as-item 3)))
         (test--anju-context-menu-org-copy-as-menu copy-as-kmap))))))

(ert-deftest test-anju-filename-from-path ()
  "Test for `anju-filename-from-path'."

  (should (string-equal (anju-filename-from-path "~/mary/jane.org")
                        "jane.org")))


;; -------------------------------------------------------------------
;; Context Menu: Dired

(ert-deftest test-anju-context-menu-dired ()
  "Test for `anju-context-menu-dired'."
  (dired "~/Projects/elisp/anju/")
  (anju-test-context-menu-function
   #'anju-context-menu-dired
   "hi there"
   14
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Rename to…"
        #'dired-do-rename
        "Rename or move file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Copy to…"
        #'dired-do-copy
        "Copy file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Symlink…"
        #'dired-do-relsymlink
        "Make relative symlink")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Copy name"
        #'dired-copy-filename-as-kill
        "Copy names of marked (or next ARG) files into the kill ring")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Toggle Thumbnail"
        #'image-dired-dired-toggle-marked-thumbs
        "Toggle thumbnails in front of marked file names in the Dired buffer")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format "Duplicate “%s”" (anju-filename-from-path (dired-get-filename))))
        #'anju-dired-duplicate-file
        "Duplicate selected item")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format "Insert “%s” View"
                      (anju-filename-from-path (dired-get-filename))))
        #'dired-maybe-insert-subdir
        "Insert subdir (sub-directory)")

       (anju-test-menu-item (seq-elt items (cl-incf i)) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Move to Trash…"
        #'dired-do-delete
        "Delete all marked files")

       (anju-test-menu-item (seq-elt items (cl-incf i)) "--")

       (should (string-equal (seq-elt (seq-elt items (cl-incf i)) 2) "Sort By"))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Omit Mode"
        #'dired-omit-mode
        "Omit mode")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Hide Details"
        #'dired-hide-details-mode
        "Hide directory details")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "📁 Dired…"
        #'dired
        "Open Dired"))))
  (kill-buffer))


(ert-deftest test-anju-context-menu-dired-subdir ()
  "Test for `anju-context-menu-dired' subdir commands."
  (dired "~/Projects/elisp/anju/")
  (dired-goto-file (expand-file-name "~/Projects/elisp/anju/tests"))
  (dired-maybe-insert-subdir (expand-file-name "~/Projects/elisp/anju/tests"))
  (dired-goto-subdir (expand-file-name "~/Projects/elisp/anju/tests"))
  (anju-test-context-menu-function
   #'anju-context-menu-dired
   "hi there"
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        (lambda () (format
               "%s “%s” View"
               (if (dired-subdir-hidden-p
                    (dired-current-directory))
                   "Show" "Hide")
               (anju-filename-from-path
                (directory-file-name
                 (dired-current-directory)))))
        #'dired-hide-subdir
        "Toggle hide subdir (sub-directory)")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format
               "Remove “%s” View"
               (anju-filename-from-path
                (directory-file-name
                 (dired-current-directory)))))
        #'dired-kill-subdir
        "Kill subdir (sub-directory)")

       )))
  (kill-buffer))


;; -------------------------------------------------------------------
;; Context Menu: Scratch Buffer

(ert-deftest test-anju-context-menu-scratch ()
  "Test for `anju-context-menu-scratch'."

  (anju-test-context-menu-function
   #'anju-context-menu-scratch
   "Scratch"
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))
       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Scratch"
        #'scratch-buffer
        "Switch to the *scratch* buffer")))))



;; -------------------------------------------------------------------
;; Context Menu: Dictionary

(ert-deftest test-anju-context-menu-dictionary ()
  "Test for `anju-context-menu-dictionary'."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-dictionary
   1
   (lambda (items)
     (let ((item0 (seq-elt items 0)))
       (anju-test-menu-item
        item0
        (lambda () (format "Look Up “%s”" (substring-no-properties (thing-at-point 'word))))
        #'dictionary-search-word-at-mouse
        "Look up selected region in dictionary")))

   (lambda (filename description)
     (insert "Hi There\nImma going fishing.\n")
     (save-buffer)
     (goto-char (point-min))
     (mark-word)
     (activate-mark))))



;; -------------------------------------------------------------------
;; Context Menu: Emacs Lisp Mode

(defun test--anju-edebug-mode-menu (kmap)
  "Test for `anju-edebug-mode-menu'."
  (anju-test-keymap
   kmap
   "Mode"
   5
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Step"
        #'edebug-step-mode
        "Stop at the next stop point encountered")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Go to ●"
        #'edebug-go-mode
        "Run until the next breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Continue"
        #'edebug-continue-mode
        "Pause one second at each breakpoint, and then continue")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Next"
        #'edebug-next-mode
        "Stop at the next stop point encountered after an expression")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Trace"
        #'edebug-trace-mode
        "Pause (normally one second) at each Edebug stop point")))))

(ert-deftest test-anju-edebug-mode-menu ()
  "Test for `anju-edebug-mode-menu'."
  (test--anju-edebug-mode-menu anju-edebug-mode-menu))


(defun test--anju-edebug-breakpoint-menu (kmap)
  "Test for `anju-edebug-breakpoint-menu'."
  (anju-test-keymap
   kmap
   "Breakpoint"
   5
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Set Breakpoint ●"
        #'edebug-set-breakpoint
        "Set breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Set Conditional ⦿"
        #'edebug-set-conditional-breakpoint
        "Set conditional breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Next ●"
        #'edebug-next-breakpoint
        "Next breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Unset ●"
        #'edebug-unset-breakpoint
        "Unset breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Unset all ●"
        #'edebug-unset-breakpoints
        "Unset all breakpoints")))))


(ert-deftest test-anju-edebug-breakpoint-menu ()
  "Test for `anju-edebug-breakpoint-menu'."
  (test--anju-edebug-breakpoint-menu anju-edebug-breakpoint-menu))


(defun test--anju-edebug-sexp-menu (kmap)
  "Test for `anju-edebug-sexp-menu'."
  (anju-test-keymap
   kmap
   "Sexp"
   3
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Forward"
        #'edebug-forward-sexp
        "Forward sexp")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Step-in"
        #'edebug-step-in
        "Step in sexp")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Step-out"
        #'edebug-step-out
        "Step out sexp")))))


(ert-deftest test-anju-edebug-sexp-menu ()
  "Test for `anju-edebug-sexp-menu'."
  (test--anju-edebug-sexp-menu anju-edebug-sexp-menu))

(defun test--anju-hideshow-menu (kmap)
  "Test for `anju-hideshow-menu'."
  (anju-test-keymap
   kmap
   "Hide/Show"
   3
   (lambda (items)
     (let ((i 0))
       (cl-letf  (((symbol-function 'hs-already-hidden-p) (lambda () t)))
        (anju-test-menu-item
        (seq-elt items i)
        (lambda () (if (hs-already-hidden-p) "Show Block" "Hide Block"))
        #'hs-toggle-hiding
        "Toggle hiding"))

       (cl-letf  (((symbol-function 'hs-already-hidden-p) (lambda () nil)))
        (anju-test-menu-item
        (seq-elt items i)
        (lambda () (if (hs-already-hidden-p) "Show Block" "Hide Block"))
        #'hs-toggle-hiding
        "Toggle hiding"))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Hide All"
        #'hs-hide-all
        "Hide all")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Show All"
        #'hs-show-all
        "Show all")))))

(ert-deftest test-anju-hideshow-menu ()
  "Test for `anju-hideshow-menu'."
  (test--anju-hideshow-menu anju-hideshow-menu))

(ert-deftest test-anju-context-menu-elisp ()
  "Test for `anju-context-menu-elisp'."

  (let ((elfile (expand-file-name "../tests/anju-elisp-edebug-examples.el")))
   (anju-test-context-menu-function-with-filetype
    ".el"
    #'anju-context-menu-elisp
    10
    (lambda (items)
      (let ((i 0))
        (anju-test-menu-item (seq-elt items i) "--")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval Last Sexp"
         #'eval-last-sexp
         "Evaluate sexp before point; print value in the echo area")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Eval “%s”" (anju-form-name-at-point)))
         #'eval-defun
         "Evaluate the top level form point is in")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Edebug “%s”" (anju-form-name-at-point)))
         #'anju-edebug-defun
         "Evaluate the top level form point is in, stepping through with Edebug")


        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (if (use-region-p) "Eval Region" "Eval Buffer"))
         #'elisp-eval-region-or-buffer
         "Evaluate region or buffer")

        (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
          (test--anju-hideshow-menu kmap))

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Rename “%s”" (thing-at-point 'symbol)))
         #'xref-find-references-and-replace
         "Rename xref symbol")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Test “%s”" (anju-form-name-at-point)))
         #'anju-ert-run-test-at-point
         "ERT")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Extract 𝜆…"
         #'anju-extract-lambda-to-defun
         "Convert lambda expression into a function")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval Expression…"
         #'eval-expression
         "Evaluate expression and print result in mini-buffer")))

    (lambda (filename description)
      (insert-file-contents elfile)
      (save-buffer)
      (goto-char (point-min))
      (search-forward "foo")))))

(ert-deftest test-anju-context-menu-elisp-edebug-mode ()
  "Test for `anju-context-menu-elisp'."
  (cl-letf (((symbol-function 'anju-edebug-mode-p) (lambda () t)))
    (let ((elfile (expand-file-name "../tests/anju-elisp-edebug-examples.el")))
      (anju-test-context-menu-function-with-filetype
       ".el"
       #'anju-context-menu-elisp
       12
       (lambda (items)
         (let ((i 0))
           (anju-test-menu-item (seq-elt items i) "--")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Step"
            #'edebug-step-mode
            "Step")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Here"
            #'edebug-goto-here
            "Here")

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-mode-menu kmap))

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-sexp-menu kmap))

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-breakpoint-menu kmap))

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Eval…"
            #'edebug-eval-expression
            "Eval expression")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Previous"
            #'edebug-previous-result
            "Previous result")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Suspend Edebug"
            #'edebug-view-outside
            "Suspend Edebug, run edebug-where to resume")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Watchlist"
            #'edebug-visit-eval-list
            "Open watchlist")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Stop execution"
            #'edebug-stop
            "Stop Edebug execution, useful for exiting from trace or continue loop")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Exit"
            #'edebug-top-level-nonstop
            "Quit Edebug Nonstop")))

       (lambda (filename description)
         (insert-file-contents elfile)
         (save-buffer)
         (goto-char (point-min))
         (search-forward "foo"))))))

(ert-deftest test-anju-context-menu-edebug-eval ()
  "Test for `anju-context-menu-edebug-eval'."

  (anju-test-context-menu-function-with-filetype
   ".el"
   #'anju-context-menu-edebug-eval
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Add symbol"
        #'edebug-update-eval-list
        "In the watchlist, type in symbol or sexp to add")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Delete symbol"
         #'edebug-delete-eval-item
         "Place point on symbol or sexp to delete")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval last sexp"
         #'edebug-eval-last-sexp
         "Eval last sexp")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Insert last sexp"
         #'edebug-eval-print-last-sexp
         "Insert (print) eval of last sexp into watchlist")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Resume"
         #'edebug-where
         "Resume code stepping")))

   (lambda (filename description)
     (edebug-eval-mode))))



;; -------------------------------------------------------------------
;; Context Menu: Org Mode

(ert-deftest test-anju-context-menu-org-mode-heading ()
  "Test for `anju-context-menu-org-mode' when point is in heading."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   10
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "TODO…"
        #'org-todo
        "Change the TODO state of an item")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Change to Body"
        #'org-toggle-heading
        "Convert headings to normal text, or items or text to headings")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Clock In"
        #'org-clock-in
        "Clock in")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Clock Out"
        #'org-clock-out
        "Clock out")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sort…"
        #'org-sort-entries
        "Sort entries on a certain level of an outline tree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-do-demote
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-do-promote
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-demote-subtree
        "Demote heading subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-promote-subtree
        "Promote heading subtree")))
   (lambda (filename description)
     (insert "* heading 1")
     (goto-char (point-min))
     (save-buffer))))


(ert-deftest test-anju-context-menu-org-link ()
  "Test for `anju-context-menu-org-mode' when point is on selected word."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   4
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Change to Heading"
        #'org-toggle-heading
        "Convert headings to normal text, or items or text to headings")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Change to Item"
        #'org-toggle-item
        "Convert headings or normal lines to items, items to normal lines")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Link…"
        #'org-insert-link
        "Insert a link.  At the prompt, enter the link")))
   (lambda (filename description)
     (insert "* Hi There\nImma going fishing.\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))


(ert-deftest test-anju-context-menu-org-mode-list-item ()
  "Test for `anju-context-menu-org-mode' when point is in list item."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   9
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Change to Body"
        #'org-toggle-item
        "Convert item to normal line")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Cycle Bullet"
        #'org-cycle-list-bullet
        "Cycle through the different itemize/enumerate bullets")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sort…"
        #'org-sort-list
        "Sort list items")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (if (org-at-item-checkbox-p)
                  "Change to Item"
                "Change to Checkbox"))
        #'casual-org-toggle-list-to-checkbox
        "Toggle Item/Checkbox")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-indent-item
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-outdent-item
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-indent-item-tree
        "Demote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-outdent-item-tree
        "Promote item subtree")))
   (lambda (filename description)
     (insert "- item 1")
     (goto-char (point-min))
     (save-buffer))))

(ert-deftest test-anju-context-menu-org-mode-checkbox-item ()
  "Test for `anju-context-menu-org-mode' when point is in list item."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   9
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "In-Progress [-]"
        #'casual-org-checkbox-in-progress
        "Change checkbox state to in-progress [-]")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Cycle Bullet"
        #'org-cycle-list-bullet
        "Cycle through the different itemize/enumerate bullets")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sort…"
        #'org-sort-list
        "Sort list items")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (if (org-at-item-checkbox-p)
                  "Change to Item"
                "Change to Checkbox"))
        #'casual-org-toggle-list-to-checkbox
        "Toggle Item/Checkbox")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-indent-item
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-outdent-item
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-indent-item-tree
        "Demote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-outdent-item-tree
        "Promote item subtree")))
   (lambda (filename description)
     (insert "- [ ] item 1")
     (goto-char (point-min))
     (save-buffer))))

(ert-deftest test-anju-context-menu-org-mode-table ()
  "Test for `anju-context-menu-org-mode' when point is in table."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   8
   (lambda (items)
     (let* ((i 0))

       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (casual-org-table--reference-dwim))
        #'casual-org-table-copy-reference-dwim
        "Copy Org table reference (field or range) into kill ring via mouse")

       (let* ((table-region-item (seq-elt items (cl-incf i)))
              (kmap (seq-elt table-region-item 3)))
         (test--anju-org-table-region-menu kmap))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sort…"
        #'org-table-sort-lines
        "Sort table lines according to the column at point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Show Coordinates"
        #'org-table-toggle-coordinate-overlays
        "Toggle the display of row/column numbers in tables")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Recalculate"
        #'anju-org-table-recalculate
        "Recalculate table")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Edit Table Formulas"
        #'org-table-edit-formulas
        "Edit the formulas of the current table in a separate buffer")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Run gnuplot"
        #'org-plot/gnuplot
        "Plot table using gnuplot")))

   (lambda (filename description)
     (insert "| a | b | c |\n|---|---|---|\n| 1 | 2 | 3 |\n")
     (goto-char 1)
     (save-buffer))))

(defun test--anju-org-table-region-menu (kmap)
  "Test KMAP for `anju-org-table-region-menu'."
  (anju-test-keymap
   kmap
   "Org Table Region"
   3
   (lambda (items)
     (let ((cut-item (seq-elt items 0))
           (copy-item (seq-elt items 1))
           (paste-item (seq-elt items 2)))

       (anju-test-menu-item cut-item
                            "Cut"
                            #'org-table-cut-region
                            "Cut Org table region")

       (anju-test-menu-item copy-item
                            "Copy"
                            #'org-table-copy-region
                            "Copy Org table region")

       (anju-test-menu-item paste-item
                            "Paste"
                            #'org-table-paste-rectangle
                            "Paste Org table region")))))

(ert-deftest test-anju-org-table-region-menu ()
  "Test `anju-org-table-region-menu'."
  (test--anju-org-table-region-menu anju-org-table-region-menu))


;; -------------------------------------------------------------------
;; Context Menu: Buffer Navigation/Management


(ert-deftest test-anju-context-menu-buffers ()
  "Test for `anju-context-menu-buffers'."

  (anju-test-context-menu-function
   #'anju-context-menu-buffers
   "Dummy"
   4
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))
            (item3 (seq-elt items 3)))

       (anju-test-menu-item item0 "--")

       (anju-test-menu-item
        item1
        "← Buffer"
        #'previous-buffer
        "Go to previous buffer")

       (anju-test-menu-item
        item2
        "→ Buffer"
        #'next-buffer
        "Go to next buffer")

       (anju-test-menu-item
        item3
        "≣ List All Buffers"
        #'ibuffer
        "List all buffers")))))


;; -------------------------------------------------------------------
;; Context Menu: Makefile Mode

(defun test--anju-makefile-modes-menu (kmap)
  "Test KMAP for `anju-makefile-modes-menu'."

  (anju-test-keymap
   kmap
   "Makefile Type"
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "automake"
        #'makefile-automake-mode
        "An adapted ‘makefile-mode’ that knows about automake")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "BSD"
        #'makefile-bsdmake-mode
        "An adapted ‘makefile-mode’ that knows about BSD make")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "GNU"
        #'makefile-gmake-mode
        "An adapted ‘makefile-mode’ that knows about gmake")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "imake"
        #'makefile-imake-mode
        "An adapted ‘makefile-mode’ that knows about imake")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "make"
        #'makefile-mode
        "Major mode for editing standard Makefiles")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "makepp"
        #'makefile-makepp-mode
        "An adapted ‘makefile-mode’ that knows about makepp")))))

(ert-deftest test-anju-makefile-modes-menu ()
  "Test for `anju-makefile-modes-menu'."
  (test--anju-makefile-modes-menu anju-makefile-modes-menu))

(ert-deftest test-anju-context-menu-make-mode ()
  "Test for `anju-context-menu-make-mode'."
  (anju-test-context-menu-function-with-filetype
   ".mk"
   #'anju-context-menu-make-mode
   12
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Compile…"
        #'compile
        "Compile the program including the current buffer.  Default: run ‘make’")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Insert target…"
        #'makefile-insert-target-ref
        "Complete on a list of known targets, then insert TARGET-NAME at point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Insert macro…"
        #'makefile-insert-macro-ref
        "Complete on a list of known macros, then insert complete ref at point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "\\ Region"
        #'makefile-backslash-region
        "Insert, align, or delete end-of-line backslashes on the lines in the region")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Insert GNU make function…"
        #'makefile-insert-gmake-function
        "Insert a GNU make function call")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Identify Auto Var"
        #'casual-make-identify-autovar-region
        "Identify GNU Make automatic variable in region from START to END")

       (anju-test-menu-item (seq-elt items (cl-incf i)) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Refresh targets and macros"
        #'makefile-pickup-everything
        "Notice names of all macros and targets in Makefile")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Include file names as targets"
        #'makefile-pickup-filenames-as-targets
        "Scan the current directory for filenames to use as targets")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Overview"
        #'makefile-create-up-to-date-overview
        "Create a buffer containing an overview of the state of all known targets")

       (let* ((makefile-modes-item (seq-elt items (cl-incf i)))
              (kmap (seq-elt makefile-modes-item 3)))
         (test--anju-makefile-modes-menu kmap))))

   (lambda (filename description)
     (makefile-gmake-mode)
     (insert "# Hello
.PHONY: tests
tests:
\t$(MAKE) -C $(SRC_DIR) $@\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))



;; -------------------------------------------------------------------
;; Context Menu: Narrow/Widen

(ert-deftest test-anju-context-menu-narrow-region ()
  "Test for `anju-context-menu-narrow' when editing a region."

  (anju-test-context-menu-function-with-filetype
   ".txt"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        (lambda () (anju-menu-label "Narrow Region"))
        #'narrow-to-region
        "Restrict editing in this buffer to the current region")))

   (lambda (filename description)
     (insert "Hi There\nImma going fishing.\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))


(ert-deftest test-anju-context-menu-narrow-elisp ()
  "Test for `anju-context-menu-narrow' when editing an Elisp file."

  (anju-test-context-menu-function-with-filetype
   ".el"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to defun"
        #'narrow-to-defun
        "Restrict editing in this buffer to the current defun")
       ))

   (lambda (filename description)
     (insert "(defun cold ()\n (message \"hi\"))\n")
     (save-buffer)
     (goto-char (point-min)))))

(ert-deftest test-anju-context-menu-narrow-org ()
  "Test for `anju-context-menu-narrow' when editing an Org file."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to subtree"
        #'org-narrow-to-subtree
        "Restrict editing in this buffer to the current subtree")))

   (lambda (filename description)
     (insert "* Hi There\n")
     (save-buffer)
     (goto-char (point-min)))))

(ert-deftest test-anju-context-menu-narrow-markdown ()
  "Test for `anju-context-menu-narrow' when editing a Markdown file."

  (anju-test-context-menu-function-with-filetype
   ".md"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to subtree"
        #'markdown-narrow-to-subtree
        "Restrict editing in this buffer to the current subtree")))

   (lambda (filename description)
     (insert "# Hi There\n")
     (save-buffer)
     (goto-char (point-min))
     (goto-char (point-max)))))

(ert-deftest test-anju-context-menu-narrow-narrowed ()
  "Test for `anju-context-menu-narrow' when editing an Elisp file."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Widen buffer"
        #'widen
        "Remove narrowing restrictions from current buffer")
       ))

   (lambda (filename description)
     (insert "* Hi There\n\n* Whats Up\n")
     (save-buffer)
     (goto-char (point-min))
     (org-narrow-to-subtree))))


;; -------------------------------------------------------------------
;; Context Menu: Open in…

(ert-deftest test-anju-context-menu-open-in ()
  "Test for `anju-context-menu-open-in'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-open-in
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "📁 Open in Dired"
        #'dired-jump-other-window
        "Open file in Dired")))))


;; -------------------------------------------------------------------
;; Context Menu: Info Mode


(ert-deftest test-anju-context-menu-info-mode ()
  "Test for `anju-context-menu-info-mode'."

  (info "(emacs)Top")
  (anju-test-context-menu-function
   #'anju-context-menu-info-mode
   "hi there"
   9
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Top"
        #'Info-top-node
        "Go to the Top node of this file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Table of Contents"
        #'Info-toc
        "Go to a node with table of contents of the current Info file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "↑ Node"
        #'Info-up
        "Go to the superior node of this node")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "← Node"
        #'Info-backward-node
        "Go backward one node, considering all nodes as forming one sequence")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "→ Node"
        #'Info-forward-node
        "Go forward one node, considering all nodes as forming one sequence")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Apropos…"
        #'info-apropos
        "Search indices of all known Info files on your system for STRING")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Copy node name"
        #'Info-copy-current-node-name
        "Put the name of the current Info node into the kill ring")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Open node in web"
        #'anju-info-goto-node-web
        "Open node in web browser"))))
  (kill-buffer))



;; -------------------------------------------------------------------
;; Context Menu: VC/Magit

(ert-deftest test-anju-context-menu-vc-file ()
  "Test for `anju-context-menu-vc'."

  (find-file "~/Projects/elisp/anju/README.org")
  (anju-test-context-menu-function
   #'anju-context-menu-vc
   "hi there"
   3
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Magit Dispatch…"
        #'magit-file-dispatch
        "Show the status of the current Git repository in a buffer")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Ediff revision…"
        #'casual-ediff-revision-from-menu
        "Ediff this file with revision"))))

  (kill-buffer))

(ert-deftest test-anju-context-menu-vc-dired ()
  "Test for `anju-context-menu-vc'."
  (dired "~/Projects/elisp/anju/")
  (anju-test-context-menu-function
   #'anju-context-menu-vc
   "hi there"
   3
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2)))
       (anju-test-menu-item item0 "--")

       (anju-test-menu-item
        item1
        "Magit Status"
        #'magit-status
        "Show the status of the current Git repository in a buffer")

       (anju-test-menu-item
        item2
        "Ediff revision…"
        #'casual-ediff-revision-from-menu
        "Ediff this file with revision"))))

  (kill-buffer))


;; -------------------------------------------------------------------
;; Context Menu: Region Operations

(ert-deftest test-anju-context-menu-region ()
  "Test for `anju-context-menu-region'."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-region
   8
   (lambda (items)
     (let* ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (anju-menu-label "Occur"))
        #'anju-occur-selected-region
        "Show all lines in the current buffer \
containing a match for selected word")

       (should (string-equal (seq-elt (seq-elt items (cl-incf i)) 2) "Style"))
       (should (string-equal (seq-elt (seq-elt items (cl-incf i)) 2) "Transform Text"))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Query Replace…"
        #'query-replace
        "Replace some occurrences of FROM-STRING with TO-STRING")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Query Replace Regexp…"
        #'query-replace-regexp
        "Replace some things after point matching REGEXP with TO-STRING")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Toggle Comment"
        #'comment-dwim
        "Toggle comment on selected region")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Write Region…"
        #'write-region
        "Write current region into specified file")))

   (lambda (filename description)
     (insert "* Hi There\nImma going fishing.\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))


;; -------------------------------------------------------------------
;; Context Menu: Show Markup/Toggle Images

(ert-deftest test-anju-context-menu-markup ()
  "Test for `anju-context-menu-markup'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-markup
   3
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Toggle Images"
        #'casual-org-toggle-images
        "Toggle images")

       (anju-test-menu-item
        item2
        "Show Markup"
        #'visible-mode
        "Toggle making all invisible text \
temporarily visible (Visible mode)"
        )))))


;; -------------------------------------------------------------------
;; Context Menu: Compilation Mode

(ert-deftest test-anju-context-menu-compile ()
  "Test for `anju-context-menu-compile'."

  (with-temp-buffer
    (compilation-mode)
    (anju-test-context-menu-function
     #'anju-context-menu-compile
     "Hello there"
     4
     (lambda (items)
       (let* ((i 0))
         (anju-test-menu-item (seq-elt items i) "--")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          (lambda () (casual-compile--select-mode-label
                                   "Recompile"
                                   "Refresh"))
          #'recompile
          "Re-compile the program including the current buffer")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Compile…"
          #'compile
          "Compile the program including the current buffer.  Default: \
run ‘make’")

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          (lambda () (casual-compile-unicode-get :kill))
          #'kill-compilation
          "Kill the current compilation or grep process"))))))


;; -------------------------------------------------------------------
;; Context Menu: Word Count

(ert-deftest test-anju-context-menu-wordcount ()
  "Test for `anju-context-menu-wordcount'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-wordcount
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Count Words"
        #'count-words
        "Count words")))))


;; -------------------------------------------------------------------
;; Context Menu: Window Management

(ert-deftest test-anju-context-menu-window ()
  "Test for `anju-context-menu-window'."

  (anju-test-context-menu-function
   #'anju-context-menu-window
   "Stub Text"
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (should (string-equal (seq-elt item1 2) "Window"))))))

(ert-deftest test-anju-context-window-management-menu ()
  "Test `anju-context-window-management-menu'."

  (anju-test-keymap
   anju-context-window-management-menu
   "Window"
   4
   (lambda (items)
     (let ((delete-window-item (seq-elt items 0))
           (split-horizontal-item (seq-elt items 1))
           (split-vertical-item (seq-elt items 2))
           (swap-menu (seq-elt items 3)))
       (anju-test-menu-item delete-window-item
                            "×"
                            #'delete-window
                            "Delete window")

       (anju-test-menu-item split-horizontal-item
                            "Split →"
                            #'mouse-split-window-horizontally
                            "Split right at mouse point")

       (anju-test-menu-item split-vertical-item
                            "Split ↓"
                            #'mouse-split-window-vertically
                            "Split below at mouse point")

       (let ((swap-kmap (seq-elt swap-menu 3)))
         (anju-test-keymap
          swap-kmap
          "Swap"
          4
          (lambda (items)
            (let ((up-item (seq-elt items 0))
                  (down-item (seq-elt items 1))
                  (left-item (seq-elt items 2))
                  (right-item (seq-elt items 3)))
              (anju-test-menu-item up-item
                                   "↑"
                                   #'windmove-swap-states-up
                                   "Swap window up")

              (anju-test-menu-item down-item
                                   "↓"
                                   #'windmove-swap-states-down
                                   "Swap window down")

              (anju-test-menu-item left-item
                                   "←"
                                   #'windmove-swap-states-left
                                   "Swap window left")

              (anju-test-menu-item right-item
                                   "→"
                                   #'windmove-swap-states-right
                                   "Swap window right")))))))))


;; -------------------------------------------------------------------
;; Context Menu: Rectangle Commands

(ert-deftest test-anju-context-menu-rectangle ()
  "Test for `anju-context-menu-rectangle'."

  (anju-test-context-menu-function-with-filetype
   ".txt"
   #'anju-context-menu-rectangle
   2
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-rectangle-menu kmap))))

   (lambda (filename description)
     (insert "hey they\nclittiak\nwhat is goin on?\n")
     (save-buffer)
     (transient-mark-mode)
     (goto-char (point-min))
     (rectangle-mark-mode)
     (goto-char (point-max))
     (activate-mark))))

;; (ert-deftest test-anju-context-menu--insert-into-context-menu-functions ()
;;   "Test for `anju-context-menu--insert-into-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-context-menu--remove-from-context-menu-functions ()
;;   "Test for `anju-context-menu--remove-from-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-reconfigure-context-menu-functions ()
;;   "Test for `anju-reconfigure-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-reset-context-menu-functions ()
;;   "Test for `anju-reset-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

(provide 'test-anju-context-menu)
;;; test-anju-context-menu.el ends here
