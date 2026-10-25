;;; test-anju-modes.el --- Test Modes                -*- lexical-binding: t; -*-

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
(require 'ert)
(require 'mouse)
(require 'dired)
(require 'ibuffer)
(require 'bookmark)

(ert-deftest test-anju-modes-dired-setup ()
  "Test for `anju-modes-dired-setup'."
  (add-hook 'dired-mode-hook #'anju-modes-dired-setup)
  (save-window-excursion
    (dired "~")
    (should (eq mouse-1-click-follows-link 'double))
    (should (eq (keymap-lookup dired-mode-map "M-<mouse-1>")
                #'anju-modes-dired-mouse-toggle-mark))
    (should (eq (keymap-lookup dired-mode-map "C-M-<mouse-1>")
                #'browse-url-of-dired-file))))

(ert-deftest test-anju-modes-ibuffer-setup ()
  "Test for `anju-modes-ibuffer-setup'."
  (add-hook 'ibuffer-mode-hook #'anju-modes-ibuffer-setup)
  (save-window-excursion
    (ibuffer)

    (should (eq (keymap-lookup ibuffer-name-map "<mouse-1>")
                #'mouse-set-point))

    (should (eq (keymap-lookup ibuffer-name-map "<double-mouse-1>")
                #'ibuffer-mouse-visit-buffer))

    (should (eq (keymap-lookup ibuffer-name-map "M-<mouse-1>")
                #'ibuffer-mouse-toggle-mark))

    (should (eq (keymap-lookup ibuffer-mode-filter-group-map "<mouse-1>")
                #'mouse-set-point))

    (should (eq (keymap-lookup ibuffer-mode-filter-group-map "<double-mouse-1>")
                #'ibuffer-mouse-toggle-filter-group))

    (should (eq (keymap-lookup ibuffer-mode-filter-group-map "M-<mouse-1>")
                #'ibuffer-mouse-toggle-mark))))



(ert-deftest test-anju-modes-bookmark-bmenu-setup ()
  "Test for `anju-modes-bookmark-bmenu-setup'."
  (add-hook 'bookmark-bmenu-mode-hook #'anju-modes-bookmark-bmenu-setup)
  (save-window-excursion
    (list-bookmarks)
    (should (eq mouse-1-click-follows-link 'double))

    (should (eq (keymap-lookup bookmark-bmenu-mode-map "M-<mouse-1>")
                #'anju-modes-bookmark-bmenu-mouse-toggle-mark))))


(provide 'test-anju-modes)
;;; test-anju-modes.el ends here
