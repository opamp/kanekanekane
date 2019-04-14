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
   (render #p"index.html")
   (jump-to "/signin")))

(defroute ("/signin" :method :GET) ()
  (render #p"signin.html"))

(defroute ("/signin" :method :POST) (&key _parsed)
  )

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
