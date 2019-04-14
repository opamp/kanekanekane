(in-package :cl-user)
(defpackage kanekanekane.user-control
  (:use :cl
        :caveman2
        :kanekanekane.db.users)
  (:export :signin))
(in-package :kanekanekane.user-control)

(defun hash-password (password)
  (let ((digester (ironclad:make-digest :SHA512)))
    (ironclad:digest-sequence digester
                              (ironclad:ascii-string-to-byte-array password))))

(defun singin (username password)
  )
