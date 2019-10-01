(in-package #:incandescent)

;; Container of events. Plays the events it holds providing positional data.
;; Inherit from this class to for your object to have sound.

(defclass emitter (actor)
  ((prev-pos :initarg :prev-pos :accessor emitter-prev-pos)
   (velocity :initarg :velocity :accessor emitter-velocity)
   (events   :initarg :emitter  :accessor emitter-events))
  (:default-initargs
   :events (list)
   :prev-pos (v! 0 0 0)
   :velocity (v! 0 0 0)))

(defun make-emitter (&rest events)
  (make-instance 'emitter :events events))

(defun play-emitter (emitter)
  (with-accessors ((pos pos) (vel emitter-velocity) (events emitter-events)) emitter
    (map nil (op (play-event _ pos vel)) events)))

(defmethod update :before ((obj emitter) dt)
  "set velocity"
  (setf (emitter-velocity obj) (v3:/s (v3:- (pos obj) (emitter-prev-pos obj)) dt)))

(defmethod update :after ((obj emitter) dt)
  "set previous position for next loop cycle"
  (setf (emitter-prev-pos obj) (copy-seq (pos obj))))

;; Ambient sfx (howl)
;;(make-emitter (make-event :odds .3 "howl.wav"))

