;;; tr-purge.el -mode -*- coding: utf-8; lexical-binding: t; -*-

(defun tr-purge-store (time-predicate)
  "Purge all entries in the trash store *TR-STORE* that satisfy
the TIME-PREDICATE."
  (let ((to-purge
         (-filter (-compose time-predicate #'ts-parse)
                  (-remove (lambda (x) (string= x "."))
                           (mapcar #'file-name-base
                                   (directory-files *tr-store* ""))))))
    (loop for x in to-purge
          do (delete-directory (concat *tr-store* "/" x) t))))

(defun tr-purge-db (time-predicate)
  "Purge all entries in the database *TR-DB* that satisfy the
TIME-PREDICATE."
  (let* ((all-records (tr-ls-all-records))
         (to-stay (-filter (lambda (x)
                             (not (funcall time-predicate
                                           (ts-parse (tr-record-ts x)))))
                           all-records)))

    ;; erase the whole *tr-db* ;; FIXME somehow dangerous?
    (copy-file *tr-db* "/tmp/tr-backup" t)
    (write-region "" nil *tr-db*)

    ;; start rewriting
    (loop for entry
          in to-stay
          do (write-region (format "%s\n" (prin1-to-string entry))
                           nil *tr-db* 'append))))

(defun tr-purge (time-predicate)
  "Purge all entries in the database *TR-DB* and the store
*TR-STORE* that satisfy the TIME-PREDICATE."
  (tr-purge-store time-predicate)
  (tr-purge-db time-predicate))

;; examples

(defun tr-purge-before-N-seconds-ago (N)
  (tr-purge (lambda (time)
              (> (ts-diff (ts-now) time) N))))

(defun tr-purge-before-N-days-ago (N)
  (tr-purge-before-N-seconds-ago (* N 60 60 24)))

(provide 'tr-purge)
