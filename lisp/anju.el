;;; anju.el --- Mouse UX Customizations              -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Charles Choi

;; Author: Charles Choi <charles.choi@yummymelon.com>
;; URL: https://github.com/kickingvegas/anju
;; Keywords: tools
;; Version: 1.8.2-rc.1
;; Package-Requires: ((emacs "29.1") (casual "2.14.0") (markdown-mode "2.7"))

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

;; Anju is a project to align mouse interactions in Emacs with contemporary
;; (circa 2026) expectations. Effort towards this alignment is made in the
;; following areas:

;; - Context-sensitive menus
;; - De-emphasis of middle mouse button usage (binding <mouse-2>)
;; - Support direct manipulation when possible
;; - Re-organization of the main menu bar

;; The features offered by Anju are opinionated, but avoids unconventional
;; behavior. Anju aspires to bring a calmer mouse experience to Emacs.

;; INSTALLATION

;; To install Anju, add the command `anju-init' to your Emacs initialization
;; file.

;;     (anju-init)

;; This command will initialize `context-menu-mode' and reconfigure the
;; following mouse menus and bindings:

;; - Legacy mouse bindings
;; - Mode line bindings
;; - Main menu
;; - Context menus for different modes

;; The `anju-init' command can be customized to preference. See Info node
;; `(anju) Anju Initialization (anju-init)' for more detail.

;; While not required, the following additions to your Emacs initialization
;; file can further enhance your mouse experience:

;; - Enable `org-mouse'

;;     (require 'org-mouse)

;; - Add Markdown export support to Org mode
;;   - `M-x' `customize-variable' `org-export-backends', check `md' option.

;; - Globally bind `C-x 1' to `anju-toggle-one-window'.

;;     (keymap-global-set "C-x 1" #'anju-toggle-one-window)

;; - Set `use-file-dialog' to `t' to support mouse-driven-only dialog
;;   interactions, or `nil' to always get a mini-buffer prompt.


;;; Code:
(require 'anju-mode-line)
(require 'anju-main-menu)
(require 'anju-context-menu)


;;; Initialization Routines

;;;###autoload (autoload 'anju-init "anju" nil t)
(defun anju-init ()
  "Reconfigure Emacs mouse menus and bindings to Anju specification.

This initialization command for Anju reconfigures the following areas
of mouse menus and bindings:

- Legacy mouse bindings (`anju-unset-legacy-mouse-bindings-enable')
- Mode line bindings (`anju-mode-line-bindings-enable')
- Main menu (`anju-reconfigure-main-menu-enable')
- Context menus (`anju-reconfigure-context-menu-functions-enable')

Each area is controlled with a customizable variable and all are by
default t. Changes to any of these variables will require a restart of
Emacs.

The global minor mode `context-menu-mode' will be initialized if it
already has not been done so."
  (interactive)

  (unless context-menu-mode
    (context-menu-mode 1))

  (if anju-unset-legacy-mouse-bindings-enable
      (anju-utils--unset-legacy-mouse-bindings))

  (if anju-mode-line-bindings-enable
      (anju-mode-line--set-bindings))

  (if anju-reconfigure-main-menu-enable
      (run-hooks 'anju-reconfigure-main-menu-hook))

  (if anju-reconfigure-context-menu-functions-enable
      (anju-reconfigure-context-menu-functions)))

(provide 'anju)
;;; anju.el ends here
