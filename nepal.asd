;;;; nepal.asd

(asdf:defsystem #:nepal
  :description "cl-openal helpers for 3d positional audio"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :depends-on (#:alexandria
               #:cl-openal
               #:openal-blob
               #:cl-alut
               #:cm
               #:rtg-math
               #:temporal-functions)
  :components ((:file "package")
               (:file "nepal")
               (:file "audio")
               (:file "listener")
               (:file "event/event")
               (:file "event/music")
               (:file "positional/positional")
               (:file "positional/sfx")
               (:file "demo")))
