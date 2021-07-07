;;; janus.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Put a description of the package here

;;; Code:

(require 'cl-lib)
(require 's)
(require 'dash)

(defvar meq/var/current-theme nil)
(defvar meq/var/current-theme-mode nil)
(defvar meq/var/aliases '(:orange (orange flamingo-pink)))
(defvar meq/var/faces `(
    ;; Adapted From: http://ergoemacs.org/emacs/elisp_define_face.html
    (flamingo-pink . (:alternate ((((class color) (background light))
                                    :foreground "#ab5dee" :bold t)
                                    (((class color) (background dark))
                                    :foreground "#fca78e" :bold t))
                    :original ((t (:foreground "#fca78e" :bold t)))
                    :aliases ,(plist-get meq/var/aliases :orange)))
    (orange . (:alternate ((((class color) (background light))
                                    :foreground "#ab5dee" :bold t)
                                    (((class color) (background dark))
                                    :foreground "#ffb86c" :bold t))
                    :original ((t (:foreground "#ffb86c" :bold t)))
                    :aliases ,(plist-get meq/var/aliases :orange)))))

;;;###autoload
(defmacro meq/set-alternate-color (color) (interactive)
    (face-spec-set
        (intern (concat "meq/" (symbol-name color)))
        (plist-get (cdr (assq color meq/var/faces)) :alternate)
        'face-defface-spec))

;;;###autoload
(defmacro meq/set-original-color (color) (interactive)
    (face-spec-set
        (intern (concat "meq/" (symbol-name color)))
        (plist-get (cdr (assq color meq/var/faces)) :original)
        'face-defface-spec))

;;;###autoload
(defun meq/same-color-switch (name) (interactive)
    (mapc #'(lambda (color) (interactive)
        (let* ((contains-list (mapcar #'(lambda (alias) (interactive)
            (s-contains? (symbol-name alias) name)) (plist-get (cdr color) :aliases))))
        (if (--any? (and it t) contains-list)
            (eval `(meq/set-alternate-color ,(car color)))
            (eval `(meq/set-original-color ,(car color)))))) meq/var/faces))

;; (mapc #'(lambda (color) (interactive)
;;     (eval `(defface
;;         ,(intern (concat "meq/" (symbol-name (car color))))
;;         ',(plist-get (cdr color) (if (member "-p" command-line-args) :alternate :original))
;;         ,(symbol-name (car color))))) meq/var/faces)

(mapc #'(lambda (color) (interactive)
    `(face-spec-set
        ,(intern (concat "meq/" (symbol-name (car color))))
        ',(plist-get (cdr color) (if (member "-p" command-line-args) :alternate :original))
        'face-defface-spec)) meq/var/faces)

;;;###autoload
(defun meq/load-theme (theme) (interactive)
    (let* ((name (symbol-name theme)))
        (setq meq/var/current-theme theme)
        (setq meq/var/current-theme-mode (car (last (split-string name "-"))))
        (meq/same-color-switch name)
        (load-theme theme)))

;;;###autoload
(defun meq/which-theme nil (interactive)
    (when (member "--theme" command-line-args)
        (meq/load-theme (intern (concat
            (nth (1+ (seq-position command-line-args "--theme")) command-line-args)
            (if (member "--light" command-line-args) "-light" "-dark"))))))

;;;###autoload
(defun meq/switch-theme-mode nil (interactive)
    (meq/load-theme (intern (concat
        (replace-regexp-in-string "-dark" "" (replace-regexp-in-string "-light" "" (symbol-name meq/var/current-theme)))
        "-"
        (if (string= meq/var/current-theme-mode "light") "dark" "light")))))

(provide 'janus)
;;; janus.el ends here
