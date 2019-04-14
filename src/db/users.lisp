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

