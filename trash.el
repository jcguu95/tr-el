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
  timestamp file message memo)

(defun trash-time-string ()
  "Return the current time string with timezone in the format
that this program prefers."
  (format-time-string "%Y%m%dT%H%M%S%z"))

(defun trash-trash-file (file)
  ;; TODO add batch removal.. to ensure things removed at the
  ;; same time have the same timestamp.
  (let* ((abso (file-truename file))
         (now (trash-time-string))
         (pail (concat *trash-store* "/" now))
         (target (concat pail "/" (file-name-base abso))))

    (mkdir pail t)
    (make-trash-record :timestamp now :file abso
                       :message nil :memo "") ;; TODO let user add memo by option
    ;; move file to trash.. in the correct destination named by
    ;; timestamp report status
    (rename-file abso target)))


#'trash-trash-file
#'trash-dired-trash-marked-files
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
