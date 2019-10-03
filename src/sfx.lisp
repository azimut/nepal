(in-package #:nepal)

(defclass sfx (positional)
  ((pos-offset    :accessor sfx-pos-offset    :initarg  :pos-offset) ;!
   (volume-offset :accessor sfx-volume-offset :initarg  :volume-offset)
   (rate-offset   :accessor sfx-rate-offset   :initarg  :rate-offset)
   (step-size     :reader   sfx-step-size     :initarg  :step-size)
   (stepper       :reader   sfx-stepper       :initform nil))
  (:default-initargs
   :pos-offset (v! 0 0 0)
   :volume-offset 0f0
   :rate-offset 0f0
   :step-size 0f0)
  (:documentation "special type of event for sfx needs"))

(defmethod initialize-instance :after ((obj sfx) &key step-size pos)
  (when (not (zerop step-size))
    (setf (slot-value obj 'stepper)
          (make-stepper (seconds step-size) (seconds step-size)))))

(defmethod (setf pos) :around (value (obj sfx))
  "add offset to position before setting it"
  (call-next-method (v3:+ value (slot-value obj 'pos-offset)) obj))

(defun make-sfx (name paths &key (pos           (v! 0 0 0))
                                 (pos-offset    (v! 0 0 0))
                                 (volume-offset 0f0)
                                 (rate-offset   0f0)
                                 (volume        0.1))
  (make-instance 'sfx :name name :paths paths :volume volume
                      :pos pos
                      :pos-offset pos-offset
                      :volume-offset volume-offset
                      :rate-offset rate-offset))

(declaim (inline random-offset))
(defun random-offset (value offset)
  (if (zerop offset)
      value
      (+ value (- (random offset) (/ offset 2f0)))))

(defmethod play ((obj sfx))
  "plays cm:next buffer element in pattern"
  (with-accessors ((volume-offset sfx-volume-offset)
                   (rate-offset   sfx-rate-offset)
                   (stepper       sfx-stepper)
                   (volume        event-volume)
                   (rate          event-rate)
                   (pattern       event-pattern)
                   (source        audio-source))
      obj
    (when (or (not stepper) (funcall stepper))
      (let ((buffer     (cm:next pattern))
            (new-volume (random-offset volume volume-offset))
            (new-rate   (random-offset rate rate-offset)))
        (al:source source :buffer buffer)
        (al:source source :gain   new-volume)
        (al:source source :pitch  new-rate)
        (al:source-play source)))))
