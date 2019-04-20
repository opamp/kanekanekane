(in-package :cl-user)
(defpackage kanekanekane.db.book
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.db
        :datafly
        :sxql)
  (:export create-new-item))
(in-package :kanekanekane.db.book)

(defun check-itm-value (title date-lst amount comment cate-id)
  )

(defun create-new-item (title date-lst amount comment cate-id)
  ;"hogehoge" ("2019" "04" "20") "20000" "" 5
  (with-connection (db)
    (execute (insert-into :book
                          (set= :title title
                                :t_year (first date-lst)
                                :t_month (second date-lst)
                                :t_day (third date-lst)
                                :val amount
                                :comment comment
                                :cate_id cate-id)))))
