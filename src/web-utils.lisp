(in-package :cl-user)
(defpackage kanekanekane.web-utils
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.view
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :jump-to
           :if-login))
(in-package :kanekanekane.web-utils)

(defun jump-to (url &optional (jumptime 0))
  (declare (type string url)
           (type fixnum jumptime))
  (format nil "<!DOCTYPE html><html><head><meta http-equiv=\"refresh\" content=\"~A;URL=~A\"></head></html>" jumptime url))

(defmacro if-login (session login-true login-false)
  `(if (null (gethash :username ,session))
       ,login-false
       ,login-true))
