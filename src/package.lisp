;;;; package.lisp

(uiop:define-package #:nepal
  (:use #:cl #:rtg-math)
  (:import-from #:temporal-functions
                #:make-stepper
                #:seconds)
  (:import-from #:serapeum
                #:op))
