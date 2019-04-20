(in-package :cl-user)
(defpackage kanekanekane.categories-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.utils
        :kanekanekane.db.categories)
  (:export :get-categories-list))
(in-package :kanekanekane.categories-control)

(defun get-categories-list (username)
  )
