(in-package #:nepal)

(defclass sfx (positional)
  ((pos-offset :accessor sfx-pos-offset :initarg  :pos-offset));!?
  (:default-initargs
   :pos-offset (v! 0 0 0))
  (:documentation "special type of event for sfx needs"))

(defmethod (setf pos) :around (value (obj sfx))
  "add offset to position before setting it"
  (call-next-method (v3:+ value (slot-value obj 'pos-offset)) obj))

(defun make-sfx (&rest args)
  (apply #'make-instance 'sfx args))

(defmethod play ((obj sfx))
  "plays cm:next buffer element in pattern"
  (with-slots (gain-offset pitch-offset volume pitch pattern source)
      obj
    (let ((buffer     (cm:next pattern))
          (new-volume (random-offset volume gain-offset))
          (new-pitch   (random-offset pitch pitch-offset)))
      (al:source source :buffer buffer)
      (al:source source :gain   new-volume)
      (al:source source :pitch  new-pitch)
      (al:source-play source))))
