(in-package :cl-user)
(defpackage kanekanekane.db.users
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :select-user-with-username
           :update-password-with-username
           :update-balance-with-username
           :update-basepoint-with-username))
(in-package :kanekanekane.db.users)

(defun select-user-with-username (username)
  (with-connection (db)
    (retrieve-one (select :*
                         (from :users)
                         (where (:= :username username))))))

(defun update-password-with-username (username password)
  (with-connection (db)
    (execute (update :users
                     (set= :password password)
                     (where (:= :username username))))))

(defun update-balance-with-username (username balance)
  (with-connection (db)
    (execute (update :users
                     (set= :balance balance)
                     (where (:= :username username))))))

(defun update-basepoint-with-username (username basepoint)
  (with-connection (db)
    (execute (update :users
                     (set= :basepoint basepoint)
                     (where (:= :username username))))))

