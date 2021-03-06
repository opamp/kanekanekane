(in-package :cl-user)
(defpackage kanekanekane.db.categories
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :find-cate
           :find-cate-by-id
           :create-new-cate
           :create-new-cate-and-return
           :get-all-categories
           :delete-cate))
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

(defun find-cate-by-id (id)
  (with-connection (db)
    (retrieve-one
     (select :*
             (from :categories)
             (where (:= :id id))))))

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

(defun get-all-categories (username)
  (with-connection (db)
    (retrieve-all
     (select :*
             (from :categories)
             (where (:= :username username))))))

(defun delete-cate (id)
  (with-connection (db)
    (execute (delete-from :categories
                          (where (:= :id id))))))
