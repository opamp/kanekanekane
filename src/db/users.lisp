(in-package :cl-user)
(defpackage kanekanekane.db.users
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :get-user))
(in-package :kanekanekane.db.users)

(defun get-user (username)
  (with-connection (db)
    (retrieve-one (select :*
                         (from :users)
                         (where (:= :username username))))))

(defun update-password (username password)
  (with-connection (db)
    (execute (update :users
                     (set= :password password)
                     (where (= :username username))))))

(defun update-balance (username balance)
  (with-connection (db)
    (execute (update :users
                     (set= :balance balance)
                     (where (= :username username))))))

(defun update-basepoint (username basepoint)
  (with-connection (db)
    (execute (update :users
                     (set= :basepoint basepoint)
                     (where (= :username username))))))
