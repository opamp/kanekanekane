(in-package :cl-user)
(defpackage kanekanekane.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :*signup-enable*
           :appenv
           :developmentp
           :productionp))
(in-package :kanekanekane.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*   (asdf:system-source-directory :kanekanekane))
(defparameter *static-directory*   (merge-pathnames #P"static/" *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/" *application-root*))
(defparameter *signup-enable* nil)

(defconfig :common
    `(:databases ((:maindb :postgres :host "localhost" :database-name "kanekanekane_devel" :username "devel"))))

(defconfig |development|
    `(:databases ((:maindb :postgres :host "localhost" :database-name "kanekanekane_devel" :username "devel"))))

(defconfig |production|
    `(:databases ((:maindb :postgres :host "" :database-name "" :username "" :password "")))) ; DB setting 

(defconfig |test|
    `(:databases ((:maindb :postgres :host "localhost" :database-name "kanekanekane_devel" :username "devel"))))

(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
