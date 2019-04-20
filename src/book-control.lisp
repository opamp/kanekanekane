(in-package :cl-user)
(defpackage kanekanekane.book-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.utils
        :kanekanekane.db.book
        :kanekanekane.db.categories)
  (:export :write-new))
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
  (let ((date (handler-case (stringdate-to-lst date)
                (error () nil))))
    (cond
      ((null date)
       (error 'invalid-input-value :valname "date" :msg "invalid date data"))
      ((/= (length date) 3)
       (error 'invalid-input-value :valname "date" :msg "missing or excess data size"))
      ((< (first date) 0)
       (error 'invalid-input-value :valname "date" :msg "year data is minus"))
      ((or (<= (second date) 0) (> (second date) 12))
       (error 'invalid-input-value :valname "date" :msg "month date is out-of-range"))
      ((or (<= (third date) 0) (> (third date) 31))
       (error 'invalid-input-value :valname "date" :msg "day date is out-of-range"))
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
  (let ((name (prepare-name name))
        (date (prepare-date date))
        (income (prepare-income income))
        (amount (prepare-amount amount))
        (category (prepare-category category))
        (comment (prepare-comment comment)))
    (values name date income amount category comment)))

(defun write-new (name date income amount category comment username)
  (handler-case (multiple-value-bind (name date income amount category comment)
                    (prepare-values name date income amount category comment)
                  (let ((cat-data (aif (find-cate category income username)
                                       it
                                       (create-new-cate-and-return category income username))))
                    (if (null cat-data)
                        (error :absence-of-data :msg "category date could not get from DB")
                        (progn (create-new-item name date amount comment (getf cat-data :id))
                               (values t "OK")))))
    (invalid-input-value (e) (values nil (msg-of e)))
    (absence-of-data (e) (values nil (msg-of e)))
    (error () (values nil "critical error"))))

