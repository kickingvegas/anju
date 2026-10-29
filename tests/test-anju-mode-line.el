;;; test-anju-mode-line.el --- Mode line tests       -*- lexical-binding: t; -*-

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
(require 'anju-mode-line)
(require 'anju-test-utils)

(ert-deftest test-anju-mode-line-buffer-list-function ()
  "Test for `anju-mode-line-buffer-list-function'."
  (should (fboundp anju-mode-line-buffer-list-function)))

(ert-deftest test-anju-window-management-menu ()
  "Test for `anju-window-management-menu'."
  (anju-test-keymap
   anju-window-management-menu
   nil
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "×"
        #'mouse-delete-window
        "Delete window")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Split →"
        #'split-window-horizontally
        "Split right")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Split ↓"
        #'split-window-vertically
        "Split below")

       (let* ((item (seq-elt items (cl-incf i)))
              (kmap (seq-elt item 3)))
         (anju-test-keymap
          kmap
          "Swap"
          4
          (lambda (items)
            (let ((i 0))
              (anju-test-menu-item
               (seq-elt items i)
               "→"
               #'windmove-swap-states-right
               "Swap window right")
              (anju-test-menu-item
               (seq-elt items (cl-incf i))
               "←"
               #'windmove-swap-states-left
               "Swap window left")
              (anju-test-menu-item
               (seq-elt items (cl-incf i))
               "↑"
               #'windmove-swap-states-up
               "Swap window up")
              (anju-test-menu-item
               (seq-elt items (cl-incf i))
               "↓"
               #'windmove-swap-states-down
               "Swap window down")))))

       (let* ((item (seq-elt items (cl-incf i)))
              (kmap (seq-elt item 3)))
         (anju-test-keymap
          kmap
          "Flip"
          2
          (lambda (items)
            (let ((i 0))
              (anju-test-menu-item
               (seq-elt items i)
               "↔︎"
               #'window-layout-flip-leftright
               "Flip WINDOW’s child windows horizontally")
              (anju-test-menu-item
               (seq-elt items (cl-incf i))
               "↕︎"
               #'window-layout-flip-topdown
               "Flip WINDOW’s child windows vertically")))))


       (let* ((item (seq-elt items (cl-incf i)))
              (kmap (seq-elt item 3)))
         (anju-test-keymap
          kmap
          "Rotate"
          2
          (lambda (items)
            (let ((i 0))
              (anju-test-menu-item
               (seq-elt items i)
               "↻"
               #'window-layout-rotate-clockwise
               "Rotate layout of WINDOW’s child windows clockwise by 90 degrees")
              (anju-test-menu-item
               (seq-elt items (cl-incf i))
               "↺"
               #'window-layout-rotate-anticlockwise
               "Rotate layout of WINDOW’s child windows counterclockwise by 90 degrees")))))))))

;; (ert-deftest test-anju-window-under-mouse ()
;;   "Test for `anju-window-under-mouse'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-popup-window-management-menu ()
;;   "Test for `anju-popup-window-management-menu'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-popup-buffer-menu ()
;;   "Test for `anju-popup-buffer-menu'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-temporary-buffer-filter ()
;;   "Test for `anju-temporary-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-info-buffer-filter ()
;;   "Test for `anju-info-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-help-buffer-filter ()
;;   "Test for `anju-help-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-buffer-list-menu-items ()
;;   "Test for `anju-buffer-list-menu-items'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-mode-line--set-bindings ()
;;   "Test for `anju-mode-line--set-bindings'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-mode-line)
;;; test-anju-mode-line.el ends here
