;;; anju-modes.el --- Anju Mode Customizations       -*- lexical-binding: t; -*-

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

;; Mode-specific customizations.

;;; Code:
(require 'mouse)


;; Dired
(require 'dired)

(defun anju-modes-dired-mouse-toggle-mark ()
  "Toggle mark of a Dired item via mouse."
  (interactive)
  (unless (use-region-p)
    (mouse-set-point last-input-event)
    (save-excursion
      (if (char-equal (char-after (line-beginning-position)) dired-marker-char)
        (call-interactively #'dired-unmark)
      (call-interactively #'dired-mark)))))

(defun anju-modes-dired-setup ()
  "Anju-specific Dired mode hook function.

This function is intended to be added to `dired-mode-hook'.

The following configurations are done to `dired-mode':

- Use single-click for selection and double-click for opening.
- Toggles mark of a Dired item with M-<mouse–1>."

  (setq-local mouse-1-click-follows-link 'double)
  (keymap-set dired-mode-map "M-<mouse-1>" #'anju-modes-dired-mouse-toggle-mark))


;; IBuffer
(require 'ibuffer)

(defun anju-modes-ibuffer-setup ()
  "Anju-specific IBuffer mode hook function.

This function is intended to be added to `ibuffer-mode-hook'.

The following configurations are done to `ibuffer-mode':

- Use single-click for selection and double-click for opening.
- Toggles mark of an IBuffer item with M-<mouse–1>."

  (keymap-set ibuffer-name-map "<mouse-1>" #'mouse-set-point)
  (keymap-set ibuffer-name-map "<double-mouse-1>" #'ibuffer-mouse-visit-buffer)
  (keymap-set ibuffer-name-map "M-<mouse-1>" #'ibuffer-mouse-toggle-mark)

  (keymap-set ibuffer-mode-filter-group-map
              "<mouse-1>" #'mouse-set-point)
  (keymap-set ibuffer-mode-filter-group-map
              "<double-mouse-1>" #'ibuffer-mouse-toggle-filter-group)
  (keymap-set ibuffer-mode-filter-group-map
              "M-<mouse-1>" #'ibuffer-mouse-toggle-mark))


;; Bookmarks
(require 'bookmark)

(defun anju-modes-bookmark-bmenu-mouse-toggle-mark ()
  "Toggle mark of a bookmark via mouse."
  (interactive)
  (mouse-set-point last-input-event)
  (save-excursion
    (forward-line 0)
    (if (looking-at-p ">")              ; oof this string check is fragile
        (bookmark-bmenu-unmark)
      (bookmark-bmenu-mark)
      (forward-line -1))))

(defun anju-modes-bookmark-bmenu-setup ()
  "Anju-specific Bookmark menu hook function.

This function is intended to be added to `bookmark-bmenu-mode-hook'.

The following configurations are done to `bookmark-bmenu-mode':

- Use single-click for selection and double-click for opening.
- Toggles mark of a bookmark with M-<mouse–1>."

  (setq-local mouse-1-click-follows-link 'double)
  (keymap-set bookmark-bmenu-mode-map "M-<mouse-1>"
              #'anju-modes-bookmark-bmenu-mouse-toggle-mark))


;; Functions

(defun anju-modes-reconfigure-mouse ()
  "Reconfigure mouse behavior for different modes.

Anju distinguishes modes whose content is treated as a hypertext
document with those whose content is more akin to an application. For
the latter, a single-click <mouse–1> event is treated as a selection
action and a double-click <mouse–1> event is treated as an open action.

In addition, mark toggling is bound to M-<mouse–1>.

Modes reconfigured to support the above distinction are:

- `dired-mode'
- `ibuffer-mode'
- `bookmark-bmenu-mode'

Reconfiguration is implemented via mode hook for each mode."

  (add-hook 'dired-mode-hook #'anju-modes-dired-setup)
  (add-hook 'ibuffer-mode-hook #'anju-modes-ibuffer-setup)
  (add-hook 'bookmark-bmenu-mode-hook #'anju-modes-bookmark-bmenu-setup))

(provide 'anju-modes)
;;; anju-modes.el ends here
