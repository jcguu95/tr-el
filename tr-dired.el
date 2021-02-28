;;; tr-dired.el -mode -*- coding: utf-8; lexical-binding: t; -*-

(cl-defun tr-dired-trash-marked-files
    (&optional (memo "")
               (confirm nil))
  "To be called in dired. It trashes all marked files, or the
file at point if no files are marked."
  (interactive)
  (tr-trash-files (dired-get-marked-files) memo))

(cl-defun tr-dired-trash-file-at-point
    (&optional (memo "")
               (confirm nil))
  "To be called in dired. It trashes the file at point."
  (interactive)
  (tr-trash-files (dired-get-filename) memo))

(provide 'tr-dired)
