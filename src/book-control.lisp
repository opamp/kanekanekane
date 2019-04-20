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

(defun write-new (name date income amount category comment username)
  (let ((cat-data (aif (find-cate category income username)
                       it
                       (create-new-cate-and-return category income username))))
    (format t "OUTPUT DB==> ~A~%" cat-data)
    (if cat-data
        (progn
          (create-new-item name (stringdate-to-lst date) amount comment (getf cat-data :id))
          (values t ""))
        (values nil "category error"))))
