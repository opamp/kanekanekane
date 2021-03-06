(in-package :cl-user)
(defpackage kanekanekane.book-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.utils
        :kanekanekane.db.users
        :kanekanekane.db.book
        :kanekanekane.db.categories)
  (:export :prepare-values
           :make-basepoint-date
           :write-new
           :rewrite-data
           :eliminate-data
           :read-data
           :calculate-balance
           :simplified-book-data
           :simplified-book-lst
           :read-and-simplified-data
           :read-and-simplified-data-from-basepoint))
(in-package :kanekanekane.book-control)

(define-condition invalid-input-value (error)
  ((valname :initarg :valname :initform nil)
   (msg :initarg :msg :initform "" :reader msg-of)))

(define-condition absence-of-data (error)
  ((msg :initarg :msg :initform "" :reader msg-of)))

(defun prepare-name (name)
  (cond
    ((null (typep name 'simple-array))
     (error 'invalid-input-value :valname "name" :msg "invalid type"))
    ((= (length name) 0)
     (error 'invalid-input-value :valname "name" :msg "zero length"))
    (t name)))

(defun prepare-date (date)
  (let ((date-lst (handler-case (stringdate-to-lst date)
                    (error () nil))))
    (cond
      ((null date-lst)
       (error 'invalid-input-value :valname "date-lst" :msg "invalid date data"))
      ((/= (length date-lst) 3)
       (error 'invalid-input-value :valname "date-lst" :msg "missing or excess data size"))
      ((< (first date-lst) 0)
       (error 'invalid-input-value :valname "date-lst" :msg "year data is minus"))
      ((or (<= (second date-lst) 0) (> (second date-lst) 12))
       (error 'invalid-input-value :valname "date-lst" :msg "month date is out-of-range"))
      ((or (<= (third date-lst) 0) (> (third date-lst) 31))
       (error 'invalid-input-value :valname "date-lst" :msg "day date is out-of-range"))
      (t date))))


(defun prepare-income (income)
  (if (typep income 'boolean)
      income
      (error 'invalid-input-value :valname "income" :msg "invalid type")))

(defun prepare-amount (amount)
  (let ((amount (handler-case (parse-integer amount)
                  (error () nil))))
    (cond
      ((null amount)
       (error 'invalid-input-value :valname "amount" :msg "invalid value"))
      ((<= amount 0)
       (error 'invalid-input-value :valname "amount" :msg "the amount of income/outlay <= 0"))
      (t amount))))

(defun prepare-category (category)
  (cond
    ((null (typep category 'simple-array))
     (error 'invalid-input-value :valname "category" :msg "invalid type"))
    ((= (length category) 0)
     (error 'invalid-input-value :valname "category" :msg "zero length"))
    (t category)))

(defun prepare-comment (comment)
  (let ((comment (if comment comment "")))
    (if (typep comment 'simple-array)
        comment
        (error 'invalid-input-value :value "comment" :msg "invalid type"))))

(defun prepare-values (name date income amount category comment)
  (handler-case
      (let ((name (prepare-name name))
            (date (prepare-date date))
            (income (prepare-income income))
            (amount (prepare-amount amount))
            (category (prepare-category category))
            (comment (prepare-comment comment)))
        (values `(:name
                  ,name
                  :date
                  ,date
                  :income
                  ,income
                  :amount
                  ,amount
                  :category
                  ,category
                  :comment
                  ,comment)
                "OK"))
    (invalid-input-value (e) (values nil (msg-of e)))
    (absence-of-data (e) (values nil (msg-of e)))
    (error () (values nil "critical error"))))

(defun write-new (name date income amount category comment username)
  (let ((cat-data (aif (find-cate category income username)
                       it
                       (create-new-cate-and-return category income username))))
    (when cat-data
      (create-new-item name date amount comment (getf cat-data :id))
      t)))

(defun delete-cate-when-cate-id-is-zero (cate-id)
  (let ((cate-id-num (number-of-cate-id cate-id)))
    (when (= cate-id-num 0)
      (delete-cate cate-id))))

(defun rewrite-data (id name date income amount category comment username)
  (let ((current-data (read-item-and-cate-by-id id))
        (new-cate-data (find-cate category income username)))
    (if (null current-data)
        (values current-data nil (format nil "id = ~A data is not found" id))
        (let ((new-cate-data (if (null new-cate-data)
                                 (create-new-cate-and-return category income username)
                                 new-cate-data)))
          (rewrite-item id name date amount comment (getf new-cate-data :id))
          (when (/= (getf current-data :cate-id) (getf new-cate-data :id))
            (delete-cate-when-cate-id-is-zero (getf current-data :cate-id)))
          (values current-data (read-item-and-cate-by-id id) "OK")))))

(defun eliminate-data (id)
  (let ((target-data (read-item-and-cate-by-id id)))
    (when target-data
      (eliminate-item id)
      (delete-cate-when-cate-id-is-zero (getf target-data :cate-id))
      target-data)))

(defun read-data (from to username)
  (let ((from (if from (prepare-date from) nil))
        (to (if to (prepare-date to) nil))
        income-data outlay-data)
    (dolist (itm (read-items from to username))
      (if (getf itm :income)
          (setf income-data (append income-data (list itm)))
          (setf outlay-data (append outlay-data (list itm)))))
    (values income-data outlay-data)))

(defun calculate-balance (username &key (offset 0) from to)
  (let ((data (read-items from to username))
        (sum offset))
    (dolist (itm data)
      (let ((income (getf itm :income))
            (val (getf itm :val)))
        (if income
            (setf sum (+ sum val))
            (setf sum (- sum val)))))
    sum))

(defun make-basepoint-date (basepoint-day)
  (let* ((today (today-list))
         (basepoint-year (if (<= basepoint-day (third today))
                             (first today)
                             (if (= (second today) 1)
                                 (- (first today) 1)
                                 (first today))))
         (basepoint-month (if (<= basepoint-day (third today))
                              (second today)
                              (if (= (second today) 1)
                                  12
                                  (- (second today) 1))))
         (basepoint-date (list basepoint-year basepoint-month basepoint-day)))
    (if (date-exist-p basepoint-year basepoint-month basepoint-day)
        basepoint-date
        (labels ((new-basepoint-day (current-day)
                   (if (date-exist-p basepoint-year basepoint-month current-day)
                       (list basepoint-year basepoint-month current-day)
                       (new-basepoint-day (- current-day 1)))))
          (new-basepoint-day (- basepoint-day 1))))))

(defun simplified-book-data (itm)
  `(:id ,(getf itm :id)
    :record-date ,(getf itm :record-date)
    :title ,(getf itm :title)
    :cateid ,(getf itm :cate-id)
    :incometype ,(getf itm :income)
    :category ,(getf itm :catename)
    :val ,(getf itm :val)
    :comment ,(getf itm :comment)))

(defun simplified-book-lst (lst &optional (predicate #'>))
  (let (rtn)
    (dolist (itm lst)
      (setf rtn (append rtn (list (simplified-book-data itm)))))
    (sort rtn predicate :key #'(lambda (x) (getf x :record-date)))))

(defun read-and-simplified-data (from to username)
  (multiple-value-bind (income-data outlay-data)
      (read-data from to username)
    (let ((rtn-data (append income-data outlay-data)))
      (mapcar #'book-data-date-to-iso8601 (simplified-book-lst rtn-data)))))

(defun read-and-simplified-data-from-basepoint (username)
  (let* ((userinfo (select-user-with-username username))
         (from-date (make-basepoint-date (getf userinfo :basepoint)))
         (to-date (today-list)))
    (multiple-value-bind (income-data outlay-data)
      (read-data (listdate-to-string from-date) (listdate-to-string to-date) username)
    (labels ((summarize (data)
               (let ((sum 0)
                     cate
                     (daily (make-date-plist from-date to-date :initial-element 0)))
                (dolist (elem data)
                  (let ((cate-id (getf elem :cate-id))
                        (catename (getf elem :catename))
                        (record-date (getf elem :record-date))
                        (val (getf elem :val)))
                    (setf sum (+ sum val))
                    (setf (getf cate (intern catename :keyword))
                          (+ (getf cate (intern catename :keyword) 0) val))
                    (setf (getf daily (intern record-date :keyword))
                          (+ (getf daily (intern record-date :keyword) 0) val))))
                `(:sum ,sum :cate ,cate :daily ,daily))))
      (let ((income-summary (summarize (mapcar #'book-data-date-to-iso8601 income-data)))
             (outlay-summary (summarize (mapcar #'book-data-date-to-iso8601 outlay-data))))
        (values
         (mapcar #'book-data-date-to-iso8601 (simplified-book-lst (append income-data outlay-data)))
         (getf income-summary :sum)
         (getf income-summary :cate)
         (getf income-summary :daily)
         (getf outlay-summary :sum)
         (getf outlay-summary :cate)
         (getf outlay-summary :daily)))))))
