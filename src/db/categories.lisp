(in-package :cl-user)
(defpackage kanekanekane.db.categories
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :find-cate
           :create-new-cate
           :create-new-cate-and-return))
(in-package :kanekanekane.db.categories)

(defun find-cate (name incometype username)
  (with-connection (db)
    (retrieve-one
     (if incometype
         (select :*
                 (from :categories)
                 (where (:and (:= :catename name)
                              (:= :username username)
                              (:= :income "true"))))
         (select :*
                 (from :categories)
                 (where (:and (:= :catename name)
                              (:= :username username)
                              (:= :income "false"))))))))

(defun create-new-cate (name incometype username)
  (with-connection (db)
    (execute
     (if incometype
         (insert-into :categories
                      (set= :catename name
                            :income "true"
                            :username username))
         (insert-into :categories
                      (set= :catename name
                            :income "false"
                            :username username))))))

(defun create-new-cate-and-return (name incometype username)
  (create-new-cate name incometype username)
  (find-cate name incometype username))
