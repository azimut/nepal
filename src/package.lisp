;;;; package.lisp

(uiop:define-package #:nepal
  (:use #:cl #:rtg-math)
  (:export #:make-audio
           #:make-event
           #:make-positional
           #:make-sfx
           #:make-music
           #:init-audio
           #:list-asources
           #:list-abuffers
           #:load-abuffer
           ;;
           #:play
           #:stop
           ;;
           #:audio
           #:event
           #:positional
           #:sfx
           #:music)
  (:import-from #:temporal-functions
                #:make-stepper
                #:seconds))
