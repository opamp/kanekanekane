(in-package :cl-user)
(defpackage kanekanekane.user-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.db.users)
  (:export :signin
           :get-userdata
           :add-balance
           :prepare-basepoint
           :change-basepoint))
(in-package :kanekanekane.user-control)

(defun hash-password (password)
  (let ((digester (ironclad:make-digest :SHA512)))
    (ironclad:digest-sequence digester
                              (ironclad:ascii-string-to-byte-array password))))

(defun signin (username password)
  (let ((userinfo (select-user-with-username username))
        (hashed-password (byte-array-to-hex-string (hash-password password))))
    (unless (null userinfo)
      (equal (getf userinfo :PASSWORD)
             hashed-password))))

(defun get-userdata (username)
  (let ((userinfo (select-user-with-username username)))
    `(:username
      ,(getf userinfo :username)
      :basepoint
      ,(getf userinfo :basepoint)
      :balance
      ,(getf userinfo :balance))))

(defun add-balance (incometype amount username)
  (let ((userinfo (get-userdata username)))
    (when userinfo
      (let ((new-balance (+ (getf userinfo :balance)
                            (if incometype
                                amount
                                (- amount)))))
        (update-balance-with-username username new-balance)
        t))))

(defun prepare-basepoint (day)
  (let ((day (handler-case (parse-integer day)
               (error () nil))))
    (when (and day
               (>= day 1)
               (<= day 31))
      day)))

(defun change-basepoint (day username)
  (update-basepoint-with-username username day))
