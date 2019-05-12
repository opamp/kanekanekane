(defsystem "kanekanekane"
  :version "0.0.1"
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
               "ironclad"
               "metatilities"
               "cl-ppcre")
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view" "web-utils" "user-control" "book-control" "categories-control"))
                 (:file "book-control" :depends-on ("db/book" "db/categories" "db/users" "utils"))
                 (:file "user-control" :depends-on ("db/users"))
                 (:file "categories-control" :depends-on ("db/categories" "utils"))
                 (:file "web-utils" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db/users" :depends-on ("db"))
                 (:file "db/book" :depends-on ("db"))
                 (:file "db/categories" :depends-on ("db"))
                 (:file "db" :depends-on ("config"))
                 (:file "utils")
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "kanekanekane-test"))))
