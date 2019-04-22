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
           :write-new
           :read-data
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

(defun read-data (from to username)
  (let ((from (if from (prepare-date from) nil))
        (to (if to (prepare-date to) nil))
        income-data outlay-data)
    (dolist (itm (read-items from to username))
      (if (getf itm :income)
          (setf income-data (append income-data (list itm)))
          (setf outlay-data (append outlay-data (list itm)))))
    (values income-data outlay-data)))

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

(defun read-data-from-basepoint (username)
  (let ((userinfo (select-user-with-username username)))
    (read-data (listdate-to-string (make-basepoint-date (getf userinfo :basepoint)))
               (listdate-to-string (today-list))
               username)))

;; (defun read-and-simplified-data-from-basepoint (username)
;;   (multiple-value-bind (income-data outlay-data)
;;       (read-data-from-basepoint username)
;;     (let ((income 0)
;;           (outlay 0))
;;       (dolist (income-elem income-data)
;;         (setf income (+ income (getf income-elem :val))))
;;       (dolist (outlay-elem outlay-data)
;;         (setf outlay (+ outlay (getf outlay-elem :val))))
;;       (values income outlay))))

(defun read-and-simplified-data-from-basepoint (username)
  (multiple-value-bind (income-data outlay-data)
      (read-data-from-basepoint username)
    (let ((income 0)
          (outlay 0)
          (income-cate-sum (make-hash-table))
          (outlay-cate-sum (make-hash-table)))
      (dolist (income-elem income-data)
        (let ((cate-id (getf income-elem :cate-id))
              (cate-name (getf income-elem :catename))
              (income-val (getf income-elem :val)))
          (setf income (+ income income-val))
          (let ((hash-val (gethash cate-id income-cate-sum)))
            (if (null hash-val)
                (setf (gethash cate-id income-cate-sum) (list (intern cate-name :keyword) income-val))
                (setf (gethash cate-id income-cate-sum) (list (first hash-val)
                                                              (+ (second hash-val)
                                                                 income-val)))))))
      (dolist (outlay-elem outlay-data)
        (let ((cate-id (getf outlay-elem :cate-id))
              (cate-name (getf outlay-elem :catename))
              (outlay-val (getf outlay-elem :val)))
          (setf outlay (+ outlay outlay-val))
          (let ((hash-val (gethash cate-id outlay-cate-sum)))
            (if (null hash-val)
                (setf (gethash cate-id outlay-cate-sum) (list (intern cate-name :keyword) outlay-val))
                (setf (gethash cate-id outlay-cate-sum) (list (first hash-val)
                                                              (+ (second hash-val)
                                                                 outlay-val)))))))
      (labels ((hash-to-list (hashdata)
                 (let (rtn)
                   (loop for key being each hash-key of hashdata
                      using (hash-value value)
                      do (progn
                           (setf rtn (append rtn value))))
                   rtn)))
        (values income
                (hash-to-list income-cate-sum)
                outlay
                (hash-to-list outlay-cate-sum))))))
