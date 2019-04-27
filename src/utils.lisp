(in-package :cl-user)
(defpackage kanekanekane.utils
  (:use :cl
        :caveman2)
  (:export :aif
           :it
           :stringdate-to-lst
           :listdate-to-string
           :today-list
           :date-exist-p
           :universal-time-to-list-date
           :universal-time-to-iso8601-date
           :book-data-date-to-iso8601
           :add-day
           :make-date-plist))
(in-package :kanekanekane.utils)

(defmacro aif (condition t-form nil-form)
  `(let ((it ,condition))
     (if it ,t-form ,nil-form)))

(defun stringdate-to-lst (str)
  (mapcar #'parse-integer (ppcre:split "-" str)))

(defun listdate-to-string (lst)
  (format nil "~4,'0d-~2,'0d-~2,'0d" (first lst) (second lst) (third lst)))

(defun today-list ()
  (let ((today (stringdate-to-lst (metatilities:date-string-brief))))
    (list (third today) (first today) (second today))))

(defun date-exist-p (y m d)
  (let ((ut (encode-universal-time 0 0 0 d m y)))
    (multiple-value-bind (ig no re d2 m2 y2)
        (decode-universal-time ut)
      (declare (ignore ig no re))
      (and (= y y2)
           (= d d2)
           (= m m2)
           ut))))

(defun universal-time-to-list-date (univtime)
  (multiple-value-bind (sec min hour date month year day daylight zone)
      (decode-universal-time univtime)
    (declare (ignorable sec min hour date month year day daylight zone))
    (list year month date)))

(defun universal-time-to-iso8601-date (univtime)
  (let ((lst-date (universal-time-to-list-date univtime)))
    (listdate-to-string (list
                         (first lst-date)
                         (second lst-date)
                         (third lst-date)))))

(defun book-data-date-to-iso8601 (bookdata)
  (let ((rtn (copy-list bookdata)))
    (setf (getf rtn :RECORD-DATE) (universal-time-to-iso8601-date (getf rtn :RECORD-DATE)))
    rtn))

(defun add-day (date-lst val)
  (let ((added-date-universal-time (+ (encode-universal-time 0 0 0 (third date-lst) (second date-lst) (first date-lst))
                                      (* val 24 60 60))))
    (universal-time-to-list-date added-date-universal-time)))

(defun make-date-plist (from to &key initial-element)
  (labels ((make-date-plist-2 (from to initial-element rtn)
             (if (equalp from to)
                 (append rtn (list (intern (listdate-to-string to) :keyword)
                                   initial-element))
                 (make-date-plist-2 (add-day from 1)
                                    to
                                    initial-element
                                    (append rtn
                                            (list (intern (listdate-to-string from) :keyword)
                                                  initial-element))))))
    (make-date-plist-2 from to initial-element nil)))
