(in-package :cl-user)
(defpackage kanekanekane.web-utils
  (:use :cl
        :caveman2
        :kanekanekane.config
        :kanekanekane.view
        :kanekanekane.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :kanekanekane.web-utils)
