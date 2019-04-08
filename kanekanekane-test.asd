(defsystem "kanekanekane-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Masahiro Nagata"
  :license ""
  :depends-on ("kanekanekane"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "kanekanekane"))))
  :description "Test system for kanekanekane"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
