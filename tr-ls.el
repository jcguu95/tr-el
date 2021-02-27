;;; tr-ls.el -mode -*- coding: utf-8; lexical-binding: t; -*-

(defun tr-ls-records-that (predicate)
  "Return the list of records that satisfy PREDICATE."
  (-filter predicate
           (ignore-errors
             (read (concat "(" (f-read-text *tr-db* 'utf-8) ")")))))

(defun tr-ls-all-records ()
  "Return all records from the database *TR-DB*"
  (tr-ls-records-that (lambda (dummy) t)))

;; _Exercise_ write the following functions using
;; #'tr-ls-records-that:
;;
;; > tr-ls-records-with-filename
;; > tr-ls-records-with-nondirectory-filename

(defun tr-ls-latest-n-records (n)
  "Take the latest N records from the database *TR-DB*."
  (-take n (-sort (lambda (a b)
                    (ts>= (ts-parse (tr-record-ts a))
                          (ts-parse (tr-record-ts b))))
                  (tr-ls-all-records))))

(defun tr-latest-record ()
  "Return the latest record."
  (tr-ls-latest-n-records 1))

(provide 'tr-ls)
