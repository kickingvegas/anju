;;; test-anju-utils.el --- Test Utils                -*- lexical-binding: t; -*-

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
(require 'anju-utils)
(require 'anju-test-utils)

(ert-deftest test-anju-reconfigure-context-menu-functions-enable ()
  "Test for `anju-reconfigure-context-menu-functions-enable'."
  (should (boundp anju-reconfigure-context-menu-functions-enable)))

(ert-deftest test-anju-reconfigure-main-menu-enable ()
  "Test for `anju-reconfigure-main-menu-enable'."
  (should (boundp anju-reconfigure-main-menu-enable)))

(ert-deftest test-anju-unset-legacy-mouse-bindings-enable ()
  "Test for `anju-unset-legacy-mouse-bindings-enable'."
  (should (boundp anju-unset-legacy-mouse-bindings-enable)))

(ert-deftest test-anju-mode-line-bindings-enable ()
  "Test for `anju-mode-line-bindings-enable'."
  (should (boundp anju-mode-line-bindings-enable)))

(ert-deftest test-anju-reconfigure-mouse-per-modes-enable ()
  "Test for `anju-reconfigure-mouse-per-modes-enable'."
  (should (boundp anju-reconfigure-mouse-per-modes-enable)))

(ert-deftest test-anju-reconfigure-main-menu-hook ()
  "Test for `anju-reconfigure-main-menu-hook'."
  (should (eq 'cons (type-of anju-reconfigure-main-menu-hook))))

(ert-deftest test-anju--frame-register-alist ()
  "Test for `anju--frame-register-alist'."
  (should (boundp anju--frame-register-alist)))

(ert-deftest test-anju-help-menu-remove-emacs-tutorial ()
  "Test for `anju-help-menu-remove-emacs-tutorial'."
  (should (boundp anju-help-menu-remove-emacs-tutorial)))

(ert-deftest test-anju-buffer-list-filter-functions ()
  "Test for `anju-buffer-list-filter-functions'."
  (should (eq 'cons
              (type-of anju-buffer-list-filter-functions)))

  (let* ((tests '(anju-buffer-list-project-filter
                  anju-buffer-list-compilation-filter
                  anju-buffer-list-grep-filter
                  anju-buffer-list-xref-filter
                  anju-buffer-list-eshell-filter
                  anju-buffer-list-shell-filter
                  anju-buffer-list-info-filter
                  anju-buffer-list-help-filter))
         (keys (map-keys anju-buffer-list-filter-functions)))

    (mapc (lambda (test)
            (should (member test keys)))
          tests)))


;; (ert-deftest test-anju-utils--command-in-new-frame ()
;;   "Test for `anju-utils--command-in-new-frame'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-utils--unset-legacy-mouse-bindings ()
;;   "Test for `anju-utils--unset-legacy-mouse-bindings'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-menu-label ()
;;   "Test for `anju-menu-label'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-middle-truncate ()
;;   "Test for `anju-middle-truncate'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(defun test--anju-transform-text-menu (kmap)
  (anju-test-keymap
   kmap
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
        "Convert the selected region to capitalized form")))))


(ert-deftest test-anju-transform-text-menu ()
  "Test for `anju-transform-text-menu'."
  (test--anju-transform-text-menu anju-transform-text-menu))


(defun test--anju-center-text-menu (kmap)
  (anju-test-keymap
   kmap
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
        "Center each nonblank line in the paragraph at or after point")
       ))))


(ert-deftest test-anju-center-text-menu ()
  "Test for `anju-center-text-menu'."
  (test--anju-center-text-menu anju-center-text-menu))


(defun test--anju-fill-text-menu (kmap)
  (anju-test-keymap
   kmap
   "Fill"
   8
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Paragraph"
        #'fill-paragraph
        "Fill paragraph at or after point")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Paragraph ⤶"
        #'fill-paragraph-semlf
        "Fill paragraph at or after point using semantic linefeeds")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Unfill Paragraph"
        #'unfill-paragraph
        "Join lines of this paragraph and fix up whitespace at joins")

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
        "Region as paragraph ⤶"
        #'fill-region-as-paragraph-semlf
        "Fill the region using semantic linefeeds as if it were a single paragraph")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Individual paragraphs"
        #'fill-individual-paragraphs
        "Fill paragraphs of uniform \
indentation within the region")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Non-uniform paragraphs"
        #'fill-nonuniform-paragraphs
        "Fill paragraphs within the region, \
allowing varying indentation within each")))))

(ert-deftest test-anju-fill-text-menu ()
  "Test for `anju-fill-text-menu'."
  (test--anju-fill-text-menu anju-fill-text-menu))



(ert-deftest test-anju-rectangle-menu ()
  "Test for `anju-rectangle-menu'."
  (test--anju-rectangle-menu anju-rectangle-menu))



;; (ert-deftest test-anju--scrub-frame-register-list ()
;;   "Test for `anju--scrub-frame-register-list'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju--new-register-id ()
;;   "Test for `anju--new-register-id'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju--window-configuration-to-register ()
;;   "Test for `anju--window-configuration-to-register'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-toggle-one-window ()
;;   "Test for `anju-toggle-one-window'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-utils)
;;; test-anju-utils.el ends here
