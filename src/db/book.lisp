(in-package :cl-user)
(defpackage kanekanekane.db.book
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :create-new-item
           :read-items))
(in-package :kanekanekane.db.book)

(defun create-new-item (title date amount comment cate-id)
  (with-connection (db)
    (execute (insert-into :book
                          (set= :title title
                                :record_date date
                                :val amount
                                :comment comment
                                :cate_id cate-id)))))

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
