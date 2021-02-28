;;; tr.el -mode -*- coding: utf-8; lexical-binding: t; -*-

;; let user play with trash easily.. restore, inspect,
;; eliminate trash with predicates.. etc

;; estimate the size first before any operation!
;; let user to add predicates to decide which trash goes to which pail

(require 'dash)
(require 'ts)

(defstruct tr-order
  from to)

(defstruct tr-record
  ts order status memo)

(mkdir (setq *tr-root-dir* "/tmp/-trash/") t)
(mkdir (setq *tr-store* (concat *tr-root-dir* "store") t))
(defvar *tr-db* (concat *tr-root-dir* "tr.db"))

(defun tr-now ()
  (ts-format (ts-now)))

(defun tr-reverse-order (order)
  "Functionally reverse the role in ORDER."
  (make-tr-order
   :from (tr-order-to order)
   :to (tr-order-from order)))

(cl-defun tr-perform-order (order &optional
                                  (ts (tr-now))
                                  (memo "")
                                  (confirm nil)) ;; TODO let confirm into play
  "Perform the ORDER.

One of the main basic utility that performs system change. It
doesn't take responsibility of the existence of either TO or
FROM."
  (let ((from (tr-order-from order))
        (to (tr-order-to order)))

    ;; Overwirte TO by FROM.
    (rename-file from to t)

    ;; TODO How to get the status of #'rename-file.
    (write-region (format "%s\n"
                   (prin1-to-string
                    (make-tr-record
                     :ts ts :order order
                     :status nil :memo memo)))
     nil *tr-db* 'append)))

(cl-defun tr-undo-order (order &optional
                               (ts (tr-now))
                               (memo "")
                               (confirm nil)) ;; TODO let confirm into play
  "Undo the ORDER."
  (tr-perform-order (tr-reverse-order order) ts memo confirm))

(defun tr-wrap-file-to-trash (ts file)
  "A trasher helper." ;; TODO merge this into #'tr-trash-files by label
  (concat (concat *tr-store* "/" ts)
          (file-truename file)))

(cl-defun tr-trash-files (files &optional (memo ""))
  "Trash all the files in FILES."
  (let ((ts (tr-now)))
    (loop for file in files
          do (let* ((from (file-truename file))
                    (to (tr-wrap-file-to-trash ts from))
                    (order (make-tr-order :from from :to to)))
               (mkdir (file-name-directory to) t)
               (tr-perform-order order ts)))))

(defun tr-undo! ()
  "This function is inverse to itself."
  (tr-undo-order
   (tr-record-order
    (car (tr-latest-record)))))

(defun tr-type-of-record (record)
  "A utility that distinguishes the type of the record RECORD.
Return 'IN if the record's order's TO-slot is a subdirectory of
*TR-STORE*."
  (if (equal 0 (string-match
                *tr-store*
                (tr-order-to (tr-record-order record))))
      'in
    'out))

(require 'tr-ls)
(require 'tr-dired)
(require 'tr-purge)
(require 'tr-retrieve)
