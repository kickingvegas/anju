;;; anju-context-menu.el --- Anju Context Menu Customization  -*- lexical-binding: t; -*-

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
(require 'mouse)
(require 'dired)
(require 'org)
(require 'org-table)
(require 'ol)
(require 'dictionary)
(require 'elisp-mode)
(require 'hideshow)
(require 'edebug)
(require 'info)
(require 'make-mode)
(require 'yank-media)
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-dired)
(require 'casual-org)
(require 'casual-ediff)
(require 'casual-compile)
(require 'casual-make)


;;; Context Menu: Dired

(defun anju-dired-duplicate-file ()
  "Duplicate the current file in Dired."
  (interactive)
  (when (derived-mode-p 'dired-mode)
    (let* ((filename (dired-get-filename))
           (target (concat (file-name-sans-extension filename)
                           " copy"
                           (file-name-extension filename t))))
      (message target)
      (if (file-directory-p filename)
          (copy-directory filename target)
        (copy-file filename target)))))

(defun anju-context-menu-dired (menu click)
  "Context menu hook function for Dired commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (derived-mode-p 'dired-mode) (not (anju-rectangle-selected-p)))
    (mouse-set-point click)
    (save-excursion
      (when (dired-file-name-at-point)
        (easy-menu-add-item menu nil
                            [dired-do-rename
                             dired-do-rename
                             :label "Rename to…"
                             :help "Rename or move file"])

        (easy-menu-add-item menu nil
                            [dired-do-copy
                             dired-do-copy
                             :label "Copy to…"
                             :help "Copy file"])

        (easy-menu-add-item menu nil
                            [dired-do-relsymlink
                             dired-do-relsymlink
                             :label "Symlink…"
                             :help "Make relative symlink"])

        (easy-menu-add-item menu nil
                            [dired-copy-filename-as-kill
                             dired-copy-filename-as-kill
                             :label "Copy name"
                             :help "Copy names of marked (or next ARG) files \
into the kill ring"])

        (easy-menu-add-item menu nil
                            [image-dired-dired-toggle-marked-thumbs
                             image-dired-dired-toggle-marked-thumbs
                             :label "Toggle Thumbnail"
                             :visible (string-match-p (image-file-name-regexp)
                                                      (dired-get-filename))
                             :help "Toggle thumbnails in front of marked \
file names in the Dired buffer"])

        (easy-menu-add-item
         menu
         nil
         ["Duplicate"
          anju-dired-duplicate-file
          :label (format "Duplicate “%s”"
                         (anju-filename-from-path (dired-get-filename)))

          :help "Duplicate selected item"])

        ;; (easy-menu-add-item menu nil
        ;;                     ["Change Mode…"
        ;;                      dired-do-chmod
        ;;                      :help "Change mode of file (chmod)"])

        (easy-menu-add-item menu nil
                            [dired-maybe-insert-subdir
                             dired-maybe-insert-subdir
                             :label "Insert Subdir"
                             :label (format "Insert “%s” View"
                                            (anju-filename-from-path (dired-get-filename)))
                             :visible (file-directory-p
                                       (dired-file-name-at-point))
                             :help "Insert subdir (sub-directory)"])
        (anju-context-menu-item-separator menu trash-separator)

        (easy-menu-add-item menu nil
                            [dired-do-delete
                             dired-do-delete
                             :label "Move to Trash…"
                             :visible (file-writable-p
                                       (dired-file-name-at-point))
                             :help "Delete all marked files"])

        (anju-context-menu-item-separator menu dired-separator))

      ;; (mouse-set-point click)

      (when (not (dired-file-name-at-point))
        (easy-menu-add-item menu nil
                            [dired-hide-subdir
                             dired-hide-subdir
                             :label (format
                                     "%s “%s” View"
                                     (if (dired-subdir-hidden-p
                                          (dired-current-directory))
                                         "Show" "Hide")
                                     (anju-filename-from-path
                                      (directory-file-name
                                       (dired-current-directory))))
                             :visible (and (dired-current-directory)
                                           (> (line-number-at-pos) 1) ; hack!
                                           (> (- (length dired-subdir-alist) 1) 0)
                                           (not (dired-file-name-at-point)))
                             :help "Toggle hide subdir (sub-directory)"])

        (easy-menu-add-item menu nil
                            [dired-kill-subdir
                             dired-kill-subdir
                             :label (format
                                     "Remove “%s” View"
                                     (anju-filename-from-path
                                      (directory-file-name
                                       (dired-current-directory))))
                             :visible (and (dired-current-directory)
                                           (> (line-number-at-pos) 1) ; hack!
                                           (> (- (length dired-subdir-alist) 1) 0)
                                           (not (dired-file-name-at-point)))
                             :help "Kill subdir (sub-directory)"]))

      (easy-menu-add-item menu nil casual-dired-sort-menu)

      (easy-menu-add-item menu nil
                          [dired-omit-mode
                           dired-omit-mode
                           :label "Omit Mode"
                           :style toggle
                           :selected dired-omit-mode
                           :help "Omit mode"])

      (easy-menu-add-item menu nil
                          [dired-hide-details-mode
                           dired-hide-details-mode
                           :label "Hide Details"
                           :style toggle
                           :selected dired-hide-details-mode
                           :help "Hide directory details"])

      (easy-menu-add-item menu nil
                          [dired dired
                           :label "📁 Dired…"
                           :help "Open Dired"])))
  menu)


;;; Context Menu: Scratch Buffer

(defun anju-context-menu-scratch (menu click)
  "Context menu hook function for journal commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (anju-at-org-table-p))
             (not (use-region-p))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu journal-separator)
      (easy-menu-add-item menu nil [scratch-buffer
                                    scratch-buffer
                                    :label "Scratch"
                                    :help "Switch to the *scratch* buffer"])))
  menu)


;;; Context Menu: Org Mode

(defun anju-at-org-table-p ()
  "Predicate if point is in an Org table."
  (if (derived-mode-p 'org-mode)
      (or (org-at-table-p) (org-at-TBLFM-p))
    nil))

(defun anju-org-stored-links-p ()
  "Predicate if `org-stored-links' is populated.
Return t if populated, nil otherwise."
  (if (> (length org-stored-links) 0)
      t
    nil))

(defun anju-org-element-empty-p ()
  "Predicate for Org body text to check it is not empty."
  (let* ((element (org-element-at-point))
         (c-beg (org-element-property :contents-begin element))
         (c-end (org-element-property :contents-end element)))
    (not (and c-beg c-end (> c-end c-beg)))))

(defun anju-line-empty-p ()
  "Predicate to test if line point is on is empty."
  (let ((begin (line-beginning-position))
        (end (line-end-position)))
    (= end begin)))

(easy-menu-define anju-org-table-region-menu nil
  "Key map for Org table region sub-menu."
  '("Org Table Region"
    [org-table-cut-region
     org-table-cut-region
     :label "Cut"
     :enable (and (bound-and-true-p rectangle-mark-mode) (use-region-p))
     :help "Cut Org table region"]

    [org-table-copy-region
     org-table-copy-region
     :label "Copy"
     :enable (and (bound-and-true-p rectangle-mark-mode) (use-region-p))
     :help "Copy Org table region"]

    [org-table-paste-rectangle
     org-table-paste-rectangle
     :label "Paste"
     :help "Paste Org table region"]))

(defun anju-org-table-recalculate ()
  "Recalculate an Org table."
  (interactive)
  (org-table-recalculate 4))

(defun anju-context-menu-org-mode (menu click)
  "Context menu hook function for Org mode commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'org-mode)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu org-separator)

      (cond
       ((and (org-at-heading-p) (not (anju-rectangle-selected-p)))
        (easy-menu-add-item menu nil
                            [org-todo
                             org-todo
                             :label "TODO…"
                             :help "Change the TODO state of an item"])

        (easy-menu-add-item menu nil
                            [org-toggle-heading
                             org-toggle-heading
                             :label "Change to Body"
                             :help "Convert headings to normal text, or items or text to headings"])

        (easy-menu-add-item menu nil
                            [org-clock-in
                             org-clock-in
                             :label "Clock In"
                             :visible (not (org-clocking-p))
                             :help "Clock in"])

        (easy-menu-add-item menu nil
                            [org-clock-out
                             org-clock-out
                             :label "Clock Out"
                             :visible (org-clocking-p)
                             :help "Clock out"])

        (easy-menu-add-item menu nil
                            [org-sort-entries
                             org-sort-entries
                             :label "Sort…"
                             :help "Sort entries on a certain level of an \
outline tree"])

        (easy-menu-add-item menu nil
                            [org-do-demote
                             org-do-demote
                             :label "Demote →"
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            [org-do-promote
                             org-do-promote
                             :label "Promote ←"
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            [org-demote-subtree
                             org-demote-subtree
                             :label "Demote Subtree →"
                             :help "Demote heading subtree"])

        (easy-menu-add-item menu nil
                            [org-promote-subtree
                             org-promote-subtree
                             :label "Promote Subtree ←"
                             :help "Promote heading subtree"]))

       ((and (org-at-item-p) (not (anju-rectangle-selected-p)))

        (if (org-at-item-checkbox-p)
            (easy-menu-add-item menu nil
                                [casual-org-checkbox-in-progress
                                 casual-org-checkbox-in-progress
                                 :label "In-Progress [-]"
                                 :help "Change checkbox state to in-progress [-]"])
          (easy-menu-add-item menu nil [org-toggle-item
                                        org-toggle-item
                                        :label "Change to Body"
                                        :visible (not (or (use-region-p)
                                                          (anju-line-empty-p)))
                                        :help "Convert item to normal line"]))

        (easy-menu-add-item menu nil
                            [org-cycle-list-bullet
                             org-cycle-list-bullet
                             :label "Cycle Bullet"
                             :help "Cycle through the different itemize/enumerate bullets"])

        (easy-menu-add-item menu nil
                            [org-sort-list
                             org-sort-list
                             :label "Sort…"
                             :help "Sort list items"])

        (easy-menu-add-item menu nil
                            [casual-org-toggle-list-to-checkbox
                             casual-org-toggle-list-to-checkbox
                             :label (if (org-at-item-checkbox-p)
                                        "Change to Item"
                                      "Change to Checkbox")
                             :help "Toggle Item/Checkbox"])

        (easy-menu-add-item menu nil
                            [org-indent-item
                             org-indent-item
                             :label "Demote →"
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            [org-outdent-item
                             org-outdent-item
                             :label "Promote ←"
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            [org-indent-item-tree
                             org-indent-item-tree
                             :label "Demote Subtree →"
                             :help "Demote item subtree"])

        (easy-menu-add-item menu nil
                            [org-outdent-item-tree
                             org-outdent-item-tree
                             :label "Promote Subtree ←"
                             :help "Promote item subtree"]))

       ((anju-at-org-table-p)
        (easy-menu-add-item menu nil
                            [casual-org-table-copy-reference-dwim
                             casual-org-table-copy-reference-dwim
                             :label (casual-org-table--reference-dwim)
                             :help "Copy Org table reference (field or range) into kill ring via mouse"])

        (easy-menu-add-item menu nil anju-org-table-region-menu)

        (easy-menu-add-item menu nil
                            [org-table-sort-lines
                             org-table-sort-lines
                             :label "Sort…"
                             :help "Sort table lines according to the column at point"])

        (easy-menu-add-item menu nil
                            [org-table-toggle-coordinate-overlays
                             org-table-toggle-coordinate-overlays
                             :label "Show Coordinates"
                             :style toggle
                             :selected org-table-coordinate-overlays
                             :help "Toggle the display of row/column numbers in tables"])

        (easy-menu-add-item menu nil
                            [anju-org-table-recalculate
                             anju-org-table-recalculate
                             :label "Recalculate"
                             :help "Recalculate table"])

        (easy-menu-add-item menu nil
                            [org-table-edit-formulas
                             org-table-edit-formulas
                             :label "Edit Table Formulas"
                             :help "Edit the formulas of the current table in a separate buffer"])

        ;; (easy-menu-add-item menu nil cc/insert-org-plot-menu)
        (easy-menu-add-item menu nil [org-plot/gnuplot
                                      org-plot/gnuplot
                                      :label "Run gnuplot"
                                      :help "Plot table using gnuplot"]))

       ;; so far nothing global
       (t
        (easy-menu-add-item menu nil [org-toggle-heading
                                      org-toggle-heading
                                      :label "Change to Heading"
                                      :visible (not (or (use-region-p)
                                                        (anju-line-empty-p)))
                                      :help "Convert headings to normal text, \
or items or text to headings"])

        (easy-menu-add-item menu nil [org-toggle-item
                                      org-toggle-item
                                      :label "Change to Item"
                                      :visible (not (or (use-region-p)
                                                        (anju-line-empty-p)))
                                      :help "Convert headings or normal lines \
to items, items to normal lines"])))

      (when (or (use-region-p)
                (eq (org-element-type (org-element-context)) 'link))
        (easy-menu-add-item menu nil
                            [org-insert-link
                             org-insert-link
                             :label "Link…"
                             :help "Insert a link.  At the prompt, enter the link"]))))
  menu)


;;; Context Menu: Info Mode


(defun anju-info-goto-node-web ()
  "Open node in web browser."
  (interactive)
  (Info-goto-node-web (Info-copy-current-node-name)))

(defun anju-context-menu-info-mode (menu click)
  "Context menu hook function for Info mode commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (derived-mode-p 'Info-mode)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu info-mode-separator)

      (easy-menu-add-item menu nil [Info-top-node
                                    Info-top-node
                                    :label "Top"
                                    :help "Go to the Top node of this file"])

      (easy-menu-add-item menu nil [Info-toc
                                    Info-toc
                                    :label "Table of Contents"
                                    :help "Go to a node with table of contents \
of the current Info file"])

      (easy-menu-add-item menu nil [Info-up
                                    Info-up
                                    :label "↑ Node"
                                    :help "Go to the superior node of this \
node"])

      (easy-menu-add-item menu nil [Info-backward-node
                                    Info-backward-node
                                    :label "← Node"
                                    :help "Go backward one node, considering \
all nodes as forming one sequence"])

      (easy-menu-add-item menu nil [Info-forward-node
                                    Info-forward-node
                                    :label "→ Node"
                                    :help "Go forward one node, considering \
all nodes as forming one sequence"])

      (easy-menu-add-item menu nil [info-apropos
                                    info-apropos
                                    :label "Apropos…"
                                    :help "Search indices of all known Info \
files on your system for STRING"])

      (easy-menu-add-item menu nil [Info-copy-current-node-name
                                    Info-copy-current-node-name
                                    :label "Copy node name"
                                    :help "Put the name of the current Info \
node into the kill ring"])

      (easy-menu-add-item menu nil [anju-info-goto-node-web
                                    anju-info-goto-node-web
                                    :label "Open node in web"
                                    :help "Open node in web browser"])))
  menu)


;;; Context Menu: Emacs Lisp Mode


(defun anju-form-name-at-point ()
  "Name of form at point."
  (save-excursion
    (beginning-of-defun)
    (let* ((fn (list-at-point))
           (form-name (seq-elt fn 1)))
      (if (symbolp form-name)
          form-name))))

(defun anju-form-delaration-at-point ()
  "Declaration of form at point as string."
  (save-excursion
    (beginning-of-defun)
    (let* ((fn (list-at-point))
           (form-declaration (seq-elt fn 0)))
      (if (symbolp form-declaration)
          form-declaration))))


(defun anju-point-in-ertdeftest-p ()
  "Predicate if point is in an ERT test."
  (string-equal "ert-deftest" (anju-form-delaration-at-point)))

(defun anju-ert-run-test-at-point ()
  "Run the ERT test at point."
  (interactive)
  (let ((test-name (anju-form-name-at-point)))
        ;; (message "ERT: %s" test-name)
        (ert test-name)))


(defun anju-edebug-mode-p ()
  "Predicate if `edebug-mode' is on."
  (if edebug-mode t nil))

(defun anju-edebug-defun ()
  "Convenience function to instrument function for Edebug."
  (interactive)
  (setq current-prefix-arg '(4))
  (call-interactively #'eval-defun))

(easy-menu-define anju-edebug-mode-menu nil
  "Keymap for Edebug mode menu."
  '("Mode"
    ["Step" edebug-step-mode
     :help "Stop at the next stop point encountered"]

    ["Go to ●" edebug-go-mode
     :help "Run until the next breakpoint"]

    ["Continue" edebug-continue-mode
     :help "Pause one second at each breakpoint, and then continue"]

    ["Next" edebug-next-mode
     :help "Stop at the next stop point encountered after an expression"]

    ["Trace" edebug-trace-mode
     :help "Pause (normally one second) at each Edebug stop point"]))


(easy-menu-define anju-edebug-breakpoint-menu nil
  "Keymap for Edebug breakpoint menu."
  '("Breakpoint"

    ["Set Breakpoint ●" edebug-set-breakpoint
     :help "Set breakpoint"]

    ["Set Conditional ⦿" edebug-set-conditional-breakpoint
     :help "Set conditional breakpoint"]

    ["Next ●" edebug-next-breakpoint
     :help "Next breakpoint"]

    ["Unset ●" edebug-unset-breakpoint
     :help "Unset breakpoint"]

    ["Unset all ●" edebug-unset-breakpoints
     :help "Unset all breakpoints"]))


(easy-menu-define anju-edebug-sexp-menu nil
  "Keymap for Edebug breakpoint menu."
  '("Sexp"

    ["Forward" edebug-forward-sexp
     :help "Forward sexp"]

    ["Step-in" edebug-step-in
     :help "Step in sexp"]

    ["Step-out" edebug-step-out
     :help "Step out sexp"]))


(easy-menu-define anju-hideshow-menu nil
  "Keymap for hideshow menu."
  '("Hide/Show"
    :visible hs-minor-mode

    [hs-toggle-hiding
     hs-toggle-hiding
     :label (if (hs-already-hidden-p) "Show Block" "Hide Block")
     :help "Toggle hiding"]

    ["Hide All" hs-hide-all
     :enable (not (hs-already-hidden-p))
     :help "Hide all"]

    ["Show All" hs-show-all
     :help "Show all"]))

(defun anju-context-menu-elisp (menu click)
  "Context menu hook function for Elisp commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (derived-mode-p 'emacs-lisp-mode)
             (not (derived-mode-p 'edebug-eval-mode))
             (not (anju-rectangle-selected-p)))

    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu emacs-lisp-separator)

      (if (anju-edebug-mode-p)
          (progn
            (easy-menu-add-item menu nil
                                ["Step" edebug-step-mode
                                 :help "Step"])

            (easy-menu-add-item menu nil
                                ["Here" edebug-goto-here
                                 :help "Here"])

            (easy-menu-add-item menu nil
                                anju-edebug-mode-menu)


            (easy-menu-add-item menu nil
                                anju-edebug-sexp-menu)

            (easy-menu-add-item menu nil
                                anju-edebug-breakpoint-menu)

            (easy-menu-add-item menu nil
                                ["Eval…" edebug-eval-expression
                                 :help "Eval expression"])

            (easy-menu-add-item menu nil
                                ["Previous" edebug-previous-result
                                 :help "Previous result"])

            (easy-menu-add-item menu nil
                                ["Suspend Edebug" edebug-view-outside
                                 :help "Suspend Edebug, run edebug-where to resume"])

            (easy-menu-add-item menu nil
                                ["Watchlist" edebug-visit-eval-list
                                 :help "Open watchlist"])

            (easy-menu-add-item menu nil
                                ["Stop execution" edebug-stop
                                 :help "Stop Edebug execution, useful for exiting from trace or continue loop"])

            (easy-menu-add-item menu nil
                                ["Exit" edebug-top-level-nonstop
                                 :help "Quit Edebug Nonstop"]))

        (easy-menu-add-item
         menu nil
         [eval-last-sexp
          eval-last-sexp
          :label "Eval Last Sexp"
          :help "Evaluate sexp before point; print value in the echo area"])

        (easy-menu-add-item
         menu nil
         [eval-defun
          eval-defun
          :label (format "Eval “%s”" (anju-form-name-at-point))
          :visible (anju-form-name-at-point)
          :help "Evaluate the top level form point is in"])

        (easy-menu-add-item
         menu nil
         [anju-edebug-defun
          anju-edebug-defun
          :label (format "Edebug “%s”" (anju-form-name-at-point))
          :visible (anju-form-name-at-point)
          :help "Evaluate the top level form point is in, stepping through with Edebug"])

        (easy-menu-add-item
         menu nil
         [elisp-eval-region-or-buffer
          elisp-eval-region-or-buffer
          :label (if (use-region-p) "Eval Region" "Eval Buffer")
          :help "Evaluate region or buffer"])

        (easy-menu-add-item
         menu nil
         anju-hideshow-menu)

        (easy-menu-add-item
         menu nil
         [xref-find-references-and-replace
          xref-find-references-and-replace
          :label (format "Rename “%s”" (thing-at-point 'symbol))
          :visible (let ((thing (thing-at-point 'symbol)))
                     (and thing
                          (not (string-match-p "^[-+]?[[:digit:]]*\\.?[[:digit:]]+$" thing))
                          (not (member (substring-no-properties thing) '("lambda" "nil")))))
          :help "Rename xref symbol"])

        (easy-menu-add-item
         menu nil
         [anju-ert-run-test-at-point
          anju-ert-run-test-at-point
          :label (format "Test “%s”" (anju-form-name-at-point))
          :visible (anju-point-in-ertdeftest-p)
          :help "ERT"])

        (easy-menu-add-item
         menu nil
         [anju-extract-lambda-to-defun
          anju-extract-lambda-to-defun
          :label "Extract 𝜆…"
          :visible (anju-point-on-lambda-p)
          :help "Convert lambda expression into a function"])

        (easy-menu-add-item
         menu nil
         [eval-expression
          eval-expression
          :label "Eval Expression…"
          :help "Evaluate expression and print result in mini-buffer"]))))
  menu)


(defun anju-context-menu-edebug-eval (menu click)
  "Context menu hook function for Edebug eval mode.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (derived-mode-p 'edebug-eval-mode)
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu edebug-eval-separator)

      (easy-menu-add-item
       menu nil
       [edebug-update-eval-list
        edebug-update-eval-list
        :label "Add symbol"
        :help "In the watchlist, type in symbol or sexp to add"])

      (easy-menu-add-item
       menu nil
       [edebug-delete-eval-item
        edebug-delete-eval-item
        :label "Delete symbol"
        :help "Place point on symbol or sexp to delete"])

      (easy-menu-add-item
       menu nil
       [edebug-eval-last-sexp
        edebug-eval-last-sexp
        :label "Eval last sexp"
        :help "Eval last sexp"])

      (easy-menu-add-item
       menu nil
       [edebug-eval-print-last-sexp
        edebug-eval-print-last-sexp
        :label "Insert last sexp"
        :help "Insert (print) eval of last sexp into watchlist"])

      (easy-menu-add-item
       menu nil
       [edebug-where
        edebug-where
        :label "Resume"
        :help "Resume code stepping"])))
menu)

(defun anju-point-on-lambda-p ()
  "Predicate if point is on a lambda symbol."
  (let* ((thing (thing-at-point 'symbol))
         (thing (if thing (substring-no-properties thing) nil)))
    (and thing (string-equal "lambda" thing))))

(defun anju-extract-lambda-to-defun (arg)
  "Extract lambda expression at point to defun named ARG.

When the point is on a lambda symbol, this command will prompt for a
function name ARG and will convert the lambda expression into a defun.
The new defun is not evaluated.

This converted function is put into a temporary buffer ‘*ARG*’ for
subsequent editing while the original lambda expression is replaced with
a reference to the new defun ARG."

  (interactive "sExtract lambda as: ")

  (if (anju-point-on-lambda-p)
      (progn
        (save-excursion
          (let* ((lfn (list-at-point))
                 (lfn-body (seq-subseq lfn 1))
                 (newfn ())
                 (newfn (push (intern arg) newfn))
                 (newfn (push 'defun newfn))
                 (newfn (append newfn lfn-body))
                 (lexp (prin1-to-string newfn))
                 (bufname (format "*%s*" arg))
                 (buf (get-buffer-create bufname)))

            (with-current-buffer (current-buffer)
              (switch-to-buffer-other-window buf)
              (emacs-lisp-mode)
              (insert lexp)
              (goto-char (point-min)))))

        (let ((delete-pair-blink-delay 0))
          (backward-up-list)
          (kill-sexp)
          (insert (format "#'%s" arg))
          (backward-sexp)))
    (message "not on lambda")))


;;; Context Menu: Buffer Navigation/Management

(defun anju-context-menu-buffers (menu click)
  "Context menu hook function for buffers commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (use-region-p))
             (not (anju-at-org-table-p))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu buffer-navigation-separator)
      (easy-menu-add-item menu nil [previous-buffer
                                    previous-buffer
                                    :label "← Buffer"
                                    :help "Go to previous buffer"])

      (easy-menu-add-item menu nil [next-buffer
                                    next-buffer
                                    :label "→ Buffer"
                                    :help "Go to next buffer"])

      (easy-menu-add-item menu nil [ibuffer
                                    ibuffer
                                    :label "≣ List All Buffers"
                                    :help "List all buffers"])))
  menu)


;;; Context Menu: Narrow/Widen

(defun anju-context-menu-narrow (menu click)
  "Context menu hook function for narrow commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (not (anju-at-org-table-p))
             (not (derived-mode-p 'Info-mode))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu narrow-separator)
      (cond ((use-region-p)
             (easy-menu-add-item menu nil
                                 [narrow-to-region narrow-to-region
                                  :label (anju-menu-label "Narrow Region")
                                  :help "Restrict editing in this buffer \
to the current region"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'prog-mode))
             (easy-menu-add-item menu nil
                                 [narrow-to-defun narrow-to-defun
                                  :label "Narrow to defun"
                                  :help "Restrict editing in this buffer \
to the current defun"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'org-mode))
             (easy-menu-add-item menu nil
                                 [org-narrow-to-subtree org-narrow-to-subtree
                                  :label "Narrow to subtree"
                                  :help "Restrict editing in this buffer \
to the current subtree"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'markdown-mode))
             (easy-menu-add-item menu nil
                                 [markdown-narrow-to-subtree
                                  markdown-narrow-to-subtree
                                  :label "Narrow to subtree"
                                  :help "Restrict editing in this buffer \
to the current subtree"])))

      (when (and (buffer-narrowed-p) (not (derived-mode-p 'Info-mode)))
        (easy-menu-add-item menu nil
                            [widen widen
                             :label "Widen buffer"
                             :help "Remove narrowing restrictions \
from current buffer"]))))
  menu)


;;; Context Menu: Open in…

(defun anju-context-menu-open-in (menu click)
  "Context menu hook function for open-in commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (not (use-region-p))
             (not (anju-at-org-table-p))
             (buffer-file-name)
             (not (derived-mode-p 'dired-mode))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu open-in-separator)
      (easy-menu-add-item menu nil
                          [dired-jump-other-window dired-jump-other-window
                           :label "📁 Open in Dired"
                           :help "Open file in Dired"])))
  menu)


;;; Context Menu: VC/Magit

(defun anju-context-menu-vc (menu click)
  "Context menu hook function for version control commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (vc-responsible-backend default-directory t)
             (not (derived-mode-p 'Info-mode))
             (not (use-region-p))
             (not (anju-at-org-table-p))
             (not (anju-rectangle-selected-p)))

    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu vc-separator)

      (when (and (package-installed-p 'magit)
                 (not (derived-mode-p 'magit-status-mode)))
        (require 'magit)
        (if (buffer-file-name)
            (easy-menu-add-item
             menu nil
             [magit-file-dispatch magit-file-dispatch
              :label "Magit Dispatch…"
              :help "Show the status of the current Git repository in a buffer"])
          (easy-menu-add-item
           menu nil
           [magit-status magit-status
            :label "Magit Status"
            :help "Show the status of the current Git repository in a buffer"])))

      (easy-menu-add-item
       menu nil
       [casual-ediff-revision-from-menu casual-ediff-revision-from-menu
        :label "Ediff revision…"
        :visible (and (bound-and-true-p buffer-file-name)
                      (vc-registered (buffer-file-name)))
        :help "Ediff this file with revision"])))
  menu)



;;; Context Menu: Region Operations

(defun anju-occur-selected-region ()
  "Occur selected region."
  (interactive)
  (let* ((start (region-beginning))
         (end (region-end))
         (regex (buffer-substring-no-properties start end)))
    (occur regex)))

(defun anju-context-menu-region (menu click)
  "Context menu hook function for region commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (use-region-p) (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu transform-text-separator)
      (easy-menu-add-item menu nil
                          [anju-occur-selected-region anju-occur-selected-region
                           :label (anju-menu-label "Occur")
                           :visible (eq (count-lines (region-beginning) (region-end)) 1)
                           :help "Show all lines in the current buffer \
containing a match for selected word"])

      (if (or (and (derived-mode-p 'org-mode) (not (anju-at-org-table-p)))
              (derived-mode-p 'markdown-mode))
          (easy-menu-add-item menu nil anju-style-menu))

      (if (not buffer-read-only)
          (easy-menu-add-item menu nil anju-transform-text-menu))

      (easy-menu-add-item menu nil
                          [query-replace query-replace
                           :label "Query Replace…"
                           :visible (not buffer-read-only)
                           :help "Replace some occurrences of FROM-STRING with TO-STRING"])

      (easy-menu-add-item menu nil
                          [query-replace-regexp query-replace-regexp
                           :label "Query Replace Regexp…"
                           :visible (not buffer-read-only)
                           :help "Replace some things after point matching REGEXP with TO-STRING"])

      (if (or (derived-mode-p 'prog-mode) (derived-mode-p 'org-mode))
          (easy-menu-add-item menu nil
                              [comment-dwim comment-dwim
                               :label "Toggle Comment"
                               :visible (not buffer-read-only)
                               :help "Toggle comment on selected region"]))

      (easy-menu-add-item menu nil
                          [write-region write-region
                           :label "Write Region…"
                           :help "Write current region into specified file"])))
  menu)


;;; Context Menu: Region Extension

(defun anju-yank-media-p ()
  "Predicate if media (images, HTML and the like) is in the clipboard.

This is built using the implementation of `yank-media'."
  (interactive)
  (unless yank-media--registered-handlers
    (user-error "The `%s' mode hasn't registered any handlers" major-mode))
  (let ((all-types nil))
    (pcase-dolist (`(,handled-type . ,handler)
                   yank-media--registered-handlers)
      (dolist (type (yank-media--find-matching-media handled-type))
        (push (cons type handler) all-types)))
    (if all-types t nil)))


(defun anju-yank-markdown-as-org ()
  "Yank Markdown text as Org.

This command will convert Markdown text in the top of the `kill-ring'
and convert it to Org using the pandoc utility."
  (interactive)
  (save-excursion
    (with-temp-buffer
      (yank)
      (shell-command-on-region
       (point-min) (point-max)
       "pandoc -f markdown -t org --wrap=preserve" t t)
      (kill-region (point-min) (point-max)))
    (yank)))


(defun anju-org-copy-region-as (backend)
  "Copy the BACKEND exported Org region to the system clipboard.

Code derived from Marcin Borkowski post at
URL `https://mbork.pl/2021-05-02_Org-mode_to_Markdown_via_the_clipboard'"
  (interactive)
  (if (use-region-p)
      (let* ((region
              (buffer-substring-no-properties
               (region-beginning)
               (region-end)))
             (clipping
              (org-export-string-as region backend t '(:with-toc nil))))
        (gui-set-selection 'CLIPBOARD clipping))))

(defun anju-org-copy-region-as-markdown ()
  "Copy the Markdown exported Org region to the system clipboard."
  (interactive)
  (if (use-region-p)
      (anju-org-copy-region-as 'md)))

(defun anju-org-copy-region-as-gfm ()
  "Copy the GitHub Markdown exported Org region to the system clipboard."
  (interactive)
  (if (use-region-p)
      (anju-org-copy-region-as 'gfm)))

(defun anju-org-copy-region-as-latex ()
  "Copy the LaTeX exported Org region to the system clipboard."
  (interactive)
  (if (use-region-p)
      (anju-org-copy-region-as 'latex)))

(defun anju-org-copy-region-as-ascii ()
  "Copy the ASCII exported Org region to the system clipboard."
  (interactive)
  (if (use-region-p)
      (anju-org-copy-region-as 'ascii)))

(defun anju-org-copy-region-as-html ()
  "Copy the HTML exported Org region to the system clipboard."
  (interactive)
  (if (use-region-p)
      (anju-org-copy-region-as 'html)))

(defun anju-org-copy-region-as-rtf ()
  "Export region to RTF and copy it to the clipboard.

Code from Daniel Martin
URL `https://gist.github.com/danielmartin/3c5d3a3a8cd24a3556379c5251651748'."
  (interactive)
  (save-window-excursion
    (let* ((buf (org-export-to-buffer 'html "*Formatted Copy*" nil nil t t))
           (html (with-current-buffer buf (buffer-string))))
      (ignore html)
      (with-current-buffer buf
        (shell-command-on-region
         (point-min)
         (point-max)
         "textutil -stdin -format html -convert rtf -stdout | pbcopy"))
      (kill-buffer buf))))

(easy-menu-define anju-context-menu-org-copy-as-menu nil
  "Key map for Org copy sub-menu."
  '("Copy as…"
    :visible (and (derived-mode-p 'org-mode) (use-region-p))

    ["GFM"
     anju-org-copy-region-as-gfm
     :visible (package-installed-p 'ox-gfm)
     :help "Copy region as GitHub Flavored Markdown to clipboard"]

    ["Markdown"
     anju-org-copy-region-as-markdown
     :help "Copy region as Markdown to clipboard"]

    ["LaTeX"
     anju-org-copy-region-as-latex
     :help "Copy region as LaTeX to clipboard"]

    ["HTML"
     anju-org-copy-region-as-html
     :help "Copy region as HTML to clipboard"]

    ["ASCII"
     anju-org-copy-region-as-ascii
     :help "Copy region as ASCII to clipboard"]

    ["Slack"
     org-slack-export-to-clipboard-as-slack
     :visible (package-installed-p 'ox-slack)
     :help "Copy as Slack to clipboard"]

    ["RTF"
     anju-org-copy-region-as-rtf
     :visible (eq system-type 'darwin)
     :help "Copy as RTF to clipboard"]))

(defun anju-context-menu-region-extension (menu click)
  "Region menu using MENU and CLICK."

  (when (and (derived-mode-p 'org-mode) (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (easy-menu-add-item menu nil
                          [org-insert-last-stored-link
                           org-insert-last-stored-link
                           :label "Paste Last Org Link"
                           :visible (and (not buffer-read-only) (anju-org-stored-links-p))
                           :help "Insert the last link stored in org-stored-links"]
                          "Clear")

      (easy-menu-add-item menu nil
                          [anju-yank-markdown-as-org
                           anju-yank-markdown-as-org
                           :label "Paste Markdown as Org"
                           :visible (not buffer-read-only)
                           :help "Convert clipboard (latest yank) of Markdown text to Org, then paste"]
                          "Clear")

      (easy-menu-add-item menu nil
                          [yank-media
                           yank-media
                           :label "Paste Media"
                           :visible (and (not buffer-read-only)
                                         (display-graphic-p)
                                         (anju-yank-media-p))
                           :help "Paste (yank) media"]
                          "Clear")

      (easy-menu-add-item menu nil
                          anju-context-menu-org-copy-as-menu
                          "Paste")))
  menu)



;;; Context Menu: Compilation Mode

(defun anju-context-menu-compile (menu click)
  "Context menu hook function for compile commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'compilation-mode)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu compile-separator)

      (easy-menu-add-item menu nil
                          [recompile
                           recompile
                           :label (casual-compile--select-mode-label
                                   "Recompile"
                                   "Refresh")
                           :enable (not (casual-compile--compilation-running-p))
                           :help "Re-compile the program including the \
current buffer"])

      (easy-menu-add-item menu nil
                          [compile
                           compile
                           :label "Compile…"
                           :visible (not (derived-mode-p 'grep-mode))
                           :enable (not (casual-compile--compilation-running-p))
                           :help "Compile the program including the current \
buffer.  Default: run ‘make’"])

      (easy-menu-add-item menu nil
                          [kill-compilation
                           kill-compilation
                           :label (casual-compile-unicode-get :kill)
                           :visible (casual-compile--compilation-running-p)
                           :help "Kill the current compilation or grep process"])))
  menu)




;;; Context Menu: Show Markup/Toggle Images

(defun anju-context-menu-markup (menu click)
  "Context menu hook function for markup commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (use-region-p))
             (member (derived-mode-p major-mode) '(org-mode markdown-mode))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (pcase (derived-mode-p major-mode)
        ('org-mode
         (anju-context-menu-item-separator menu org-mode-operations-separator)
         (easy-menu-add-item menu nil
                             [casual-org-toggle-images
                              casual-org-toggle-images
                              :label "Toggle Images"
                              :help "Toggle images"])

         (easy-menu-add-item menu nil
                             [visible-mode
                              visible-mode
                              :label "Show Markup"
                              :style toggle
                              :selected visible-mode
                              :help "Toggle making all invisible text \
temporarily visible (Visible mode)"]))

        ('markdown-mode
         (anju-context-menu-item-separator menu markdown-mode-operations-separator)
         (easy-menu-add-item menu nil
                             [markdown-toggle-markup-hiding
                              markdown-toggle-markup-hiding
                              :label "Hide Markup"
                              :style toggle
                              :selected markdown-hide-markup
                              :help "Toggle the display or hiding of markup"]))
        (m nil))))
  menu)


;;; Context Menu: Word Count

(defun anju-context-menu-wordcount (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (derived-mode-p 'text-mode)
             (not (anju-at-org-table-p))
             (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu count-words-separator)
      (easy-menu-add-item menu nil [count-words count-words
                                    :label "Count Words"
                                    :help "Count words"])))
  menu)


;;; Context Menu: Dictionary

(defun anju-context-menu-dictionary (menu click)
  "Context menu hook function for the dictionary command.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (use-region-p) (not (anju-rectangle-selected-p)))
    (save-excursion
      (mouse-set-point click)
      (easy-menu-add-item
       menu nil
       ["Look Up"
        dictionary-search-word-at-mouse
        :label (format "Look Up “%s”" (substring-no-properties (thing-at-point 'word)))
        :help "Look up selected region in dictionary"])))
  menu)



;;; Context Menu: Window Management

(easy-menu-define anju-context-window-management-menu nil
  "Keymap for mouse window management menu."
  '("Window"
    ["×" delete-window
     :visible (not (one-window-p t))
     :help "Delete window"]

    ["Split →" mouse-split-window-horizontally
     :help "Split right at mouse point"]

    ["Split ↓" mouse-split-window-vertically
     :help "Split below at mouse point"]

    ("Swap"
     :visible (and (eq (selected-window) (anju-window-under-mouse)) (not (one-window-p t)))
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
      :help "Swap window right"])))

(defun anju-context-menu-window (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (ignore click)

  (save-excursion
    (anju-context-menu-item-separator menu context-window--separator)
    (easy-menu-add-item menu nil anju-context-window-management-menu))
  menu)


;;; Context Menu: Rectangle Commands

(defun anju-context-menu-rectangle (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (or (and (anju-rectangle-selected-p)
                 (not (anju-at-org-table-p)))
            (and (not buffer-read-only)
                 (boundp 'killed-rectangle)
                 killed-rectangle))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu context-rectangle--separator)
      (easy-menu-add-item menu nil anju-rectangle-menu)))
  menu)


;;; Context Menu: Makefile Mode

(easy-menu-define anju-makefile-modes-menu nil
  "Keymap for mouse window management menu."
  '("Makefile Type"
    :label (format
            "Makefile Type (%s)"
                   (casual-make-mode-label major-mode))
    [makefile-automake-mode
     makefile-automake-mode
     :label "automake"
     :style radio
     :selected (derived-mode-p 'makefile-automake-mode)
     :help "An adapted ‘makefile-mode’ that knows about automake"]

    [makefile-bsdmake-mode
     makefile-bsdmake-mode
     :label "BSD"
     :style radio
     :selected (derived-mode-p 'makefile-bsdmake-mode)
     :help "An adapted ‘makefile-mode’ that knows about BSD make"]

    [makefile-gmake-mode
     makefile-gmake-mode
     :label "GNU"
     :style radio
     :selected (derived-mode-p 'makefile-gmake-mode)
     :help "An adapted ‘makefile-mode’ that knows about gmake"]

    [makefile-imake-mode
     makefile-imake-mode
     :label "imake"
     :style radio
     :selected (derived-mode-p 'makefile-imake-mode)
     :help "An adapted ‘makefile-mode’ that knows about imake"]

    [makefile-mode
     makefile-mode
     :label "make"
     :style radio
     :selected (and (derived-mode-p 'makefile-mode)
                    (not (or (derived-mode-p 'makefile-automake-mode)
                             (derived-mode-p 'makefile-bsdmake-mode)
                             (derived-mode-p 'makefile-gmake-mode)
                             (derived-mode-p 'makefile-imake-mode)
                             (derived-mode-p 'makefile-makepp-mode))))
     :help "Major mode for editing standard Makefiles"]

    [makefile-makepp-mode
     makefile-makepp-mode
     :label "makepp"
     :style radio
     :selected (derived-mode-p 'makefile-makepp-mode)
     :help "An adapted ‘makefile-mode’ that knows about makepp"]))


(defun anju-context-menu-make-mode (menu click)
  "Context menu hook function for `makefile-mode' commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'makefile-mode)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu context-makefile--separator1)

      (easy-menu-add-item menu nil
                          [compile
                           compile
                           :label "Compile…"
                           :help "Compile the program including the \
current buffer.  Default: run ‘make’"])

      (easy-menu-add-item menu nil
                          [makefile-insert-target-ref
                           makefile-insert-target-ref
                           :label "Insert target…"
                           :enable (not buffer-read-only)
                           :help "Complete on a list of known targets, \
then insert TARGET-NAME at point"])

      (easy-menu-add-item menu nil
                          [makefile-insert-macro-ref
                           makefile-insert-macro-ref
                           :label "Insert macro…"
                           :enable (not buffer-read-only)
                           :help "Complete on a list of known macros, \
then insert complete ref at point"])

      (easy-menu-add-item menu nil
                          [makefile-backslash-region
                           makefile-backslash-region
                           :label "\\ Region"
                           :visible (use-region-p)
                           :enable (not buffer-read-only)
                           :help "Insert, align, or delete end-of-line \
backslashes on the lines in the region"])

      (easy-menu-add-item menu nil
                          [makefile-insert-gmake-function
                           makefile-insert-gmake-function
                           :label "Insert GNU make function…"
                           :visible (derived-mode-p 'makefile-gmake-mode)
                           :enable (not buffer-read-only)
                           :help "Insert a GNU make function call"])

      (easy-menu-add-item menu nil
                          [casual-make-identify-autovar-region
                           casual-make-identify-autovar-region
                           :label "Identify Auto Var"
                           :visible (use-region-p)
                           :help "Identify GNU Make automatic variable in \
region from START to END"])

      (anju-context-menu-item-separator menu context-makefile--separator2)

      (easy-menu-add-item menu nil
                          [makefile-pickup-everything
                           makefile-pickup-everything
                           :label "Refresh targets and macros"
                           :help "Notice names of all macros and \
targets in Makefile"])

      (easy-menu-add-item menu nil
                          [makefile-pickup-filenames-as-targets
                           makefile-pickup-filenames-as-targets
                           :label "Include file names as targets"
                           :help "Scan the current directory for \
filenames to use as targets"])

      (easy-menu-add-item menu nil
                          [makefile-create-up-to-date-overview
                           makefile-create-up-to-date-overview
                           :label "Overview"
                           :help "Create a buffer containing an overview of \
the state of all known targets"])

      (easy-menu-add-item menu nil anju-makefile-modes-menu)))
  menu)


;;; Context Menu: Utility and Setup Functions

(defun anju-context-menu--insert-into-context-menu-functions (source target)
  "Insert SOURCE before TARGET in `context-menu-functions'.

This function provides finer grained control in inserting a context menu
function into `context-menu-functions' over `add-hook'."
  (let* ((s (default-value 'context-menu-functions))
         (i (seq-position s target)))

    (setq s (append (seq-subseq s 0 i)
                    (cons source (seq-subseq s i))))
    (setq-default context-menu-functions s)))

(defun anju-context-menu--remove-from-context-menu-functions (target)
  "Remove TARGET in `context-menu-functions'."
  (let* ((s (default-value 'context-menu-functions)))
    (setq s (remove target s))
    (setq-default context-menu-functions s)))

(defvar anju-context-menu--inventory
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
  "Inventory of all Anju-defined context menu functions.

These functions are intended to be used in `context-menu-functions'.")


(defun anju-extend-context-menu-functions-options (inventory)
  "Extend `context-menu-functions' options with INVENTORY.

This function is idempotent insofar as to not duplicate choice entries
from INVENTORY into `context-menu-functions'."
  (mapc (lambda (fn)
          (let* ((current-type (get 'context-menu-functions 'custom-type))
                 (base-choices (cdr (nth 1 current-type)))
                 (new-choice `(function-item ,fn)))
            (if (not (seq-contains-p base-choices new-choice)) ; make idempotent
                (put 'context-menu-functions 'custom-type
                     `(repeat (choice ,@base-choices ,new-choice))))))
        inventory))

(defun anju-reconfigure-context-menu-functions ()
  "Reconfigure `context-menu-functions'."
  (interactive)
  (anju-extend-context-menu-functions-options anju-context-menu--inventory)

  (when (not (get 'context-menu-functions 'saved-value))
    (let ((inventory (seq-remove
                      (lambda (fn)
                        (eq fn #'anju-context-menu-region-extension))
                      (reverse anju-context-menu--inventory))))


     (mapc (lambda (fn)
            (if (not (member fn context-menu-functions))
                (add-hook 'context-menu-functions fn)))
           inventory)))

  (if (member #'context-menu-middle-separator context-menu-functions)
      (anju-context-menu--insert-into-context-menu-functions #'anju-context-menu-region-extension
                                                             #'context-menu-middle-separator))
  (if (member #'context-menu-minor context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-minor))
  (if (member #'context-menu-local context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-local))
  (if (member #'context-menu-middle-separator context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-middle-separator)))

(defun anju-reset-context-menu-functions ()
  "Reset `context-menu-functions'."
  (interactive)
  (mapc (lambda (fn)
          (anju-context-menu--remove-from-context-menu-functions fn))
        (reverse anju-context-menu--inventory)))

(provide 'anju-context-menu)
;;; anju-context-menu.el ends here
