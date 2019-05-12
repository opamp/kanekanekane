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

(defroute "/user/info" ()
  (if-login
   *session*
   (render #p"userinfo.html")
   (jump-to "/")))

(defroute "/user/get/userdata" ()
  (if-login
   *session*
   (let ((username (gethash :username *session*)))
     (render-json (json-post-return 0
                                    "OK"
                                    (kanekanekane.user-control:get-userdata username))))
   (throw-code 403)))

(defroute "/user/get/basepoint-date" ()
  (if-login
   *session*
   (let ((username (gethash :username *session*)))
     (render-json (json-post-return 0
                                    "OK"
                                    (kanekanekane.book-control:make-basepoint-date
                                     (getf (kanekanekane.user-control:get-userdata username)
                                           :basepoint)))))
   (throw-code 403)))

(defroute "/user/update/basepoint/simple/:val" (&key val)
  (if-login
   *session*
   (let ((username (gethash :username *session*))
         (day (kanekanekane.user-control:prepare-basepoint val)))
     (if day
         (progn
           (kanekanekane.user-control:change-basepoint day username)
           (format nil "update"))
         (format nil "failed to update")))
   (throw-code 403)))

(defroute "/category/get/all" ()
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
         (kanekanekane.book-control:prepare-values name
                                                   date
                                                   incometype
                                                   amount
                                                   category
                                                   comment)
       (if rtn
           (if (kanekanekane.book-control:write-new (getf rtn :name)
                                                    (getf rtn :date)
                                                    (getf rtn :income)
                                                    (getf rtn :amount)
                                                    (getf rtn :category)
                                                    (getf rtn :comment)
                                                    username)
               (if (kanekanekane.user-control:add-balance (getf rtn :income) (getf rtn :amount) username)
                   (render-json (json-post-return 0 "OK"))
                   (render-json (json-post-return 3 "Failed to update balance of user data")))
               (render-json (json-post-return 2 "Failed to write DB")))
           (render-json (json-post-return 1 msg)))))
   (throw-code 403)))

(defroute ("/book/rewrite" :method :POST) (&key _parsed)
  (if-login
   *session*
   (let ((id (cdr (assoc "id" _parsed :test #'string=)))
         (name (cdr (assoc "name" _parsed :test #'string=)))
         (date (cdr (assoc "date" _parsed :test #'string=)))
         (incometype (cdr (assoc "incometype" _parsed :test #'string=)))
         (amount (cdr (assoc "amount" _parsed :test #'string=)))
         (category (cdr (assoc "category" _parsed :test #'string=)))
         (comment (cdr (assoc "comment" _parsed :test #'string=)))
         (username (gethash :username *session*)))
     (multiple-value-bind (rtn msg)
         (kanekanekane.book-control:prepare-values name
                                                   date
                                                   incometype
                                                   amount
                                                   category
                                                   comment)
       (if rtn
           (multiple-value-bind (old-itm new-itm msg)
               (kanekanekane.book-control:rewrite-data id
                                                       (getf rtn :name)
                                                       (getf rtn :date)
                                                       (getf rtn :income)
                                                       (getf rtn :amount)
                                                       (getf rtn :category)
                                                       (getf rtn :comment)
                                                       username)
             (if new-itm
                 (if (kanekanekane.user-control:re-balance (getf old-itm :income)
                                                           (getf old-itm :val)
                                                           (getf new-itm :income)
                                                           (getf new-itm :val)
                                                           username)
                     (render-json (json-post-return 0 "OK"))
                     (render-json (json-post-return 3 "Failed to update balanace of user data")))
                 (render-json (json-post-return 2 msg))))
           (render-json (json-post-return 1 msg)))))
   (throw-code 403)))

(defroute ("/book/eliminate" :method :POST) (&key _parsed)
  (if-login
   *session*
   (let ((id (cdr (assoc "id" _parsed :test #'string=)))
         (username (gethash :username *session*)))
     (let ((eliminated-data (kanekanekane.book-control:eliminate-data id)))
       (if (not (null eliminated-data))
           (if (kanekanekane.user-control:delete-balance (getf eliminated-data :income)
                                                         (getf eliminated-data :val)
                                                          username)
               (render-json (json-post-return 0 "OK"))
               (render-json (json-post-return 2 "Failed to change the balanace.")))
           (render-json (json-post-return 1 "Failed to eliminate")))))
   (throw-code 403)))

(defroute ("/book/read" :method :POST) (&key _parsed)
  (if-login
   *session*
   (let ((username (gethash :username *session*))
         (from-date (cdr (assoc "fromdate" _parsed :test #'string=)))
         (to-date (cdr (assoc "todate" _parsed :test #'string=))))
     (let ((data (kanekanekane.book-control:read-and-simplified-data from-date to-date username)))
       (render-json (json-post-return 0
                                      "OK"
                                      `(:data ,(make-array (length data)
                                                           :initial-contents
                                                           data))))))
   (throw-code 403)))

(defroute "/book/read/simple-summary-data" ()
  (if-login
   *session*
   (let ((username (gethash :username *session*)))
     (multiple-value-bind (s-data i-sum i-cate i-daily o-sum o-cate o-daily)
         (kanekanekane.book-control:read-and-simplified-data-from-basepoint username)
       (render-json (json-post-return 0 "OK" `(:incomeall ,i-sum
                                               :outlayall ,o-sum
                                               :incomebreakdown ,i-cate
                                               :outlaybreakdown ,o-cate
                                               :incomedaily ,i-daily
                                               :outlaydaily ,o-daily
                                               :data ,(make-array (length s-data)
                                                                  :initial-contents s-data))))))
   (throw-code 403)))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
