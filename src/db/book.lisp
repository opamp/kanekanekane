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

;; (defun read-items (from to username)
;;   (let ((where-lst `(:and (:= :username ,username))))
;;     (when from
;;       (let* ((year (first from))
;;              (month (second from))
;;              (day (third from))
;;              (from-y-cond (when year `(:>= :t_year ,year)))
;;              (from-m-cond (when month `(:>= :t_month ,month)))
;;              (from-d-cond (when day `(:>= :t_day ,day))))
;;         (when from-y-cond (setf where-lst (append where-lst (list from-y-cond))))
;;         (when from-m-cond (setf where-lst (append where-lst (list from-m-cond))))
;;         (when from-d-cond (setf where-lst (append where-lst (list from-d-cond))))))
;;     (when to
;;       (let* ((year (first to))
;;              (month (second to))
;;              (day (third to))
;;              (from-y-cond (when year `(:<= :t_year ,year)))
;;              (from-m-cond (when month `(:<= :t_month ,month)))
;;              (from-d-cond (when day `(:<= :t_day ,day))))
;;         (when from-y-cond (setf where-lst (append where-lst (list from-y-cond))))
;;         (when from-m-cond (setf where-lst (append where-lst (list from-m-cond))))
;;         (when from-d-cond (setf where-lst (append where-lst (list from-d-cond))))))
;;     (format t "cond -> ~A~%" where-lst)
;;     (with-connection (db)
;;       (if (= (length where-lst) 2)
;;           (retrieve-all (select :*
;;                                 (from :book)
;;                                 (inner-join :categories :on (:= :book.cate_id :categories.id))
;;                                 (where (:= :username username))))
;;           (retrieve-all (select :*
;;                                 (from :book)
;;                                 (inner-join :categories :on (:= :book.cate_id :categories.id))
;;                                 (where where-lst)))))))
