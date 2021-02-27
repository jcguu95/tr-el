;;; trash.el -mode -*- coding: utf-8; lexical-binding: t; -*-

;;
;;  my trash.el
;;
;; goal:
;;
;; let user play with trash easily.. restore, inspect,
;; eliminate trash with predicates.. etc

;; estimate the size first before any operation!
;; let user to add predicates to decide which trash goes to which pail

(mkdir (setf *trash-root-dir* "/tmp/trash/") t)
(mkdir (setf *trash-db* (concat *trash-root-dir* ".db")) t)
(mkdir (setf *trash-store* (concat *trash-root-dir* "store")) t)

;; TODO how to ensure transaction is either done or undone?
(defstruct trash-record
  timestamp files direction message memo)

(require 'ts) thanks, alphapapa.
(defun trash-time-string ()
  "Return the current time string with timezone in the format
that this program prefers."
  (ts-format (ts-now)))
(defun trash-time-parse (str)
  "The time parser this program favors."
  (ts-parse str))

(defun trash-write-record-to-db (trash-record)
  "Write TRASH-RECORD into the database under *TRASH-DB*."
  (unless (trash-record-p trash-record)
    (error "Input must be a legt trash-record."))
  (let* ((time (trash-record-timestamp trash-record))
         (target (concat *trash-db* "/" time)))
    (write-region (prin1-to-string trash-record) nil target)))

(defun trash-trash-files (files)
  "Trash all files in the list FILES to the trash-store directory
specified by the moment the operation is performed. Make and
timestamp a single trash-record, and write to the database."
  (let ((now (trash-time-string)))
    (loop for file in files
          do (let* ((abso (file-truename file))
                    (pail (concat *trash-store* "/" now))
                    (target (concat pail "/" (file-name-nondirectory abso))))
               (mkdir pail t)
               (trash-write-record-to-db
                (make-trash-record
                 :timestamp now :files files
                 :direction 'in
                 ;; TODO Add options to add messages and memos.
                 :message nil :memo ""))
               ;; TODO Better status report?
               (rename-file abso target)))))

(defun trash-dired-trash-marked-files ()
  "In dired, trash the marked files, or the file at point if none
is marked, using #'trash-trash-files."
  ;; TODO add options for user confirmation.
  ;; TODO add message to confirm that operation is done.
  (interactive)
  (trash-trash-files (dired-get-marked-files)))

;; (defun filemeta-ls-data-files ()
;;   "List all data files under *FILEMETA-ROOT-DIR*."
;;   (directory-files-recursively *filemeta-root-dir* ""))

  ;; (ignore-errors (read (f-read-text data-file 'utf-8)))

(defun trash-ls-db ()
  "List all files under *TRASH-DB*"
  (directory-files-recursively *trash-db* ""))

(defun trash-read-db-file (db-file)
  (ignore-errors (read (f-read-text db-file 'utf-8))))

(defun trash-read-db ()
  "Perform health check for the db *TRASH-DB*. If unhealthy,
throw error. If healthy, returns all trash-records read from the
db."
  (if (eq (trash-health-check-db) 'healthy)
      (loop for f in (trash-ls-db)
            collect (trash-read-db-file f))
      (error "*trash-db* is unhealthy. Use #'trash-health-check-db to manually detect patients.")))

(defun trash-read-db-timely-sorted ()
  "Return the timely sorted list of all trashes."
  (-sort (lambda (a b)
           (ts>= (ts-parse (trash-record-timestamp a))
                 (ts-parse (trash-record-timestamp b))))
         (trash-read-db)))

(defun trash-ls-last-N-trash (N)
  "List the last N trashes thrown in the db, sorted timely."
  (-take N (trash-read-db-timely-sorted)))

(defun trash-restore-trash (file trash-record)
  "Restore FILE if it is a member of TRASH-RECORD."
  (let ((time (trash-record-timestamp trash-record))
        (files (trash-record-files trash-record)))
    (if (member file files)
        (rename-file ;; TODO how to handle/monitor potential errors?
         (concat *trash-store* "/"
                 time "/"
                 (file-name-nondirectory file))
         file)
      (error "FILE is not a member in TRASH-RECORD."))))

(defun trash-restore-all-from-trash-record (trash-record)
  "Restore all files from the TRASH-RECORD"
  (let ((files (trash-record-files trash-record)))
    (loop for file in files
          do (trash-restore-trash file trash-record))))

(provide 'trash)
