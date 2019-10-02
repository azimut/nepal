(in-package #:nepal)

;; Container of events. Plays the events it holds providing positional data.
;; Inherit from this class to for your object to have sound.

(defclass actor ()
  ((pos :initform (v! 0 0 0) :initarg :pos :accessor pos)))

(defclass emitter (actor)
  ((prev-pos :initarg :prev-pos :accessor emitter-prev-pos)
   (velocity :initarg :velocity :accessor emitter-velocity)
   (events   :initarg :emitter  :accessor emitter-events))
  (:default-initargs
   :pos      (v! 0 0 0)
   :prev-pos (v! 0 0 0)
   :velocity (v! 0 0 0)
   :events   (list)))

(defun make-emitter (&rest events)
  (make-instance 'emitter :events events))

(defun play-emitter (emitter)
  (with-accessors ((velocity emitter-velocity)
                   (events   emitter-events)
                   (position pos))
      emitter
    (map nil (op (play-audio _ position velocity)) events)))

(defmethod update :before ((obj emitter) dt)
  "set velocity"
  (setf (emitter-velocity obj) (v3:/s (v3:- (pos obj) (emitter-prev-pos obj)) dt)))

(defmethod update :after ((obj emitter) dt)
  "set previous position for next loop cycle"
  (setf (emitter-prev-pos obj) (copy-seq (pos obj))))

;; Ambient sfx (howl)
;;(make-emitter (make-event :odds .3 "howl.wav"))

