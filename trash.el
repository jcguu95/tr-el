;;  my trash.el
;;
;; goal:
;;
;; let user play with trash easily.. restore, inspect,
;; eliminate trash with predicates.. etc

;; estimate the size first before any operation!
;;
;; let user to add predicates to decide which trash goes to which pail

trash-root-dir
trash-db
#'trash-trash-file
#'trash-dired-trash-marked-files
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
