(in-package :cl-user)
(defpackage kanekanekane.user-control
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :signin))
(in-package :kanekanekane.user-control)

(defun singin (username password)
  )
