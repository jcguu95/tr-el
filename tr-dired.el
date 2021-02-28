;;; tr-dired.el -mode -*- coding: utf-8; lexical-binding: t; -*-

(cl-defun tr-dired-trash-marked-files (&optional (memo ""))
  (interactive)
  (tr-trash-files (dired-get-marked-files) memo))

(cl-defun tr-dired-trash-file-at-point (&optional (memo ""))
  (interactive)
  (tr-trash-files (dired-get-filename) memo))

(provide 'tr-dired)
