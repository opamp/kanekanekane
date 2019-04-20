(defsystem "kanekanekane"
  :version "0.1.0"
  :author "Masahiro Nagata"
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
               "sxql"

               ;; additional dependencies
               "ironclad")
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view" "web-utils" "user-control" "book-control"))
                 (:file "user-control" :depends-on ("db/users"))
                 (:file "book-control" :depends-on ("db/book" "db/categories"))
                 (:file "web-utils" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db/users" :depends-on ("db"))
                 (:file "db/book" :depends-on ("db"))
                 (:file "db/categories" :depends-on ("db"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "kanekanekane-test"))))
