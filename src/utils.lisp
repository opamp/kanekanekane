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
           :universal-time-to-iso8601-date))
(in-package :kanekanekane.utils)

(defmacro aif (condition t-form nil-form)
  `(let ((it ,condition))
     (if it ,t-form ,nil-form)))

(defun stringdate-to-lst (str)
  (mapcar #'parse-integer (ppcre:split "-" str)))

(defun listdate-to-string (lst)
  (format nil "~A-~A-~A" (first lst) (second lst) (third lst)))

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

(defun universal-time-to-iso8601-date (univtime)
  (multiple-value-bind (sec min hour date month year day daylight zone)
      (decode-universal-time univtime)
    (declare (ignorable sec min hour date month year day daylight zone))
    (format nil "~4,'0d-~2,'0d-~2,'0d" year month day)))
