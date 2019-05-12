(in-package :cl-user)
(defpackage kanekanekane.user-control
  (:use :cl
        :caveman2
        :ironclad
        :kanekanekane.db.users)
  (:export :signin
           :get-userdata
           :add-balance
           :re-balance
           :delete-balance
           :prepare-basepoint
           :prepare-password
           :change-basepoint
           :change-balance
           :change-password))
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

(defun re-balance (old-incometype old-amount new-incometype new-amount username)
  (let ((userinfo (get-userdata username))
        (old-amount (if old-incometype old-amount (- old-amount)))
        (new-amount (if new-incometype new-amount (- new-amount))))
    (when userinfo
      (let ((new-balance (+ (getf userinfo :balance)
                            (- new-amount old-amount))))
        (update-balance-with-username username new-balance)
        t))))

(defun delete-balance (incometype amount username)
  (let ((userinfo (get-userdata username)))
    (when userinfo
      (let ((new-balance (- (getf userinfo :balance)
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

(defun prepare-password (pass)
  (unless (< (length pass) 4)
    pass))

(defun change-basepoint (day username)
  (update-basepoint-with-username username day))

(defun change-balance (val username)
  (update-balance-with-username username val)
  t)

(defun change-password (password username)
  (let ((hashed-password (byte-array-to-hex-string (hash-password password))))
    (update-password-with-username username hashed-password)
    t))
