(in-package #:nepal)

(defclass sfx (event)
  ((pos-offset    :initarg :pos-offset    :accessor sfx-pos-offset);!
   (volume-offset :initarg :volume-offset :accessor sfx-volume-offset)
   (rate-offset   :initarg :rate-offset   :accessor sfx-rate-offset)
   (stepper       :initarg :stepper       :accessor sfx-stepper)
   (step-size     :initarg :step-size     :accessor sfx-step-size))
  (:default-initargs
   :pos-offset (v! 0 0 0)
   :volume-offset 0f0
   :rate-offset 0f0
   :stepper nil
   :step-size 0f0)
  (:documentation "special type of event for sfx needs"))

(defmethod initialize-instance :after ((obj sfx) &key stepper step-size)
  (when (not (zerop step-size))
    (setf stepper (make-stepper (seconds step-size) (seconds step-size)))))

(defun make-sfx (name &rest paths
                      &key (volume 0.1)
                           (volume-offset 0f0)
                           (rate-offset 0f0)
                           (pos-offset (v! 0 0 0))
                      &allow-other-keys)
  (remf paths :volume)
  (remf paths :volume-offset)
  (remf paths :rate-offset)
  (remf paths :pos-offset)
  (make-instance 'sfx :name name :paths paths :volume volume
                      :volume-offset volume-offset
                      :rate-offset rate-offset
                      :pos-offset pos-offset))

(declaim (inline random-offset))
(defun random-offset (value offset)
  (if (zerop offset)
      value
      (+ value (- (random offset) (/ offset 2f0)))))

(defmethod play-audio ((obj sfx))
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
        (al:source source :gain new-volume)
        (al:source source :pitch new-rate)
        (al:source-play source)))))

