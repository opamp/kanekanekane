(in-package :cl-user)
(defpackage kanekanekane.user-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.db.users)
  (:export :signin))
(in-package :kanekanekane.user-control)

(defun hash-password (password)
  (let ((digester (ironclad:make-digest :SHA512)))
    (ironclad:digest-sequence digester
                              (ironclad:ascii-string-to-byte-array password))))

(defun singin (username password)
  (let ((userinfo (get-user username))
        (hashed-password (byte-array-to-hex-string (hash-password password))))
    (unless (null userinfo)
      (equal (getf userinfo :PASSWORD)
             hashed-password))))
