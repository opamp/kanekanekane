(in-package :cl-user)
(defpackage kanekanekane.db.book
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :create-new-item
           :read-item-by-id
           :read-items
           :read-items-by-cate-id
           :number-of-cate-id
           :rewrite-item))
(in-package :kanekanekane.db.book)

(defun create-new-item (title date val comment cate-id)
  (with-connection (db)
    (execute (insert-into :book
                          (set= :title title
                                :record_date date
                                :val val
                                :comment comment
                                :cate_id cate-id)))))

(defun read-item-by-id (id)
  (with-connection (db)
    (retrieve-one (select :*
                          (from :book)
                          (where (:= :id id))))))

(defun read-items (from to username)
  (let ((where-lst `(:and (:= :username ,username))))
    (when from
      (setf where-lst (append where-lst `((:>= :record_date ,from)))))
    (when to
      (setf where-lst (append where-lst `((:<= :record_date ,to)))))
    (with-connection (db)
      (if (= (length where-lst) 2)
          (retrieve-all (select (:book.id :title :record_date :val :comment :cate_id :income :catename)
                                (from :book)
                                (inner-join :categories :on (:= :book.cate_id :categories.id))
                                (where (:= :username username))))
          (retrieve-all (select (:book.id :title :record_date :val :comment :cate_id :income :catename)
                                (from :book)
                                (inner-join :categories :on (:= :book.cate_id :categories.id))
                                (where where-lst)))))))

(defun read-items-by-cate-id (cate-id)
  (with-connection (db)
    (retrieve-all (select :*
                          (from :book)
                          (where (:= :cate_id cate-id))))))

(defun number-of-cate-id (cate-id)
  (length (read-items-by-cate-id cate-id)))

(defun rewrite-item (id title date val comment cate-id)
  (with-connection (db)
    (execute (update :book
                     (set= :title title
                           :record_date date
                           :val val
                           :comment comment
                           :cate_id cate-id)
                     (where (:= :id id))))))
