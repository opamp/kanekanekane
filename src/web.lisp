(in-package :cl-user)
(defpackage kanekanekane.web
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.view
        :kanekanekane.db
        :datafly
        :sxql
        :kanekanekane.web-utils)
  (:export :*web*))
(in-package :kanekanekane.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (if-login
   *session*
   (render #p"top.html")
   (jump-to "/signin")))

(defroute "/review" ()
  (if-login
   *session*
   (render #p"review.html")
   (jump-to "/signin")))

(defroute "/category/get-all" ()
  (if-login
   *session*
   (let* ((username (gethash :username *session*))
          (cate-data (kanekanekane.categories-control:get-categories-list username)))
     (render-json (json-post-return 0 "OK" `((:income ,@(first cate-data))
                                             (:outlay ,@(second cate-data))))))
   (throw-code 403)))

(defroute ("/book/write" :method :POST) (&key _parsed)
  (if-login
   *session*
   (let ((name (cdr (assoc "name" _parsed :test #'string=)))
         (date (cdr (assoc "date" _parsed :test #'string=)))
         (incometype (cdr (assoc "incometype" _parsed :test #'string=)))
         (amount (cdr (assoc "amount" _parsed :test #'string=)))
         (category (cdr (assoc "category" _parsed :test #'string=)))
         (comment (cdr (assoc "comment" _parsed :test #'string=)))
         (username (gethash :username *session*)))
     (multiple-value-bind (rtn msg)
         (kanekanekane.book-control:write-new name
                                              date
                                              incometype
                                              amount
                                              category
                                              comment
                                              username)
       (render-json (if rtn
                        (json-post-return 0 msg)
                        (json-post-return 1 msg)))))
   (throw-code 403)))


(defroute ("/signin" :method :GET) ()
  (if-login *session*
            (progn
              (format nil "You are already logged in.")
              (jump-to "/" 2))
            (render #p"signin.html")))

(defroute ("/signin" :method :POST) (&key _parsed)
  (let* ((userdata (cdr (assoc "user" _parsed :test #'string=)))
         (name (cdr (assoc "name" userdata :test #'string=)))
         (password (cdr (assoc "password" userdata :test #'string=))))
    (if (kanekanekane.user-control:signin name password)
        (progn
          (setf (gethash :username *session*) name)
          (jump-to "/"))
        (format nil "Failed to login~%"))))

;; temporary implementation
(defroute ("/signup" :method :GET) ()
  (format nil "This method has not been implemented yet. Please contact an admitistrator of this service."))
; (defroute ("/signup" :method :POST) (&key _parsed))

(defroute ("/signout" :method :GET) ()
  (setf (gethash :username *session*) nil)
  (format nil "SEE YOU...")
  (jump-to "/" 1))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
