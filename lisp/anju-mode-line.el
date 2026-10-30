;;; anju-mode-line.el --- Anju Mode Line Customization  -*- lexical-binding: t; -*-

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
(require 'project)
(require 'anju-utils)

(defcustom anju-mode-line-buffer-list-function #'anju-buffer-list-menu-items
  "Function that populates the mode line buffer name popup menu.

Assign this variable to a function that returns a value that conforms to
the “MENU” parameter of `popup-menu'.

This setting allows for customization of the buffer list (or any other
menu content) when the mode line buffer name (identifier) is
clicked (typically with mouse 1).

Users who wish define their own menu should override this value with
their own function. It is highly recommended that such users look at the
source to `anju-buffer-list-menu-items' as a start to defining their own menu
function."
  :type 'function
  :group 'anju)


;;; Mode Line Customization

(easy-menu-define anju-window-management-menu nil
  "Keymap for mouse window management menu."
  '(nil
    ["×" mouse-delete-window
     :visible (not (one-window-p t))
     :help "Delete window"]

    ["Split →" split-window-horizontally
     :visible (eq (selected-window) (anju-window-under-mouse))
     :help "Split right"]

    ["Split ↓" split-window-vertically
     :visible (eq (selected-window) (anju-window-under-mouse))
     :help "Split below"]

    ("Swap"
     :visible (and (eq (selected-window) (anju-window-under-mouse)) (not (one-window-p t)))
     ["→" windmove-swap-states-right
      :visible (window-in-direction 'right)
      :help "Swap window right"]

     ["←" windmove-swap-states-left
      :visible (window-in-direction 'left)
      :help "Swap window left"]

     ["↑" windmove-swap-states-up
      :visible (window-in-direction 'above)
      :help "Swap window up"]

     ["↓" windmove-swap-states-down
      :visible (window-in-direction 'below)
      :help "Swap window down"])

    ("Flip"
     :visible (and (eq (selected-window) (anju-window-under-mouse))
                   (not (one-window-p t))
                   (fboundp 'window-layout-flip-leftright)
                   (fboundp 'window-layout-flip-topdown))

     ["↔︎" window-layout-flip-leftright
      :visible (and (fboundp 'window-layout-flip-leftright)
                    (not (one-window-p))
                    (or (window-in-direction 'left)
                        (window-in-direction 'right)))
      :help "Flip WINDOW’s child windows horizontally"]

     ["↕︎" window-layout-flip-topdown
      :visible (and (fboundp 'window-layout-flip-topdown)
                    (not (one-window-p))
                    (or (window-in-direction 'above)
                        (window-in-direction 'below)))
      :help "Flip WINDOW’s child windows vertically"])

    ("Rotate"
     :visible (and (eq (selected-window) (anju-window-under-mouse))
                   (not (one-window-p t))
                   (fboundp 'window-layout-rotate-anticlockwise)
                   (fboundp 'window-layout-rotate-clockwise))

     ["↻" window-layout-rotate-clockwise
      :help "Rotate layout of WINDOW’s child windows clockwise by 90 degrees"]

     ["↺" window-layout-rotate-anticlockwise
      :help "Rotate layout of WINDOW’s child windows counterclockwise by 90 degrees"])

    ["Transpose" window-layout-transpose
     :visible (and (eq (selected-window) (anju-window-under-mouse))
                   (fboundp 'window-layout-transpose)
                   (not (one-window-p)))
     :help "Transpose child windows of WINDOW"]))


(defun anju-window-under-mouse ()
  "Return the live window under the current mouse pointer.

Derived from code found at URL
`https://emacs.stackexchange.com/questions/21497/how-to-find-the-window-under-the-mouse-pointer'."
  (interactive)
  (let* ((mouse-pos (mouse-position))
         (frame (car mouse-pos))
         (x (cadr mouse-pos))
         (y (cddr mouse-pos))
         (window (window-at x y frame)))
    window))

(defun anju-popup-window-management-menu (click)
  "Popup mouse window management with CLICK."
  (interactive "e")
  (popup-menu anju-window-management-menu click))

(defun anju-popup-buffer-menu (click)
  "Popup mouse buffer navigation with CLICK."
  (interactive "e")
  (popup-menu (funcall anju-mode-line-buffer-list-function) click))


;;; Buffer Filter Logic

(defun anju-buffer-list--filter (filter buffers &optional count)
  "Apply FILTER on BUFFERS, taking the first COUNT if defined."
  (let ((result (seq-filter filter buffers)))
    (if count
        (seq-take result count)
      result)))

(defun anju-temporary-buffer-filter (buf)
  "Return t if BUF name is has pattern *<name>*."
  (let* ((bufname (string-trim (buffer-name buf))))
    (not
     (or
      (string-match-p "^\\*.*\\*$" bufname)
      (string-match-p "^\\*info\\*\\(<[[:digit:]]*>\\)*$" bufname)
      (string-match-p "^\\*eshell\\*\\(<[[:digit:]]*>\\)*$" bufname)
      (string-match-p "\~.*~$" bufname) ; filter out ediff buffers
      ))))

(defun anju-info-buffer-filter (buf)
  "Return t if BUF is an Info buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'Info-mode)))

(defun anju-help-buffer-filter (buf)
  "Return t if BUF is a Help buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'help-mode)))

(defun anju-eshell-buffer-filter (buf)
  "Return t if BUF is an Eshell buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'eshell-mode)))

(defun anju-shell-buffer-filter (buf)
  "Return t if BUF is a Shell buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'shell-mode)))

(defun anju-compilation-buffer-filter (buf)
  "Return t if BUF is a Compilation buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'compilation-mode)))

(defun anju-grep-buffer-filter (buf)
  "Return t if BUF is a Grep buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'grep-mode)))

(defun anju-xref-buffer-filter (buf)
  "Return t if BUF is a Xref buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'xref--xref-buffer-mode)))

(defun anju-filter-buffers-in-directory (buffers dir)
  "Filter BUFFERS whose default directory is DIR."
  (let ((dir (expand-file-name dir)))
    (seq-filter (lambda (b)
                  (let ((bdir (expand-file-name
                               (buffer-local-value 'default-directory b))))
                    (string-match dir bdir)))
                buffers)))

(defun anju-buffer-list-project-filter (buffers &optional count)
  "Filter BUFFERS using `project-current', taking the first COUNT if defined.

First filter BUFFERS through `anju-temporary-buffer-filter' and then
filter remaining buffers using the root directory of `project-current'.
If there is no project, then `default-directory' is used."
  (let* ((buffers (seq-filter #'anju-temporary-buffer-filter buffers))
         (curdir (if (project-current)
                     (project-root (project-current))
                   default-directory))
         (buffers (anju-filter-buffers-in-directory buffers curdir)))
    (if count
        (seq-take buffers count)
      buffers)))

(defun anju-buffer-list-plain-filter (buffers &optional count)
  "Filter BUFFERS for plain names only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-temporary-buffer-filter buffers count))

(defun anju-buffer-list-info-filter (buffers &optional count)
  "Filter BUFFERS for Info buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-info-buffer-filter buffers count))

(defun anju-buffer-list-help-filter (buffers &optional count)
  "Filter BUFFERS for Help buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-help-buffer-filter buffers count))

(defun anju-buffer-list-eshell-filter (buffers &optional count)
  "Filter BUFFERS for Eshell buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-eshell-buffer-filter buffers count))

(defun anju-buffer-list-shell-filter (buffers &optional count)
  "Filter BUFFERS for Shell buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-shell-buffer-filter buffers count))

(defun anju-buffer-list-compilation-filter (buffers &optional count)
  "Filter BUFFERS for Compilation buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-compilation-buffer-filter buffers count))

(defun anju-buffer-list-grep-filter (buffers &optional count)
  "Filter BUFFERS for Grep buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-grep-buffer-filter buffers count))

(defun anju-buffer-list-xref-filter (buffers &optional count)
  "Filter BUFFERS for Xref buffers only, taking the first COUNT if defined."
  (anju-buffer-list--filter #'anju-xref-buffer-filter buffers count))

(defun anju-process-buffer-list-filter-functions (buffers)
  "Process `anju-process-buffer-list-filter-functions' to filter BUFFERS.

- BUFFERS : List of buffers, usually from `buffer-list'"

  (let* ((apply-result (map-apply
                        (lambda (k v)
                          (if (fboundp k)
                              (funcall k buffers v)
                            (progn
                              (message "WARNING: %s is undefined." (symbol-name k))
                              nil)))
                        anju-buffer-list-filter-functions)))
    (seq-reduce #'append apply-result '())))

(defun anju-buffer-list-menu-items ()
  "Vector of menu items populating `anju-popup-buffer-menu'.

The list of menu items can be configured with the customizable variable
`anju-buffer-list-filter-functions'.

This function called by indirection via the variable
`anju-mode-line-buffer-list-function'."

  (let* ((open-buffers (buffer-list))
         (all-buffers (remove (current-buffer) open-buffers))
         (all-buffers (anju-process-buffer-list-filter-functions all-buffers))
         (buffer-items (mapcar (lambda (buf)
                                 (vector (format "%s" (buffer-name buf))
                                         `(lambda () (interactive) (switch-to-buffer ,buf))
                                         :visible (and (eq (selected-window) (anju-window-under-mouse)))))
                               all-buffers))

         (menu-items (append buffer-items
                             '("--")
                             '(["Set Selected" mouse-set-point
                                :visible (not (and (eq (selected-window) (anju-window-under-mouse))))
                                :help "Set window at point as selected"]

                               ["← Previous" previous-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Previous Buffer"]

                               ["→ Next" next-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Next buffer"]

                               ["≣ List All Buffers" ibuffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "List all buffers"]))))
      menu-items))

(defun anju-mode-line--set-bindings ()
  "Set Anju bindings."
  (keymap-set mode-line-buffer-identification-keymap
              "<mode-line> <mouse-1>"
              #'anju-popup-buffer-menu)

  (keymap-global-set "<mode-line> <double-mouse-1>" #'anju-toggle-one-window)

  ;; (keymap-global-set "<vertical-scroll-bar> <mouse-3>"
  ;;                    #'mouse-split-window-vertically)

  (keymap-global-set "<mode-line> <down-mouse-3>"
                     #'anju-popup-window-management-menu))


(provide 'anju-mode-line)
;;; anju-mode-line.el ends here
