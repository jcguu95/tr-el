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
  timestamp files message memo)

(defun trash-time-string ()
  "Return the current time string with timezone in the format
that this program prefers."
  (format-time-string "%Y%m%dT%H%M%S%z"))

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
                    (target (concat pail "/" (file-name-base abso))))
               (mkdir pail t)
               (trash-write-record-to-db
                (make-trash-record
                 :timestamp now :files files
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

#'trash-untrash-trash
;; what if it cannot be successfully untrashed? say mother dir is
;; missing, or original path is populated?
#'trash-show-latest-trash
#'trash-untrash-latest-trash
#'trash-show-latest-nth-trash
#'trash-untrash-latest-nth-trash
#'trash-show-latest-trashes (n m)
#'trash-untrash-latest-trashes (n m)
#'trash-restore-file
#'trash-untrash-trash
;; need also a buffer/GUI interface to quickly select trashes to
;; be restored.. or i should simply use dired? Something like
;; #'trash-dired-restore-marked-files that only is supposed to be
;; run in the trash dir.
#'trash-dired-untrash-marked-trashes

#'trash-list
#'trash-healthy-db
#'trash-eliminate-file                  ; dangerous and shouldn't been used
#'trash-eliminate-trash
