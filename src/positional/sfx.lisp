(in-package #:nepal)

(defclass sfx (positional)
  ((pos-offset :accessor sfx-pos-offset :initarg  :pos-offset));!?
  (:default-initargs
   :pos-offset (v! 0 0 0))
  (:documentation "special type of event for sfx needs"))

(defmethod (setf pos) :around (value (obj sfx))
  "add offset to position before setting it"
  (call-next-method (v3:+ value (slot-value obj 'pos-offset)) obj))

(defun make-sfx (name paths &key (pos           (v! 0 0 0))
                              (pos-offset    (v! 0 0 0))
                              (volume-offset 0f0)
                              (rate-offset   0f0)
                              (volume        0.1)
                              loop-p)
  (make-instance 'sfx :name name :paths paths :volume volume
                      :pos pos
                      :loop-p loop-p
                      :pos-offset pos-offset
                      :volume-offset volume-offset
                      :rate-offset rate-offset))

(defmethod play ((obj sfx))
  "plays cm:next buffer element in pattern"
  (with-slots (volume-offset rate-offset volume rate pattern source)
      obj
    (let ((buffer     (cm:next pattern))
          (new-volume (random-offset volume volume-offset))
          (new-rate   (random-offset rate rate-offset)))
      (al:source source :buffer buffer)
      (al:source source :gain   new-volume)
      (al:source source :pitch  new-rate)
      (al:source-play source))))
