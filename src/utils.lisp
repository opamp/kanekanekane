(in-package :cl-user)
(defpackage kanekanekane.utils
  (:use :cl
        :caveman2)
  (:export :aif
           :it
           :stringdate-to-lst))
(in-package :kanekanekane.utils)

(defmacro aif (condition t-form nil-form)
  `(let ((it ,condition))
     (if it ,t-form ,nil-form)))

(defun stringdate-to-lst (str)
  (ppcre:split "-" str))
