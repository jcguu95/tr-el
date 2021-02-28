;;; tr-retrieve.el -mode -*- coding: utf-8; lexical-binding: t; -*-

;; TODO main user interface for selecting records to later
;; TODO How to easily multiselect using ivy?
;; perform undoing.
;; (defun tr-select-records ()
;;   "TODO")

(require 'ivy)
(cl-defun tr-ivy-select-record (&optional (predicate (lambda (x) t)))
  "Prompt the user the list of all records to choose, and return
  the selected record."
  (read (ivy-read
         "Select order: "
         (mapcar #'prin1-to-string
                 (-filter predicate
                          (tr-ls-all-records)))
         :re-builder 'ivy--regex-plus)))

(defun tr-ivy-select-undo ()
  "Prompt the user a list of records to choose. Transform the
  selected record to an order, and undo that order."
  (tr-undo-record (tr-record-order (tr-ivy-select-record))))

(defun tr-ivy-select-restore ()
  "Same as #'tr-ivy-select-undo, but the selection list only
  contains records of type 'IN."
  (tr-undo-record
   (tr-record-order
    (tr-ivy-select-record
     (lambda (x) (eq 'in (tr-type-of-record x)))))))

(tr-type-of-record (tr-ivy-select-record))

(string-match "\\(dog\\|cat\\)" "There are two cats here." 0) ;; => 14

(provide 'tr-retrieve)
