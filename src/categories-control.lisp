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
  (let ((data (get-all-categories username))
        income-cates
        outlay-cates)
    (dolist (entry data)
      (let ((incometype (getf entry :income)))
        (if incometype
            (setf income-cates (append income-cates
                                       (list (getf entry :catename))))
            (setf outlay-cates (append outlay-cates
                                       (list (getf entry :catename)))))))
    (list income-cates outlay-cates)))


