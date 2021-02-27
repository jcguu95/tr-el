;;; trash-health.el -mode -*- coding: utf-8; lexical-binding: t; -*-

(defun trash-health-check-db-file (db-file)
  "Return T if DB-FILE is healthy. Otherwise, return nil."
  (trash-record-p (trash-read-db-file db-file)))

(defun trash-health-ls-unhealthy ()
  (let ((fs (trash-ls-db)))
    (loop for f in fs
          unless (trash-health-check-db-file f)
          collect f)))

(defun trash-health-check-db ()
  "Return 'healthy if all db-files under *trash-db* is healthy in
  the sense of #'trash-health-check-db-file. Otherwise, return a
  list of unhealthy files."
  (let ((patients (trash-health-ls-unhealthy)))
    (if (eq patients nil) 'healthy patients)))

(provide 'trash-health)
