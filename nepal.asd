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
               #:cl-alut
               #:cm
               #:rtg-math
               #:serapeum)
  :components ((:file "package")
               (:file "nepal")
               (:file "audio")
               (:file "event")
               (:file "music")
               (:file "sfx")
               (:file "emmiter")))
