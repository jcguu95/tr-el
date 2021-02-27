;; Another attempt, as the old trash.el isn't as well designed as
;; this.
;;
;; tr.el (tr for trash)

(defstruct tr-order
  from to)
(defstruct tr-record
  ts order status memo)

(mkdir "/tmp/-trash" t)
(mkdir "/tmp/-trash/store" t)
(defvar *tr-db* "/tmp/-trash/tr.db")
(defvar *tr-store* "/tmp/-trash/store")

(defun tr-now ()
  (ts-format (ts-now)))

(defun tr-reverse-order (order)
  "Functionally reverse the role in ORDER."
  (make-tr-order
   :from (tr-order-to order)
   :to (tr-order-from order)))

(cl-defun tr-perform-order
    (order &optional
           (ts (tr-now))
           (memo "")
           (confirm t)) ;; TODO let confirm into play

  "TODO to be described. It doesn't take responsibility of the
existence of either TO or FROM."

  (let ((from (tr-order-from order))
        (to (tr-order-to order)))

    (rename-file from to t) ;; this will over-write TO if it exists already!

    ;; TODO find out why the following doesn't perform if
    ;; #'rename-file errors.
    (write-region (format "%s\n"
                   (prin1-to-string
                    (make-tr-record
                     :ts ts :order order
                     :status nil :memo memo))) ;; TODO How to get the status of #'rename-file.
     nil *tr-db* 'append)))

(prin1-to-string
(make-tr-record :ts 1 :order 2 :status 3 :memo 4))

(cl-defun tr-undo-order
    (order &optional
           (ts (tr-now))
           (memo "") (confirm t)) ;; TODO let confirm into play
  "TODO yet to be described."
  (tr-perform-order (tr-reverse-order order) ts memo confirm))

(defun tr-trash-space (ts)
  (concat *tr-store* "/" ts))

(defun tr-wrap-trash (ts file)
  (concat (tr-trash-space ts)
          (file-truename file)))

(cl-defun tr-trash-files (files &optional (memo ""))
  "Trash all the files in FILES."
  (let ((ts (tr-now)))
    (loop for file in files
          do (let* ((from (file-truename file))
                    (to (tr-wrap-trash ts from))
                    (order (make-tr-order :from from :to to)))
               (mkdir (file-name-directory to) t)
               (tr-perform-order order ts)))))

(cl-defun tr-dired-trash-marked-files (&optional (memo ""))
  (interactive)
  (tr-trash-files (dired-get-marked-files) memo))

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
  (tr-ls-latest-n-records 1))

(defun tr-undo! ()
  "This function is inverse to itself."
  (tr-undo-order
   (tr-record-order
    (car (tr-latest-record)))))

(defun tr-purge-store (time-predicate)
  "TODO"
  (let ((to-purge
         (-filter (-compose time-predicate #'ts-parse)
                  (-remove (lambda (x) (string= x "."))
                           (mapcar #'file-name-base
                                   (directory-files *tr-store* ""))))))
    (loop for x in to-purge
          do (delete-directory (concat *tr-store* "/" x) t))))

;; TODO Notice that the two purgers (db and store) don't to
;; symmetric things. Add this notice in the readme.org.
(defun tr-purge-db (time-predicate)
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
  (tr-purge-store time-predicate)
  (tr-purge-db time-predicate))

(defun tr-purge-before-N-seconds-ago (N)
  (tr-purge (lambda (time)
              (> (ts-diff (ts-now) time) N))))

(defun tr-purge-before-N-days-ago (N)
  (tr-purge-before-N-seconds-ago (* N 60 60 24)))

;; ---

(defun tr-select-records ()) ;; TODO main user interface, as well as #'tr-dired-trash-marked-files
