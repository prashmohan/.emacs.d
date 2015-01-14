;;; prash-scratch.el ---

;; Copyright 2011 Prashanth Mohan
;;
;; Author: prashmohan@gmail.com
;; Version: $Id: prash-scratch.el,v 0.0 2011/09/30 16:32:18 prmohan Exp $
;; Keywords:
;; X-URL: not distributed yet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;

;; Put this file into your load-path and the following into your ~/.emacs:
;;   (require 'prash-scratch)

;;; Code:

(provide 'prash-scratch)
(eval-when-compile
  (require 'cl))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make Scratch buffer persistent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; http://blog.lifeflow.jp/2010/02/emacs-scratch.html
(defun save-scratch-buffer ()
  "Save scratch buffer. Return nil if buffer is not modified."
  (interactive)
  (when (get-buffer "*scratch*")
    (with-current-buffer (get-buffer "*scratch*")
      (if (buffer-modified-p)
          (let* ((file (expand-file-name "~/.emacs.d/scratch"))
                 (recentf-exclude '("\\.emacs\\.d/scratch$"))
                 (bf (or (get-file-buffer file)
                         (find-file-noselect file t))))
            (with-current-buffer bf
              (erase-buffer)
              (insert-buffer-substring-no-properties "*scratch*")
              (save-buffer))
            (kill-buffer bf)
            (set-buffer-modified-p nil)
            (message "Wrote %s" file))
        (message "(No changes need to be saved)")
        nil))))

(defun read-scratch-buffer ()
  "Read scratch buffer.
Return nil if file for save is not found."
  (let ((file "~/.emacs.d/scratch"))
    (if (file-exists-p file)
        (with-current-buffer (get-buffer-create "*scratch*")
          (erase-buffer)
          (insert-file-contents file)
          (set-buffer-modified-p nil))
      nil)))

(defun save-and-initialize-scratch-buffer ()
  "Initialize scratch buffer."
  (interactive)
  (when (or (not (interactive-p))
            (yes-or-no-p "Really backup and initialize scratch buffer? "))
    (let ((m (if (save-scratch-buffer)
                 " backuped and"
               "")))
      (with-current-buffer (get-buffer "*scratch*")
        (erase-buffer)
        (insert initial-scratch-message)
        (message "Scratch buffer%s initialized." m))
      nil)))

(add-hook 'lisp-interaction-mode-hook
          (lambda ()
            (define-key lisp-interaction-mode-map "\C-x\C-s" 'save-scratch-buffer)
            (define-key lisp-interaction-mode-map "\C-xk" 'save-and-initialize-scratch-buffer)))

(setq initial-major-mode 'lisp-interaction-mode)
(setq initial-scratch-message ";; initial message\n") ;

(add-hook 'after-init-hook
          'read-scratch-buffer)
(add-hook 'kill-emacs-hook
          'save-scratch-buffer)

;;; prash-scratch.el ends here
